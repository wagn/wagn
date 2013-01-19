
module Wagn
  module Set::Type
   module Set
    include Sets

    format :base

    define_view :core , :type=>:set do |args|
      body = card.setting_codes_by_group.map do |group_name, data|
        next if group_name.nil? || data.nil?
        content_tag(:tr, :class=>"rule-group") do
          (["#{group_name} Settings"]+%w{Content Type}).map do |heading|
            content_tag(:th, :class=>'rule-heading') { heading }
          end * "\n"
        end +
        raw( data.map do |setting_code|
          rule_card = card.fetch(:trait=>setting_code, :new=>{})
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
      include SearchType::Model

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
        is_pointer = Card::PointerID == (
          if templt = fetch(:trait=>:content) || fetch(:trait=>:default)
            templt.type_id
          elsif right_id == Card::TypeID
            left_id
          else
            trunk(:new=>{}).type_id
          end
        )
        Setting::SETTING_GROUPS.reject { |k,v| !is_pointer && k == Setting::POINTER_KEY }
      end

      def prototype
        opts = subclass_for_set.prototype_args(self.cardname.trunk_name)
        Card.fetch opts[:name], :new=>opts
      end

    end
   end
  end
end
