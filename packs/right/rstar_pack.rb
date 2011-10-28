class Wagn::Renderer::RichHtml
  define_view(:rule) do |args|
    set_name = card.cardname.trunk_name
    setting_name = card.cardname.tag_name
    
    is_self = set_name.tag_name =='*self'
    rule_card = if is_self
      c = Card.fetch(set_name.trunk_name)
      return div(){"no such card #{set_name.trunk_name}"} unless c
      c.setting_card(setting_name)
    else
      card.new_card? ? nil : card 
    end
      
    cells = [
#      ["rule-setting", link_to_page(setting_name) ],
      ["rule-setting", link_to( setting_name, 
        "/card/view/#{card.cardname.to_url_key}?view=edit_rule",
        :remote => true
      )],
      ["rule-content", begin
        div(:class=>'rule-content-container line') do
          span(:class=>'content') do
            # these two extra layers are all about getting overflow:hidden to work right.
            # was unable to do it without inline inside block inside table-cell.  would be happy to simplify if possible
            raw(
              case
              when !rule_card; ''
              when is_self && card != rule_card
                subrenderer(rule_card).render_closed_content
              else; render_closed_content
              end
            )
          end
        end
      end ],
      ["rule-type", (rule_card ? rule_card.typename : '') ],
    ]
    if is_self
      cells << ['rule-set', rule_card ? rule_card.trunk.label(rule_card.cardname.trunk_name) : ''] 
    end

    warn "cells = #{cells.inspect}"

    extra_css_class = rule_card && !rule_card.new_card? ? 'known-rule' : 'missing-rule'
    cells.map do |css_class, content|
      raw( content_tag('td', :class=>"#{css_class} #{extra_css_class}") { raw content } )
    end.join "\n"
    
#    raw( cells.join "\n" )
    
  end
  
  define_view(:edit_rule) do |args|
    main_set_name = card.name.trunk_name
    set_class = main_set_name.tag_name
    setting_name = card.name.tag_name  
    is_self = set_class =='*self'
    col_count = is_self ? 5 : 4
        
    content_tag(:td, :class=>'edit-rule', :colspan=>col_count-1) do
#      div(:class=>'rule-setting') { link_to_page setting_name } +
      div(:class=>'rule-setting') do
         link_to setting_name, {:url=>"/card/view/#{card.cardname.to_url_key}?view=rule", :update=>id }, :remote=>true 
      end +
      
      
      div(:class=>'edit-rule-content') do 
        if is_self
          ruled_card = Card[main_set_name.trunk_name]
          current_rule = ruled_card.setting_card(setting_name)
          current_rule_set = current_rule ? current_rule.name.trunk_name.to_key : nil
          
          mode, sifter = :override, {:override => [], :defer=>[]}
          ruled_card.set_names().each do |set_name|
            if [current_rule_set, params[:new_rule_set]].member? set_name.to_key
              mode = :defer
            else
              sifter[mode] << set_name
            end
          end
          
          sections = []
          sections << if !sifter[:override].empty?
            div(:class=>'edit-rule-section edit-rule-override') do
              if current_rule || params[:new_rule_set]
                edit_rule_header('Override', 'add more specific rule for:')
              else
                edit_rule_header('Create', 'add new rule for:')
              end +
              content_tag(:ul) do
                sifter[:override].map do |set_name|
                  content_tag(:li) { link_to ruled_card.label(set_name), 
                    { :update=>id, :url=>"/card/view/#{card.name.to_url_key}?view=edit_rule&new_rule_set=#{CGI.escape(set_name.to_key)}" },
                    :remote=>true
                  }
                end.join
              end
            end
          end
          
          sections << if set_name = params[:new_rule_set]
            div(:class=>'edit-rule-section edit-rule-new') do
              edit_rule_header('Create', "add new rule for #{ruled_card.label(set_name)}:") +
              process_inclusion(Card.new(:name=>"#{set_name}+#{setting_name}"), :view=>:open)
            end
          end
          
          sections << if current_rule
            div(:class=>'edit-rule-section edit-rule-current') do
              edit_rule_header('Edit', "change current rule for #{ruled_card.label(current_rule_set)}:") +
              process_inclusion(current_rule, :view=>:open)
            end
          end
          
          deferrable_rules = sifter[:defer].map{ |set_name| Card["#{set_name}+#{setting_name}"] }.compact
          sections << if !deferrable_rules.empty?
            div(:class=>'edit-rule-section edit-rule-defer') do
              edit_rule_header('Defer','delete current rule (above) in favor of more general rule:') +
              deferrable_rules.map do |rule_card|
                process_inclusion rule_card, :view=>:closed
              end.join
            end
          end
          sections.compact.join "\n"
        else
          process_inclusion(card, :view=>:open)
        end
      end
    end
  end
  
  def edit_rule_header(title, intro)
    div(:class=>'edit-rule-header') do
      span(:class=>'edit-rule-header-title') { title } +
      span(:class=>'edit-rule-header-intro') { intro }
    end
  end
  
end
