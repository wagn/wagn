require 'card_controller' 
require 'rexml/document'

class RestCardController < CardController
  helper :wagn
 
  before_filter :load_card!, :only=> [ :put, :get, :delete ]
 
  before_filter :view_ok,   :only=> [ :get, :put ]
  #before_filter :create_ok, :only=> [ :post ]
  before_filter :edit_ok,   :only=> [ :put ]
  before_filter :remove_ok, :only=> [ :delete ]          
 
    
  def method
    method = request.method
    warn "method #{method}"
    if REST_METHODS.member?(method)
      self.send(method)
    else
      raise("Not a REST method #{method}")
    end
  end
  
  alias :get :show
 
  # rest XML put/post
  # Need to split off envelope code somehome
  def read_xml(xml, updates)
    warn "read_xml(#{xml.class}, #{xml.to_a.inspect}, #{updates.inspect})"
    if REXML::Element === xml and xml.name == 'name'
      card_name = xml.attribute('name').to_s
      card_type = xml.attribute('type').to_s
    #out_xml = REXML::Document.new('')
    #out_xml = out_xml.add_element('e')
    #warn "out_xml is #{out_xml.inspect}"
    #no_card = false
    #if (root_card=card_name.nil?) or card_name.empty?
      #card_name = @card_name = xml.attribute('name').to_s
      #card_type = xml.attribute('type').to_s
      #warn "root: #{root_card.inspect}, #{card_name.inspect}, #{card_type.inspect}"
    #end
    #raise("No xml?, #{card_name}") unless xml
    #warn "xml size #{xml.to_a.size}"
      REXML::XPath.each(xml, '*/card') do |x|
        warn "search node: #{x.inspect}, #{x.to_a.inspect}"
      end
    else
      warn "Not a card: #{xml.class}"
    end
  end
=begin
    xml.each do |el|
      warn "each #{el.class}"
      if REXML::Element===el
        warn "each el #{el.name}: #{el.inspect}"
        if el.name == 'card'
          sub_cname = card_name+'+'+el.attribute('name').to_s
          sub_type = el.attribute('type').to_s
          warn "card element #{el.inspect}, #{sub_cname}, #{sub_type}"
          read_xml(el, updates)
        else
          el.name == 'no_card' && no_card=true
          out_xml.add_element(REXML::Element.new(el.expanded_name), el.attributes)
          read_xml(el, card_name, updates)
        end
      else
        warn "each text #{el}"
        out_xml.add(el.clone)
    #warn "out_xml add text #{out_xml.inspect}"
      end
      warn "loop?>"
    end
    warn "out_xml after #{out_xml.to_a.inspect}"
    card_content = out_xml.to_a[3..-5]
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
    warn (Rails.logger.info "XML post card: #{this_update.inspect} C:#{card_content}")
    if root_card
      raise "Bad element #{xml.name}" unless xml.name == 'card'
      updates.merge!(this_update)
      updates[:type]=card_type if card_type
    else
      updates[card_name] = this_update
    end
    #Rails.logger.info "updates: #{card_content} #{updates.inspect}"
    card_content
=end

  def put
    @card_name = Cardname.unescape(params['id'] || '')
    raise("Need a card name to put") if (@card_name.nil? or @card_name.empty?)
    @card = Card.fetch(@card_name)

    #raise("PUT #{params.to_yaml}\n")
    content = request.body.read
    doc = REXML::Document.new(content)
    raise "XML error: #{doc} #{content}" unless doc.root
    #f = REXML::Formatters::Transitive.new
    warn "doc.root #{doc.root.inspect}"
    read_xml(doc.root, card_updates={})
    if !card_updates.empty?
      Card.update(@card.id, card_updates)
      #@card.multi_save card_updates 
    end
  end
  
  def post
    request.format = :xml if !params[:format]
    warn (Rails.logger.debug "POST(rest)[#{params.inspect}] #{request.format}")
    #return render(:action=>"missing", :format=>:xml)  unless params[:card]
=begin
    respond_to do |format|
      format.xml do
    Rails.logger.debug "POST(xml)[#{params.inspect}] #{request.format}"
=end
        content = request.body.read
        #warn "content is #{content}"
        doc = REXML::Document.new(content)
        raise "XML error: #{doc} #{content}" unless doc.root
        warn "doc.root (post) #{doc.inspect}"
      begin
        read_xml(doc, card_create={})
      rescue Exception => e
        warn "except #{e.inspect}, #{e.backtrace*"\n"}"
      end
        #card_create.delete(:name) if card_create[:name].nil?
        #Rails.logger.debug "postb #{@card&&@card.name}:: #{card_create.inspect}"; @card
        warn "card_create content is #{card_create.inspect}"
        @card = Card.new card_create 
    if @card.save
      render_success
    else
      render_errors      
    end
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

  end
  
  def delete
    @card = @card.refresh if @card.frozen?
    warn "delete #{@card}, #{params.inspect}"
    @card.destroy

    if @card.errors.on(:confirmation_required)
      return render_update_slot( render_to_string(:partial=>'confirm_remove'))
    end
  end
end 
