
require 'rexml/document'
#require 'rexml/formatters'

require 'ruby-debug'
#debugger

class XmlcardController < ApplicationController

  helper :card 
  layout :default_layout
  cache_sweeper :card_sweeper

  before_filter :create_ok, :only=>[ :post, :put ]

  before_filter :load_card!, :only=>[ :get, :put, :post ]
    #:changes, :comment, :denied, :edit, :edit_conflict, :edit_name, 
    #:edit_type, :options, :quick_update, :related, :remove, :rollback, 
    #:save_draft, :update
  #]

  before_filter :load_card_with_cache, :only => [ :get ]
  
  before_filter :edit_ok,   :only=>[ :post, :put ]
  before_filter :remove_ok, :only=>[ :delete ]
  
  #caches_action :show, :view, :to_view

  protected
  def action_fragment_key(options)
    roles_key = User.current_user.all_roles.map(&:id).join('-')
    global_serial = Cache.get('GlobalSerial') #Time.now.to_f }
    key = url_for(options).split('://').last + "/#{roles_key}" + "/#{global_serial}" + 
      "/#{default_layout}"
  end
       

  public    

  #----------( Special cards )
  
  def method
    method = request.method
#debugger
    if REST_METHODS.member?(method)
      self.send(method)
    else
      #debugger
      raise("Not a REST method #{method}")
    end
  end

  def get
    # record this as a place to come back to.
    location_history.push(request.request_uri) if request.get?

    params[:_keyword] && params[:_keyword].gsub!('_',' ') ## this will be unnecessary soon.

    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      @card_name = System.site_title
      #@card_name = System.deck_name
    end             
    @card = CachedCard.get(@card_name)

    if @card.new_record? && ! @card.phantom?
      params[:card]={:name=>@card_name, :type=>params[:type]}
      if Cardtype.createable_cardtypes.empty? 
        return render(:action=>'missing')
      else
        return self.new
      end
    end                                                                                  
    return unless view_ok # if view is not ok, it will render denied. return so we dont' render twice

    # rss causes infinite memory suck in rails 2.1.2.  
    unless Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR >=2
      respond_to do |format|
        format.rss { raise("Sorry, RSS is broken in rails < 2.2") }
        format.html {}
      end
    end 
  end

  #----------------( MODIFYING CARDS )
  
  def read_xml(xml, card_name, card_updates, card_content, f)
    xml.each_element { |e|
      if REXML::Element===xml
        sub_cname = card_name
        if e.name == 'card'
          sub_cname += '+'+e.attribute('name').to_s
          t= e.attribute('transclude') || 'no transclude attribute'
          card_content += "{{#{t}}}"
        else
          #f.write_element(e, card_content)
          e.write(card_content)
        end
        read_xml(e, sub_cname, card_updates, subcontent='', f)
      else
        #f.write_text(e, card_content)
        e.write(card_content)
      end
    }
    #debugger if ENV['RAILS_ENV'] == 'development'
    if xml.name == 'card' 
      card_updates[card_name] = {:content => card_content}
    end
    card_updates
  end

  def put
    #debugger if ENV['RAILS_ENV'] == 'development'
    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      raise("Need a card name to put")
    end
    @card = CachedCard.get(@card_name)

    #raise("PUT #{params.to_yaml}\n")
    doc = REXML::Document.new(request.body)
    #content = request.body.read
    #f = REXML::Formatters::Transitive.new
    if card_updates = read_xml(doc.root, @card_name, Hash.new, '', nil)
      @card.multi_update card_updates     
    end
  end

  def post
    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      raise("Need a card name to post")
    end
    @card = CachedCard.get(@card_name)
    #debugger if ENV['RAILS_ENV'] == 'development'
    if params[:multi_edit]
      @card.multi_update(params[:cards])
    else
      @card.update_attributes! params[:card]     
    end
  end

  def denial
    render :template=>'/card/denied', :status => 403
  end
  
  def delete  
    if params[:card]
      @card.confirm_destroy = params[:card][:confirm_destroy]
    end
    if @card.destroy     
      discard_locations_for(@card)
      render_update_slot do |page,target|
        if @context=="main_1"
          page.wagn.messenger.note "#{@card.name} removed."
          page.redirect_to previous_location
          flash[:notice] =  "#{@card.name} removed"
        else 
          target.replace %{<div class="faint">#{@card.name} was just removed</div>}
          page.wagn.messenger.note( "#{@card.name} removed. ")  
        end
      end
    elsif @card.errors.on(:confirmation_required)
      render_update_slot render_to_string(:partial=>'confirm_remove')
    else
      render_card_errors(@card)
    end
  end

    
    def xml_missing
    load_card
    params[:view] = method
    if id = params[:replace]
      render_update_slot do |page, target|
        target.update render_to_string(:action=>'show')
      end
    else
      render :action=>'show'
    end
  end
end

