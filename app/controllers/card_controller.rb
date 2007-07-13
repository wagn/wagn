class CardController < ApplicationController
  helper :wagn, :card 
  layout :ajax_or_not
  observer :card_observer, :tag_observer
  cache_sweeper :card_sweeper
  before_filter :load_card, :except => [ :new, :create, :show, :index  ]
  
  # views ---------------------------------------
  
  def index
    redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
  end
  
  def show
    @card_name = Cardname.unescape(params['id'] || '')
    if @card_name.nil? or @card_name.empty?
      return redirect_to :controller=>'card',:action=>'show', :id=>Cardname.escape(System.site_name)
    end             
    
    if (@card = Card.find_by_name( @card_name )) 
      @card.read_ok!
      remember_card @card
      load_context
      load_renderer                                 
      respond_to do |format|
        format.html { render :action=>'show' }
        format.json {
          render_jsonp :partial =>'card/card_slot', :locals=>{ 
            :card                               => @card,
            :context                            => 'wadget',
            :partial                            => 'paragraph sidebar',
            :div_id                             => 'main-body'
          }
        }
      end
    elsif User.current_user
      redirect_to :controller=>'card', :action=>'new', :params=>{ 'tag[name]'=>@card_name }
    else
      # FIXME this logic is not right.  We should first check whether 
      # the user has permission to create a card.  If not, then we should 
      # redirect anonymous users to the login page with some sort of message
      # explaining why they're there.  And there should be a different way of 
      # handling users who are logged in but lack permission to create cards 
      # (it would be nice to catch them before they leave the referring page,
      # but there needs to be a net anyway, and besides this is currently still
      # just a theoretical case)
      redirect_to :controller=>'account', :action=>'login'
    end
  end

  def view
    render :partial=>"card/card", :locals=>{ :card=>@card, :element=>params[:element] } 
  end

  def new
    @tag = Tag.new({
      'datatype_key'=>Card.default_datatype_key,
      'plus_datatype_key'=>Card.default_plus_datatype_key
    }.merge(params[:tag]||{}))  
    @card = Card.const_get( params[:cardtype] || "Basic" ).new(
     {:name=>""}.merge( params[:card] || {} ).merge( :tag=>@tag )
    )
    #warn "TAG DATATYPE KEY: #{@tag.datatype_key}"
    if request.post?
      render :partial=>'new_editor', :locals=>{:datatype_key=>@tag.datatype_key } 
    end
  end

  def options; end
  def remove_form; end
  def rename_form; end
  def edit_form;  end
  def edit_transclusion; end

=begin
  def change_cardtype_form; end
  def change_datatype_form; end
  def change_plus_datatype_form; end
=end

  
  def editor 
    render :partial=>"/card/editor", :locals=>{ :card=>@card, :div_id=>params[:element] }
  end
  
  def revision
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end

  # actions ------------------------------------------------------
  
  def edit
    old_rev_id = params[:card].delete(:old_revision_id)
    warn "EDIT PARAMS: #{params[:card].inspect}"
    if old_rev_id.to_i != @card.current_revision.id
      revision  # FIXME -- this should probably be abstracted?
      @changes = render_to_string :action=>'revision' 
      render :action=>:edit_conflict
    else
      WikiContent.process_links!(params[:card][:content], url="http://#{request.host_with_port}")
      @card.update_attributes( params[:card] )
    end
    #render_update do |page|
    #end
  end
  
  def save_draft
    @card.save_draft( params[:card][:content] )
    render(:update) do |page|
      page.wagn.messenger.log("saved draft of #{@card.title}")
    end
  end
  
  def create         
    params[:tag][:name].strip!
    @tag = Tag.new params[:tag]
    @card = Card.const_get(params[:cardtype] || 'Basic' ).create!( params[:card].merge(:tag=>@tag, :name=>params[:tag][:name]) )
    
    # prevent infinite redirect loop
    if !Card.find_by_name(params[:tag][:name])
      fail "Card creation failed" 
    end
    #redirect_to url_for_page(@card.landing_name)
  end 

  def flip
    @card.flip_trunk_and_tag
    render :action=>'update'
  end
  
#  def update
#    @tag.update_attributes( params[:tag] ) if params[:tag]
#    @card.update_attributes( params[:card] ) if params[:card]
#  end
  
  def rename
    @card.rename( params[:tag][:name], params[:change_links]=='yes' )
  end
  
  def remove
    if @card.simple? and User===@card
      oops "Can't remove Users"
    end
    @card.destroy
  end

  def rollback
    load_card_and_revision
    @card.revise @revision.content
    render :action=>'edit'
  end  
  
  def update_reader
    @new_reader = Role.find( params[:card][:reader_id] )
    @card.reader = @new_reader
    @card.save!
    render(:update) do |page|
      page.replace_html "#{params[:element]}-writer-select", :partial=>'writer_select'
      page.wagn.messenger.note "#{@card.name} #{params[:message] || 'updated'}"
    end
  end
  
  def update_writer
    @new_writer = Role.find( params[:card][:writer_id] )
    @card.writer = @new_writer
    @card.save!
    render(:update) do |page|
      page.replace_html "#{params[:element]}-reader-select", :partial=>'reader_select'
      page.wagn.messenger.note "#{@card.name} #{params[:message] || 'updated'}"
    end
  end
   
  def update
    @updated_attributes = params[:card].keys
    if !@card.update_attributes( params[:card] )
      render(:update) do |page|
        page << "$('#{params[:element]}').card().reset()"
      end
    end
  end
                                     
  def attribute
    @attr = params[:attribute]
    id = @card.id
    if request.post? 
      method = case @attr
                when 'cardtype'; 'type'
                when 'datatype'; 'datatype_key'
                when 'plus_datatype'; 'plus_datatype_key' 
                else @attr
               end
               
      @card.send("#{method}=", params[:value])
      @card.save
    end                           
    @card = Card::Base.find(id)
    result = 
      case @attr
      when 'cardtype'          
        @card.cardtype.name
      when 'datatype'    
        @card.tag.datatype_key
      when 'plus_datatype'
        @card.tag.plus_datatype_key
      else
        @card.send(@attr)
      end
    render :text => result
  end

end
