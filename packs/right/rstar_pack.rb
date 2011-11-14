class Wagn::Renderer::RichHtml

  define_view(:closed_rule) do |args|
    rule_card, set_prototype = find_current_rule_card

    cells = [
      ["rule-setting", 
        link_to( card.cardname.tag_name, "/card/view/#{card.cardname.to_url_key}?view=open_rule", 
          :class => 'edit-rule-link standard-slotter', :remote => true )
      ],
      ["rule-content", begin
        div(:class=>'rule-content-container closed-view') do
          %{ <span class="content">#{rule_card ? subrenderer(rule_card).render_closed_content : ''}</span> }
          # these two extra layers are all about getting overflow:hidden to work right.
          # was unable to do it without inline inside block inside table-cell.  would be happy to simplify if possible
        end
      end ],
      ["rule-type", (rule_card ? rule_card.typename : '') ],
    ]

    extra_css_class = rule_card && !rule_card.new_card? ? 'known-rule' : 'missing-rule'
    
    %{<tr class="card-slot closed-rule">} +
    cells.map do |css_class, content|
      %{<td class="#{css_class} #{extra_css_class}">#{content}</td>}
    end.join("\n") +
    '</tr>'
  end
  
  define_view(:open_rule) do |args|
    setting_name = card.cardname.tag_name
    current_rule_card, prototype = find_current_rule_card #|| "*all+#{setting_name}"
    current_rule_card ||= Card.new
    
    if args=params[:card]
      current_rule_card = current_rule_card.refresh if !current_rule_card.new_card?
      args[:typecode] = Cardtype.classname_for(args.delete(:type)) if args[:type]
      current_rule_card.assign_attributes args
    end
    
    body =       
      if card.ok?(card.new_card? ? :create : :edit)
        set_options = prototype.set_names
        subrenderer( current_rule_card ).render_view_action('edit_rule',
          :main_rule_card => card,
          :set_options    => set_options,
          :setting_name   => setting_name
        )
      else
        #FIXME - need some reasonable content here
        "permissions denied for #{card.name}.  new_card?  #{card.new_card?}"
      end  

    %{
      <tr class="card-slot open-rule">
        <td colspan="3">        
          #{body}
        </td>
      </tr>
    }
    
  end
  

  
  private
  
  def find_current_rule_card
    setting_name = card.cardname.tag_name
    set_card = Card.fetch( card.cardname.trunk_name )
    set_prototype = set_card.prototype
    rule_card = set_card.prototype.setting_card setting_name
    [rule_card, set_prototype]
  end
  
end
