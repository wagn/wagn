class Wagn::Renderer::RichHtml

  define_view(:closed_rule) do |args|
    rule_card, set_prototype = find_current_rule_card

    cells = [
      ["rule-setting", 
        link_to( card.cardname.tag_name, "/card/view/#{card.cardname.to_url_key}?view=open_rule", 
          :class => 'edit-rule-link standard-slotter init-editors', :remote => true )
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
      %{<td class="rule-cell #{css_class} #{extra_css_class}">#{content}</td>}
    end.join("\n") +
    '</tr>'
  end
  
  
  
  define_view(:open_rule) do |args|
    current_rule, prototype = find_current_rule_card
    setting_name = card.cardname.tag_name
    current_rule ||= Card.new :name=> "*all+#{setting_name}"
    
    if args=params[:card]
      current_rule = current_rule.refresh if current_rule.frozen?
      args[:typecode] = Cardtype.classname_for(args.delete(:type)) if args[:type]
      current_rule.assign_attributes args
    end
    
    params.delete(:success) if params[:type_reload] #otherwise updating the editor looks like a successful post
    
    opts = {
      :fallback_set    => false, 
      :open_rule       => card,
      :edit_mode       => (card.ok?(card.new_card? ? :create : :update) && !params[:success]),
      :setting_name    => setting_name,
      :current_set_key => (current_rule.new_card? ? nil : current_rule.cardname.trunk_name.key)
    }
    
    if !opts[:read_only]
      set_options = prototype.set_names.reverse
      first = (csk=opts[:current_set_key]) ? set_options.index{|s| s.to_cardname.key == csk} : 0
      if first > 0
        set_options[0..(first-1)].reverse.each do |set_name|
          opts[:fallback_set] = set_name if Card.exists?("#{set_name}+#{opts[:setting_name]}")
        end
      end
      last = set_options.index{|s| s.to_cardname.key == card.cardname.trunk_name.key} or raise("set for #{card.name} not found in prototype set names")
      opts[:set_options] = set_options[first..last]        
      
      # The above is about creating the options for the sets to which the user can apply the rule.
      # The broadest set should always be the currently applied rule 
      # (for anything more general, they must explicitly choose to "DELETE" the current one)
      # the narrowest rule should be the one attached to the set being viewed.  So, eg, if you're looking at the "*all plus" set, you shouldn't
      # have the option to create rules based on arbitrary narrower sets, though narrower sets will always apply to whatever prototype we create
    end
      

    %{
      <tr class="card-slot open-rule">
        <td class="rule-cell" colspan="3">        
          #{subrenderer( current_rule ).render_view_action('edit_rule', opts )}
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
