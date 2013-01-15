require_dependency 'json'

module Wagn
  module Set::SettingGroups
    include Sets

    format :base

    define_view( :name, :name => :perms )         do "Permission"     end
    define_view( :name, :name => :look )          do "Look and Feel"  end
    define_view( :name, :name => :com )           do "Communication"  end
    define_view( :name, :name => :other )         do "Other"          end
    define_view( :name, :name => :pointer_group ) do "Item Selection" end
  end

  module Set::Type::Setting
    include Sets

    SETTING_GROUPS = {
      :perms         => [ :create, :read, :update, :delete, :comment ],
      :look          => [ :default, :content, :layout, :table_of_contents ],
      :com           => [ :add_help, :edit_help, :send, :thanks ],
      :pointer_group => [ :options, :options_label, :input ],
      :other         => [ :autoname, :accountable, :captcha ]
    }

    DEFAULT_CONFIG = {:seq=>9999}

    format :base

    define_view :core, :type=>'setting' do |args|
      _render_closed_content(args) +

      Cardlib::Pattern.subclasses.reverse.map do |set_class|
        wql = { :left  => {:type =>Card::SetID},
                :right => card.id,
                :sort  => 'name',
                :limit => 100
              }
        wql[:left][ (set_class.trunkless? ? :name : :right )] = set_class.key_name

        search_card = Card.new :type =>Card::SearchTypeID, :content=>wql.to_json
        next if search_card.count == 0

        raw( content_tag( :h2, (set_class.trunkless? ? '' : '+') + set_class.key_name, :class=>'values-for-setting') ) +
        subrenderer(search_card)._render_content
      end.compact * "\n"

    end

    define_view :closed_content, :type=>'setting' do |args|
      %{<div class="instruction">#{process_content "{{+*right+*edit help}}"}</div>}
    end

  end
end
