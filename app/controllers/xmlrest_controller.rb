require 'rexml/document'

class XmlrestController < ApplicationController
  helper :wagn, :card 

  before_filter :create_ok, :only=>[ :put, :post ]
  before_filter :load_card!, :only=>[ :get, :put ]
  before_filter :load_card_with_cache, :only => [ :get, :delete ]
  before_filter :name_ok,   :only=>[ :put, :post ] 
  before_filter :edit_ok,   :only=>[ :put, :post ] 
  before_filter :remove_ok, :only=>[ :delete ]
  
  #----------( Special cards )
    
  public    
  
  #----------( Special cards )
  
  def method
    method = request.method
    if REST_METHODS.member?(method)
      self.send(method)
    else
      raise("Not a REST method #{method}")
    end
  end
  
  def get
    #location_history.push(request.request_uri) if request.get?
    params[:_keyword] && params[:_keyword].gsub!('_',' ') ## this will be unnecessary soon.

    @card_name = Cardname.unescape(params['id'] || '')
    @card_name = System.site_title if (@card_name.nil? or @card_name.empty?) 
    #@card_name = System.deck_name
    @card = CachedCard.get(@card_name)

    if @card.new_record? && !@card.virtual?  # why doesnt !known? work here?
      params[:card]={:name=>@card_name, :type=>params[:type]}
      begin
        return ( Card::Basic.create_ok? ? self.new : render(:action=>'missing', :format=>'xml') )
      rescue Exception=>e
        raise e
      end
    else
      save_location
    end
    return if !view_ok # if view is not ok, it will render denied. return so we dont' render twice

    # rss causes infinite memory suck in rails 2.1.2.  
    unless Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR >=2
      respond_to do |format|
        format.rss { raise("Sorry, RSS is broken in rails < 2.2") }
        format.html {}
      end
    end
    render_show
  end

  def render_show
    Wagn::Hook.call :before_show, '*all', self
    
    @title = @card.name=='*recent changes' ? 'Recently Changed Cards' : @card.name
    ## fixme, we ought to be setting special titles (or all titles) in cards
    (request.xhr? || params[:format]) ? render(:action=>'get') :
	render(:text=>'~~render main inclusion~~', :layout=>true)
  end

  #----------------( MODIFYING CARDS )
  
  def read_xml(xml, card_name, card_updates, f)
    card_content=''
    no_card=false
    #raise("Should be card, #{card_name}") if xml.name != 'card'
    raise("No xml?, #{card_name}") unless xml
    xml.each_child { |e|
      if REXML::Element===e
        if e.name == 'card'
          sub_cname = card_name+'+'+e.attribute('name').to_s
          t= e.attribute('transclude') || 'no transclude attribute'
          card_content += "{{#{t}}}"
          read_xml(e, sub_cname, card_updates, f)
        else
          e.name == 'no_card' && no_card=true
          card_content += '<'+e.expanded_name
          e.attributes.each_attribute do |attr|
            card_content += " "
            attr.write( card_content )
          end unless e.attributes.empty?
          if e.children.empty?
            card_content += "/>"
          else    
            card_content += '>'+read_xml(e, card_name, card_updates, f)+
                            '</'+e.expanded_name+'>'
          end
        end
      else
        #f.write_text(e, card_content)
        e.write(card_content)
      end
    }
    if xml.name == 'card'
      this_card = CachedCard.get(card_name)
      # no card and no new content, don't update
      unless no_card || this_card.new_record? && !card_content
        card_cc = this_card.content
        this_name = this_card.name
        if card_content != card_cc
          card_updates[card_name] = {:content => card_content}
        end
      end
    end
    card_content
  end

  def put
    @card_name = Cardname.unescape(params['id'] || '')
    raise("Need a card name to put") if (@card_name.nil? or @card_name.empty?)
    @card = CachedCard.get(@card_name)

    #raise("PUT #{params.to_yaml}\n")
    content = request.body.read
    doc = REXML::Document.new(content)
