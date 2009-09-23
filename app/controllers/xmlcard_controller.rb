require 'rexml/document'

class XmlcardController < ApplicationController
  helper :wagn, :card 

  before_filter :create_ok, :only=>[ :put, :post ]

  before_filter :load_card!, :only=>[ :get, :put, :post ]

  before_filter :load_card_with_cache, :only => [ :get ]
  
  before_filter :edit_ok,   :only=>[ :put, :post ] 
  before_filter :remove_ok, :only=>[ :delete ]

  def help
    Helper.instance
  end
  
  class Helper
    include Singleton
    include WagnHelper
  end

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
      if !Card::Basic.create_ok?
        return render(:action=>'missing')
      else
        return self.post
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
  
  def read_xml(xml, card_name, card_updates, f)
    card_content=''
    no_card=false
    #raise("Should be card, #{card_name}") if xml.name != 'card'
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
    doc = REXML::Document.new(request.body)
    #content = request.body.read
    #f = REXML::Formatters::Transitive.new
    card_updates = Hash.new
    read_xml(doc.root, @card_name, card_updates, nil)
    if !card_updates.empty?
      @card.multi_update card_updates 
    end
  end

  def post
    @card_name = Cardname.unescape(params['id'] || '')
    if (@card_name.nil? or @card_name.empty?) then    
      raise("Need a card name to post")
    end
    @card = CachedCard.get(@card_name)
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
