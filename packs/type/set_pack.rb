class Wagn::Renderer
  define_view(:naked , :type=>'set') do

    headings = ['Type','Content']
    headings.unshift 'Set' if card.name.tag_name=='*self'
    
    setting_groups = card.setting_names_by_group
    div( :class=>'instruction' ) do
      Wagn::Pattern.label card.name
    end +
    
    div(:class=>'set-rules') do
      [:viewing, :editing, :creating].map do |group|
        div(:class=>"rule-group") do 
          (["#{group.to_s.capitalize} Setting"]+headings).map do |heading|
            div(:class=>'rule-heading') { heading }
          end
        end +
        setting_groups[group].map do |setting_name| 
          rule_card = Card.fetch_or_new "#{card.name}+#{setting_name}", :skip_defaults=>true, :skip_virtual=>true
          process_inclusion(rule_card, :view=>:rule)
        end.join
      end.join
    end
  end


  define_view(:editor, :type=>'set') do 
    'Cannot currently edit Sets' #ENGLISH
  end

  alias_view(:closed_content , {:type=>:search}, {:type=>:set})

end