raise "XML error: #{doc} #{content}" unless doc.root
    #f = REXML::Formatters::Transitive.new
    card_updates = Hash.new
    read_xml(doc.root, @card_name, card_updates, nil)
    if !card_updates.empty?
      @card.multi_update card_updates 
    end
    end
  
  def post
    return render(:action=>"missing", :format=>:xml)  unless params[:card]
  
    @card = Card.create params[:card]        
    if params[:multi_edit] and params[:cards] and !@card.errors.present?
      @card.multi_create(params[:cards]) 
    end

    # according to rails / prototype docs:
    # :success: [...] the HTTP status code is in the 2XX range.
    # :failure: [...] the HTTP status code is not in the 2XX range.
  
    # however on 302 ie6 does not update the :failure area, rather it sets the :success area to blank..
    # for now, to get the redirect notice to go in the failure slot where we want it, 
    # we've chosen to render with the (418) 'teapot' failure status: 
    # http://en.wikipedia.org/wiki/List_of_HTTP_status_codes  
    handling_errors do
      @thanks = Wagn::Hook.call( :redirect_after_create, @card ).first ||
        @card.setting('thanks')
      case
        when @thanks.present?;               ajax_redirect_to @thanks 
        when @card.ok?(:read) && main_card?; ajax_redirect_to url_for_page( @card.name )
        when @card.ok?(:read);               render_show
        else                                 ajax_redirect_to "/"
      end
    end
  end
  
  def ajax_redirect_to url
    @redirect_location = url
    @message = "Create Successful!"
    render :action => "ajax_redirect", :status => 418
  end
    
  
  #--------------( editing )
  
  def denial
    render :template=>'/card/denied', :status => 403, :format => :xml
  end
    
  def delete  
    if params[:card]
      @card.confirm_destroy = params[:card][:confirm_destroy]
    end        
    
    captcha_ok = captcha_required? ? verify_captcha : true   
    unless captcha_ok
      return render_update_slot( render_to_string(:partial=>'confirm_remove'))
    end

    @card.destroy
      
    if @card.errors.on(:confirmation_required)
      return render_update_slot( render_to_string(:partial=>'confirm_remove'))
    end

    handling_errors do
      discard_locations_for(@card)
      render_update_slot do |page,target|
        if main_card?
          page.wagn.messenger.note "#{@card.name} removed."
          page.redirect_to previous_location
          flash[:notice] =  "#{@card.name} removed"
        else 
          target.replace %{<div class="faint">#{@card.name} was just removed</div>}
          page.wagn.messenger.note( "#{@card.name} removed. ")  
        end
      end
    end
  end

  #---------------( tabs )

  def view
    render_show
  end   
  
  def open
    params[:view] = :open
    render_show
  end

  def options
    @extension = @card.extension
    render :partial=>"card/options/#{params[:attribute]}" if params[:setting] and 
      ['closed_setting','open_setting'].include?(params[:attribute])
  end

  def changes
    load_card_and_revision
    @show_diff = (params[:mode] != 'false')
    @previous_revision = @card.previous_revision(@revision)
  end

  def related
    sources = [@card.cardtype.name,nil]
    sources.unshift '*account' if @card.extension_type=='User' 
    @items = sources.map do |root| 
      c = CachedCard[(root ? "#{root}+" : '') +'*related']
      c && c.type=='Pointer' && c.pointees
    end.flatten.compact
    @items << 'config'
    @current = params[:attribute] || @items.first.to_key
  end

  #------------------( views )

  
  [:open_missing, :closed_missing].each do |method|
    define_method( method ) do
      load_card
      params[:view] = method
      if id = params[:replace]
        render_update_slot do |page, target|
          target.update render_to_string(:action=>'show')
        end
      else
        render_show
      end
    end
  end

  
  def xml_missing
    load_card
    params[:view] = method
    if id = params[:replace]
      render_update_slot do |page, target|
        target.update render_to_string(:action=>'get')
      end
    else
      render :action=>'missing', :format => :xml
    end
  end
end

