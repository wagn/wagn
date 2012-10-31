
module Wagn::Set::Type::Set
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

  include Wagn::Set::Type::SearchType

  def inheritable?
    return true if junction_only?
    cardname.junction?
  end

  def subclass_for_set
    #FIXME - use codename??
    Wagn::Model::Pattern.subclasses.find do |sub|
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

  def prototype
    opts = subclass_for_set.prototype_args(self.cardname.trunk_name)
    Card.fetch_or_new opts[:name], opts
  end

end
