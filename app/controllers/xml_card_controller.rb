require 'card_controller' 

class XmlCardController < CardController
  helper :wagn, :card
 
  EDIT_ACTIONS = [ :put, :post ]
  LOAD_ACTIONS = EDIT_ACTIONS + [ :delete ]
 
  before_filter :load_card!, :only=> LOAD_ACTIONS
  before_filter :load_card_with_cache, :only => [:get]
 
  before_filter :view_ok,   :only=> LOAD_ACTIONS
  before_filter :create_ok, :only=> [ :put, :post ]
  before_filter :edit_ok,   :only=> EDIT_ACTIONS
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
      this_card = Card.fetch(card_name)
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
    @card = Card.fetch(@card_name)

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
  end
  
  #----------------( creating)
  def delete  
    @card.destroy

    if @card.errors.on(:confirmation_required)
      return render_update_slot( render_to_string(:partial=>'confirm_remove'))
    end
  end
end 
