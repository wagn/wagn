class Wagn::Renderer
  @@setting_group_title = {
    :perms   => 'Permission',
    :look    => 'Look and Feel',
    :com     => 'Communication',
    :other   => 'Other',
    :pointer => 'Pointer'
  }

  define_view :core , :type=>:set do |args|
    headings = ['Content','Type']
    setting_groups = card.setting_names_by_group

    body = [:perms, :look, :com, :pointer, :other].map do |group|

      next unless setting_groups[group]
      content_tag(:tr, :class=>"rule-group") do
        (["#{@@setting_group_title[group.to_sym]} Settings"]+headings).map do |heading|
          content_tag(:th, :class=>'rule-heading') { heading }
        end.join("\n")
      end +
      raw( setting_groups[group].map do |setting_code|
        setting_name = (setting_card=Card[setting_code]).nil? ? "no setting ?" : setting_card.name
        rule_card = card.trait_card(setting_code)
        process_inclusion(rule_card, :view=>:closed_rule)
      end.join("\n"))
    end.compact.join

    content_tag('table', :class=>'set-rules') { body }

  end


  define_view :editor, :type=>'set' do |args|
    'Cannot currently edit Sets' #ENGLISH
  end

  alias_view(:closed_content , {:type=>:search_type}, {:type=>:set})

end
