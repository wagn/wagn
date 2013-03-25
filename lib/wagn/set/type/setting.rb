require_dependency 'json'

module Wagn
  module Set::Type::Setting
    include Sets

    POINTER_KEY = "Pointer"

    SETTING_GROUPS = {
      "Permission"    => [ :create, :read, :update, :delete, :comment ],
      "Look and Feel" => [ :default, :content, :layout, :table_of_contents ],
      "Communication" => [ :add_help, :edit_help, :send, :thanks ],
      POINTER_KEY     => [ :options, :options_label, :input ],
      "Other"         => [ :autoname, :accountable, :captcha ]
    }

    format :base

    define_view :core, :type=>'setting' do |args|
      _render_closed_content(args) +

      Cardlib::Pattern.subclasses.reverse.map do |set_class|
        wql = { :left  => { :type =>Card::SetID },
                :right => card.id,
                :sort  => 'name',
                :limit => 0
              }
        wql[:left][ (set_class.anchorless? ? :id : :right_id )] = set_class.key_id

        search_card = Card.new :type =>Card::SearchTypeID, :content=>wql.to_json
        next if search_card.count == 0

        %{ 
          <div class="set-class set-class-#{set_class.key}">
            <h2>#{ set_class.key_name }</h2>
            #{ subrenderer(search_card)._render_content }
          </div>
        }
      end.compact * "\n"

    end

    define_view :closed_content, :type=>'setting' do |args|
      %{<div class="instruction">#{process_content_object "{{+*right+*edit help}}"}</div>}
    end

  end
end
