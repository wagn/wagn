class Wagn::Renderer::RichHtml
  define_view(:rule) do
    set_name = card.name.trunk_name
    setting_name = card.name.tag_name
    
    is_self = set_name.tag_name =='*self'
    rule_card = if is_self
      c = Card[set_name.trunk_name].setting_card(setting_name)
      c.after_fetch if c
      c
    else
      card.new_card? ? nil : card 
    end
      
    cells = [
      ["rule-setting", link_to_page(setting_name) ],
      ["rule-type", (rule_card ? rule_card.typename : '') ],
      ["rule-content", begin
        div(:class=>'rule-content-container') do
          span(:class=>'line') do
            # these two extra layers are all about getting overflow:hidden to work right.
            # was unable to do it without inline inside block inside table-cell.  would be happy to simplify if possible
            case
            when !rule_card; ''
            when is_self && card != rule_card
              subrenderer(rule_card).render_closed_content
            else; render_closed_content
            end
          end
        end
      end ],
      ["rule-action", link_to_remote( rule_card ? 'edit' : 'add',
        :url=>"/card/view/#{card.name.to_url_key}?view=edit_rule", :update=>id
      )]
    ]
    if is_self
      cells.insert 1, ['rule-set', rule_card ? Wagn::Pattern.label(rule_card.name.trunk_name) : ''] 
    end

    extra_css_class = rule_card && !rule_card.new_card? ? 'known-rule' : 'missing-rule'
    cells.map do |css_class, content|
      content_tag('td', :class=>"#{css_class} #{extra_css_class}") { content }
    end.join "\n"
  end
  
  define_view(:edit_rule) do
    main_set_name = card.name.trunk_name
    set_class = main_set_name.tag_name
    setting_name = card.name.tag_name  
    is_self = set_class =='*self'
    col_count = is_self ? 5 : 4
        
    content_tag(:td, :class=>'edit-rule', :colspan=>col_count-1) do
      div(:class=>'rule-setting') { link_to_page setting_name } +
      div(:class=>'edit-rule-content') do 
        if is_self
          ruled_card = Card[main_set_name.trunk_name]
          current_rule = ruled_card.setting_card(setting_name)
          current_rule.after_fetch if current_rule
          current_rule_set = current_rule ? current_rule.name.trunk_name : nil
          
          mode, sifter = :override, {:override => [], :defer=>[]}
          Wagn::Pattern.set_names(ruled_card).each do |set_name|
            if [current_rule_set, params[:new_rule_set]].member? set_name
              mode = :defer
            else
              sifter[mode] << set_name
            end
          end
          
          sections = []
          sections << if !sifter[:override].empty?
            div(:class=>'edit-rule-section edit-rule-override') do
              if current_rule || params[:new_rule_set]
                edit_rule_header('Override', 'add more specific rule that impacts:')
              else
                edit_rule_header('Create', 'add new rule that impacts:')
              end +
              content_tag(:ul) do
                sifter[:override].map do |set_name|
                  content_tag(:li) { link_to_remote Wagn::Pattern.label(set_name), :update=>id, 
                    :url=>"/card/view/#{card.name.to_url_key}?view=edit_rule&new_rule_set=#{CGI.escape(set_name)}"
                  }
                end.join
              end
            end
          end
          
          sections << if set_name = params[:new_rule_set]
            div(:class=>'edit-rule-section edit-rule-new') do
              edit_rule_header('Create', "add new rule that impacts #{Wagn::Pattern.label(set_name)}") +
              process_inclusion(Card.new(:name=>"#{set_name}+#{setting_name}"), :view=>:open)
            end
          end
          
          sections << if current_rule
            div(:class=>'edit-rule-section edit-rule-current') do
              edit_rule_header('Edit', 'change current rule') +
              process_inclusion(current_rule, :view=>:open)
            end
          end
          
          deferrable_rules = sifter[:defer].map{ |set_name| Card["#{set_name}+#{setting_name}"] }.compact
          sections << if !deferrable_rules.empty?
            div(:class=>'edit-rule-section edit-rule-defer') do
              edit_rule_header('Defer','delete current rule, fall back on more general') +
              deferrable_rules.map do |rule_card|
                process_inclusion rule_card, :view=>:closed
              end.join
            end
          end
#          sifter[:defer].inspect
            
          sections.compact.join "\n"
          
#          "card name = #{card.name}, set_name = #{main_set_name}; setting_name = #{setting_name}, ruled card name = #{ruled_card.name}"
        else
          process_inclusion(card, :view=>:open)
        end
      end
    end +
    content_tag(:td, :class => 'rule-action') do
      div() { link_to_remote 'close', :url=>"/card/view/#{card.name.to_url_key}?view=rule", :update=>id } +
      div() { link_to_remote 'refresh', :url=>"/card/view/#{card.name.to_url_key}?view=edit_rule", :update=>id }
    end 
    
  end
  
  def edit_rule_header(title, intro)
    div(:class=>'edit-rule-header') do
      span(:class=>'edit-rule-header-title') { title } +
      span(:class=>'edit-rule-header-intro') { intro }
    end
  end
  
end