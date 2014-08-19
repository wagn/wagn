
format :html do

  view :core do |args|
    body = card.setting_codes_by_group.map do |group, data|
      next if group.nil? || data.nil?
      group_name = Card::Set::Type::Setting::SETTING_GROUP_NAMES[group] || group.to_s
      content_tag(:tr, :class=>"rule-group") do
        (["#{group_name} Rules"]+%w{Content Set}).map do |heading|
          content_tag(:th, :class=>'rule-heading') { heading }
        end * "\n"
      end +
      raw( data.map do |setting|
        rule_card = card.fetch(:trait=>setting.codename, :new=>{})
        nest rule_card, :view=>:closed_rule
      end * "\n" )
    end.compact * ''
    %{
      #{
        unless args[:unlabeled]
          %{ <h2 class="set-label">#{ card.label }</h2> }
        end
      }
      #{ content_tag('table', :class=>'set-rules') { body } }
    }
  end


  view :editor do |args|
    'Cannot currently edit Sets' #ENGLISH
  end
  
  view :template_link do |args|
    args.delete :style
    wrap args do
      link = link_to_view args[:inc_syntax], :template_editor, :class=>'slotter' #, 'slot-include'=>include_syntax
      "{{#{link}}}"
    end
  end
  
  view :template_closer do |args|
    link_to_view '', :template_link, :class=>'slotter ui-icon ui-icon-closethick template-editor-close'
  end
  
  view :template_editor do |args|
    wrap args do
      %{
        <div class="template-editor-left">{{</div> 
        <div class="template-editor-main">
          #{
            frame :no_slot=>true, :title=>card.label, :optional_menu_view=>:template_closer do
              _render_core args.merge(:unlabeled=>true)
            end
          }
        </div>
        <div class="template-editor-right">}}</div> 
      }
    end
  end

  view :closed_content do |args|
    ''
  end
end


include Card::Set::Type::SearchType

def inheritable?
  return true if junction_only?
  cardname.trunk_name.junction? and cardname.tag_name.key == Card::SelfSet.pattern.key
end

def subclass_for_set
  set_class_key = tag.codename
  Card.set_patterns.find do |sub|
    cardname.tag_name.key == sub.pattern.key
  end
end

def junction_only?()
  if @junction_only.nil?
    @junction_only = subclass_for_set.junction_only
  else
    @junction_only
  end
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

require 'byebug'

def setting_codes_by_group
  result = {}
  byebug
  Card::Set::Type::Setting.setting_groups.each do |group, settings| 
    visible_settings = settings.keep_if { |s| s and !s.invisible_for.include?(prototype.type_id) }
    unless visible_settings.empty?
      result[group] = visible_settings
    end
  end
  result
end

def prototype
  opts = subclass_for_set.prototype_args self.cardname.trunk_name
  Card.fetch opts[:name], :new=>opts
end
