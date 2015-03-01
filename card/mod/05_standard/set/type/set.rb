
format :html do

  view :core do |args|
    body = card.setting_codenames_by_group.map do |group, data|
      next if group.nil? || data.nil?
      group_name = Card::Setting.group_names[group] || group.to_s
      content_tag(:tr, :class=>"rule-group") do
        (["#{group_name} Rules"]+%w{Content Set}).map do |heading|
          content_tag(:th, :class=>'rule-heading') { heading }
        end * "\n"
      end +
      raw( data.map do |setting|
        rule_card = card.fetch(:trait=>setting, :new=>{})
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
      link = view_link args[:inc_syntax], :template_editor, :class=>'slotter' #, 'slot-include'=>include_syntax
      "{{#{link}}}"
    end
  end
  
  view :template_closer do |args|
    view_link '', :template_link, :class=>'slotter glyphicon glyphicon-remove template-editor-close'
  end
  
  view :template_editor do |args|
    wrap args do
      %{
        <div class="template-editor-left">{{</div> 
        <div class="template-editor-main">
          #{ render_template_editor_frame args }
        </div>
        <div class="template-editor-right">}}</div> 
      }
    end
  end
  
  view :template_editor_frame do |args|
    frame :no_slot=>true, :title=>card.label, :menu_hack=>:template_closer do
      _render_core args.merge(:unlabeled=>true)
    end
  end
  
  view :closed_content do |args|
    ''
  end
  
end


include Card::Set::Type::SearchType

def followed_by? user_id = nil
  all_members_followed_by? user_id
end


def default_follow_set_card
  self
end

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

def follow_label
  if klass = subclass_for_set
    klass.follow_label cardname.left
  else
    ''
  end
end

def follow_rule_name user=nil
  if user
    if user.kind_of? String
      "#{name}+#{user}+#{Card[:follow].name}"
    else
      "#{name}+#{user.name}+#{Card[:follow].name}"
    end
  else
    "#{name}+#{Card[:all].name}+#{Card[:follow].name}"
  end
end

# def to_following_item_name args
#   left_part = follow_rule_name( args[:user] )
#   option = args[:option] || if (rule_card = Card.fetch(left_part))
#        rule_card.content
#      else
#        Card[:nothing].name
#      end
#
#   "#{left_part}+#{option}"
# end

def all_user_ids_with_rule_for setting_code
  Card.all_user_ids_with_rule_for self, setting_code
end


def setting_codenames_by_group
  result = {}
  Card::Setting.groups.each do |group, settings| 
    visible_settings = settings.reject { |s| !s or !s.applies_to_cardtype(prototype.type_id) }
    unless visible_settings.empty?
      result[group] = visible_settings.map { |s| s.codename }
    end
  end
  result
end

def all_members_followed? 
  all_members_followed_by? Auth.current_id
end

def all_members_followed_by? user_id = nil
  if !prototype.followed_by? user_id  
    return false
  elsif set_followed_by? user_id
    return true
  else
    broader_sets.each do |b_s|
      if (set_card  = Card.fetch(b_s)) && set_card.set_followed_by?(user_id)
       return true
      end
    end
  end
  return false
end

def set_followed?
  set_followed_by? Auth.current_id
end

def set_followed_by? user_id = nil
  return  ( user_id && (user = Card.find(user_id)) && Card.fetch(follow_rule_name(user.name)) ) || 
          Card.fetch(follow_rule_name)
end

def broader_sets
  prototype.set_names[1..-1]
end


def prototype
  opts = subclass_for_set.prototype_args self.cardname.trunk_name
  Card.fetch opts[:name], :new=>opts
end
