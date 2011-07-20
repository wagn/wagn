class Wagn::Renderer
  define_view(:naked , :type=>'set') do
    is_self = card.name.tag_name=='*self'
    headings = ['Type','Content','Action']
    headings.unshift 'Set' if is_self
    
    setting_groups = card.setting_names_by_group
    div( :class=>'instruction' ) do
      "Rules for: "+ 
      if is_self
        link_to_page card.name.trunk_name
      else
        link_to_page Wagn::Pattern.label(card.name), "#{card.name}+by_update"
      end
    end +
    
    content_tag('table', :class=>'set-rules') do
      [:view, :edit, :add].map do |group|
        content_tag(:tr, :class=>"rule-group") do 
          (["#{group.to_s.capitalize} Settings"]+headings).map do |heading|
            content_tag(:th, :class=>'rule-heading') { heading }
          end
        end +
        setting_groups[group].map do |setting_name| 
          rule_card = Card.fetch_or_new "#{card.name}+#{setting_name}", :skip_defaults=>true, :skip_virtual=>true
          content_tag(:tr, :class=>'rule-slot', :position=>generate_position) do
            process_inclusion(rule_card, :view=>:rule)
          end
        end.join
      end.join
    end
  end


  define_view(:editor, :type=>'set') do 
    'Cannot currently edit Sets' #ENGLISH
  end

  alias_view(:closed_content , {:type=>:search}, {:type=>:set})

end
