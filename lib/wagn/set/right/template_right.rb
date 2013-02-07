module Wagn
  module Set::Right::TemplateRight

    include Wagn::Sets

    format :base

    define_view  :core, :right=>'content' do |args|
      self._render_raw
      #with_inclusion_mode :template do
      #  self._final_core args
      #end
    end

    alias_view :core, {:right=>'content'}, {:right=>'default'}

    define_view :template_rule, :tags=>:unknown_ok do |args|
      tname = args[:include_name].gsub /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/, ''
      if tname !~ /^\+/
        "{{#{args[:unmask]}}}"
      else
          tmpl_set_name = parent.card.cardname.left_name
          set_name =
          if tmpl_set_class_name = tmpl_set_name.tag_name and Card[tmpl_set_class_name].codename == 'type'
            "#{tmpl_set_name.left_name}#{args[:include_name]}+#{Card[:type_plus_right].name}"
          else
            "#{tname.gsub /^\+/,''}+#{Card[:right].name}"
          end
        "<strong>{{#{args[:unmask]}}} -- #{set_name}</strong>"
      end
    end
  end
end
