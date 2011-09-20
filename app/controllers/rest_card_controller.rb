require 'card_controller' 
require 'rexml/document'

class RestCardController < CardController
  helper :wagn, :card
 
  before_filter :load_card!, :only=> [ :put, :get ]
  before_filter :load_card_with_cache, :only => [:get]
 
  before_filter :view_ok,   :only=> [ :get, :put, :delete ]
  #before_filter :create_ok, :only=> [ :post ]
  before_filter :edit_ok,   :only=> [ :put ]
  before_filter :remove_ok, :only=> [ :delete ]          
 
    
  def method
    method = request.method
    if REST_METHODS.member?(method)
      self.send(method)
    else
      raise("Not a REST method #{method}")
    end
  end
  
  alias :get :show
 
  # rest XML put/post
  # Need to split off envelope code somehome
  def read_xml(xml, card_name, updates)
    out_xml = REXML::Document.new('')
    out_xml = out_xml.add_element('e')
    no_card = false
    if (root_card=card_name.nil?) or card_name.empty?
      card_name = @card_name = xml.attribute('name').to_s
      card_type = xml.attribute('type').to_s
    end
    raise("No xml?, #{card_name}") unless xml
    xml.each_child do |e|
      if REXML::Element===e
        if e.name == 'card'
          sub_cname = card_name+'+'+e.attribute('name').to_s
          sub_type = e.attribute('type').to_s
          read_xml(e, sub_cname, updates)
        else
          e.name == 'no_card' && no_card=true
          out_xml.add_element(REXML::Element.new(e.expanded_name), e.attributes)
        end
      else
        out_xml.add(e)
      end
    end
    card_content = out_xml.to_s[3..-5]
    this_update = {:name=>nil, :type=>this_type = xml.attribute('type').to_s}
    unless card_name.blank?
      this_update = {:name=>card_name} unless card_name.blank?
      this_card = Card.fetch_or_new(card_name)
      this_update.delete(:type) unless this_type != this_card.typename
    # no card and no new content, don't update
    #Rails.logger.info "uptest[#{root_card}} #{no_card || this_card.new_record? && card_content.blank?}"
      if !(no_card || this_card.new_record? &&
           card_content.blank?) && card_content != this_card.content
        this_update[:content] = card_content
      end
    end
    #Rails.logger.info "XML post card: #{this_update.inspect} C:#{card_content}"
    if root_card
      raise "Bad element #{xml.name}" unless xml.name == 'card'
      updates.merge!(this_update)
      updates[:type]=card_type if card_type
    else
      updates[card_name] = this_update
    end
    #Rails.logger.info "updates: #{card_content} #{updates.inspect}"
    card_content
  end

  def put
    @card_name = Cardname.unescape(params['id'] || '')
    raise("Need a card name to put") if (@card_name.nil? or @card_name.empty?)
    @card = Card.fetch(@card_name)

    #raise("PUT #{params.to_yaml}\n")
    content = request.body.read
    doc = REXML::Document.new(content)
    raise "XML error: #{doc} #{content}" unless doc.root
    #f = REXML::Formatters::Transitive.new
    read_xml(doc.root, @card_name, card_updates={})
    if !card_updates.empty?
      Card.update(@card.id, card_updates)
      #@card.multi_save card_updates 
    end
  end
  
  def post
    request.format = :xml if !params[:format]
    #Rails.logger.debug "POST(rest)[#{params.inspect}] #{request.format}"
    #return render(:action=>"missing", :format=>:xml)  unless params[:card]
=begin
    respond_to do |format|
      format.xml do
    Rails.logger.debug "POST(xml)[#{params.inspect}] #{request.format}"
=end
        content = request.body.read
        doc = REXML::Document.new(content)
        raise "XML error: #{doc} #{content}" unless doc.root
        read_xml(doc.root, @card_name, card_create={})
        #card_create.delete(:name) if card_create[:name].nil?
        #Rails.logger.debug "postb #{@card&&@card.name}:: #{card_create.inspect}"; @card
        @card = Card.create card_create 
        #Rails.logger.debug "posta #{@card&&@card.name}"; @card
=begin
      end
      format.html do
    Rails.logger.debug "POST(html)[#{params.inspect}] #{request.format}"
        @card_name = Cardname.unescape(params['id'] || '')
        if card_create = params[:card]
          params[:multi_edit] and card_create[:cards] = params[:cards]
          @card = Card.create card_create
        else
          raise "No card parameters on create"
        end
      end
    end
=end

    # according to rails / prototype docs:
    # :success: [...] the HTTP status code is in the 2XX range.
    # :failure: [...] the HTTP status code is not in the 2XX range.

    # however on 302 ie6 does not update the :failure area, rather it sets the :success area to blank..
    # for now, to get the redirect notice to go in the failure slot where we want it,
    # we've chosen to render with the (418) 'teapot' failure status:
    # http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
    if @card
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
  end
  
  #----------------( creating)
  def delete  
    @card.destroy

    if @card.errors.on(:confirmation_required)
      return render_update_slot( render_to_string(:partial=>'confirm_remove'))
    end
  end
end 
