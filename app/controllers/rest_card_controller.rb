 
# encoding: UTF-8

require 'xmlscan/processor'
require 'card_controller' 

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
 
  def read_xml(io)
    pairs = XMLScan::XMLProcessor.process(io, {:key=>:name, :element=>:card,
      :substitute=>":transclude|{{:name}}", :extras=>[:type]})
    main = pairs.shift
    main, content, type = main[0], main[1][0]*'', main[1][2]
    data = { :name=>main,
      :cards=>pairs.inject({}) { |hash,p| k,v = p
         h = {:content => v[0]*''}
         h[:type] = v[2] if v[2]
         hash[k.to_cardname.to_absolute(v[1])] = h
         hash } }
    data[:content] = content unless content.blank?
    data[:type] = type if type
    data
  end

  def dump_pairs(pairs)
    warn "Result
#{    pairs.map do |p| n,o,c,t = p
      "#{c&&c.size>0&&"#{c}::"||''}#{n}#{t&&"[#{t}]"}=>#{o*''}"
    end * "\n"}
Done"
  end
  # Need to split off envelope code somehome

  def put
    @card_name = Cardname.unescape(params['id'] || '')
    raise("Need a card name to put") if (@card_name.nil? or @card_name.empty?)
    @card = Card.fetch(@card_name)

    #raise("PUT #{params.to_yaml}\n")
    card_updates = xml_read request.body
    if !card_updates.empty?
      Card.update(@card.id, card_updates)
      #@card.multi_save card_updates 
    end
  end
  
  def post
    request.format = :xml if !params[:format]
    #warn (Rails.logger.debug "POST(rest)[#{params.inspect}] #{request.format}")
    #return render(:action=>"missing", :format=>:xml)  unless params[:card]
=begin
    respond_to do |format|
      format.xml do
    Rails.logger.debug "POST(xml)[#{params.inspect}] #{request.format}"
=end
      begin
        card_create = read_xml request.body
        #warn "POST creates are  #{card_create.inspect}"
      rescue Exception => e
        warn "except #{e.inspect}, #{e.backtrace*"\n"}"
      end
        #card_create.delete(:name) if card_create[:name].nil?
        #Rails.logger.debug "postb #{@card&&@card.name}:: #{card_create.inspect}"; @card
        #warn "card_create content is #{card_create.inspect}"
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
