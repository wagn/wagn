class Wagn::Renderer
  define_view(:naked , :type=>'set') do
    is_self = card.name.tag_name=='*self'
    #headings = ['Type','Content','Action']
    headings = ['Content','Type']
    headings << 'Set' if is_self    
    
    setting_groups = card.setting_names_by_group
    content_tag('table', :class=>'set-rules') do
      content_tag(:tr, :class=>'set-header') do
        content_tag(:th, :colspan=>(headings.size+1)) do
          count = card.count
          span(:class=>'set-label') { Wagn::Pattern.label(card.name) } +
          span(:class=>'set-count') do
            ' (' + (count == 1 ? link_to_page('1', card.item_names.first) : count.to_s) + ') '
          end + "\n" +
          (count<2 ? '' : span(:class=>'set-links') do
            ' list by: ' + ([:name, :create, :update].map do |attrib|
              link_to_page attrib.to_s, "#{card.name}+by_#{attrib}"
            end.join "\n")
          end)
        end 
      end +
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
