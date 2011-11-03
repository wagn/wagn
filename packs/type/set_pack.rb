class Wagn::Renderer
  define_view(:core , :type=>'set') do |args|
    is_self = card.cardname.tag_name=='*self'
    #headings = ['Type','Content','Action']
    headings = ['Content','Type']
    headings << 'Set' if is_self    
    
    setting_groups = card.setting_names_by_group
    header= content_tag(:tr, :class=>'set-header') do
      content_tag(:th, :colspan=>(headings.size+1)) do
        count = card.count
        span(:class=>'set-label') { card.label } +
        span(:class=>'set-count') do
          ' (' + (count == 1 ? link_to_page('1', card.item_names.first) : count.to_s) + ') '
        end + "\n" +
        (count<2 ? '' : span(:class=>'set-links') do
          raw(
            ' list by: ' + 
            [:name, :create, :update].map do |attrib|
              link_to_page( raw(attrib.to_s), "#{card.name}+by_#{attrib}")
            end.join( "\n" )
          )
        end)
      end 
    end
    body = [:view, :edit, :add].map do |group|
      content_tag(:tr, :class=>"rule-group") do
        raw(
          (["#{group.to_s.capitalize} Settings"]+headings).map do |heading|
            content_tag(:th, :class=>'rule-heading') { heading }
          end.join("\n")
        )
      end +
      raw( setting_groups[group].map do |setting_name| 
        rule_card = Card.fetch_or_new "#{card.name}+#{setting_name}", :skip_virtual=>true
        content_tag(:tr, :class=>'rule-slot', :position=>generate_position) do
          raw process_inclusion(rule_card, :view=>:rule)
        end
      end.join("\n"))
    end.join

    content_tag('table', :class=>'set-rules') { header + raw(body) }
  end


  define_view(:editor, :type=>'set') do |args|
    'Cannot currently edit Sets' #ENGLISH
  end

  alias_view(:closed_content , {:type=>:search}, {:type=>:set})

end
