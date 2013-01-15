
module Wagn
  module Set::Type::Set
    include Sets

    format :base

    # make these into traits of Setting cards:
    # *content+*group => [[:code]]
    # where below are the codenames and the cardnames (in Wagn seed DB)
    #@@setting_group_title = {
    #  :perms   => 'Permission',
    #  :look    => 'Look and Feel',
    #  :com     => 'Communication',
    #  :other   => 'Other',
    #  :pointer_group => 'Pointer'
    #}
    # should construct this from a search:
    # to  model/settings: Card class method
    def setting_groups
      [:perms, :look, :com, :pointer_group, :other]
    end

    define_view :core , :type=>:set do |args|
      body = card.setting_codes_by_group.map do |group, data|
        next if group.nil? || data.nil?
        content_tag(:tr, :class=>"rule-group") do
          (["#{Card[group].name} Settings"]+%w{Content Type}).map do |heading|
            content_tag(:th, :class=>'rule-heading') { heading }
          end * "\n"
        end +
        raw( data.map do |setting_code|
          rule_card = card.fetch(:trait=>setting_codename, :new=>{})
          process_inclusion rule_card, :view=>:closed_rule
        end * "\n" )
      end.compact * ''

      content_tag('table', :class=>'set-rules') { body }
    end


    define_view :editor, :type=>'set' do |args|
      'Cannot currently edit Sets' #ENGLISH
    end

    alias_view(:closed_content , {:type=>:search_type}, {:type=>:set})


    module Model
      include Wagn::Set::Type::SearchType::Model

      def inheritable?
        return true if junction_only?
        cardname.tag==Cardlib::Patterns::SelfPattern.key_name and cardname.trunk_name.junction?
      end

      def subclass_for_set
        #FIXME - use codename??
        Cardlib::Pattern.subclasses.find do |sub|
          cardname.tag==sub.key_name
        end
      end

      def junction_only?()
        !@junction_only.nil? ? @junction_only :
           @junction_only = subclass_for_set.junction_only
      end

      def reset_set_patterns
        Card.members( key ).each do |mem|
          Card.expire mem
        end
      end

      def label
        if klass = subclass_for_set
          klass.label cardname.left
        else
          ''
        end
      end

      def setting_codes_by_group
        test = Card::PointerID != ( templt = templt = fetch(:trait=>:content) || fetch(:trait=>:default) and
                 templt.type_id or (right_id == Card::TypeID ? left_id : trunk.type_id) )
        Wagn::Set::Type::Setting::SETTING_GROUPS.reject {|k,v| test && k == :pointer_group }
      end

      def prototype
        opts = subclass_for_set.prototype_args(self.cardname.trunk_name)
        Card.fetch_or_new opts[:name], opts
      end

    end
  end
end
