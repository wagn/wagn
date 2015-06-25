
format :html do

  view :core do |args|
    if Card[:recent_settings].item_names.present?
      _render_recent_rules(args)
    else
      _render_common_rules(args)
    end
  end

  def with_label_and_navbar args
    wrap do
      [
        _optional_render(:set_label, args, :show),
        _optional_render(:rule_navbar, args, :show),
        yield
      ]
    end
  end

  view :all_rules do |args|
    with_label_and_navbar args.merge(:active_toolbar_view =>:all_rules) do
      rules_table (card.visible_setting_codenames.sort & card.visible_setting_codenames), args
    end
  end

  view :grouped_rules do |args|
    with_label_and_navbar args.merge(:active_toolbar_view =>:grouped_rules) do
      content_tag(:div, :class=>'panel-group', :id=>'accordion', :role=>'tablist','aria-multiselectable'=>'true') do
         Card::Setting.groups.keys.map do |group_key|
           _optional_render(group_key, args, :show)
         end * "\n"
      end
    end
  end

  view :recent_rules do |args|
    with_label_and_navbar args.merge(:active_toolbar_view =>:recent_rules) do
      recent_settings = Card[:recent_settings].item_cards.map(&:codename)
      rules_table (recent_settings.map(&:to_sym) & card.visible_setting_codenames), args
    end

  end

  view :common_rules do |args|
    with_label_and_navbar args.merge(:active_toolbar_view =>:common_rules) do
      rules_table (card.visible_setting_codenames & [:create, :read, :update, :delete, :structure, :default, :style]), args
    end
  end

  view :field_related_rules do |args|
    with_label_and_navbar args.merge(:active_toolbar_view =>:field_related_rules) do
      rules_table (card.visible_setting_codenames & [:default, :help, :add_help, :input, :options, :options_label]), args
    end
  end

  view :set_label do |args|
    content_tag :h2, card.label, :class=>'set-label'
  end

  Card::Setting.groups.keys.each do |group_key|
    view group_key.to_sym do |args|
      settings = card.visible_settings group_key
      if settings.present?
        group_name =  Card::Setting.group_names[group_key] || group.to_s
        heading_id = "heading-#{group_key}"
        collapse_id = "collapse-#{card.cardname.safe_key}-#{group_key}"
        output [
          (content_tag :div, :class=>'panel panel-default' do
            content_tag :div, :class=>'panel-heading', :role=>'tab', :id=>heading_id do
              content_tag :h4, :class=>'panel-title' do
                content_tag :a, group_name, 'data-toggle'=>'collapse', 'data-parent'=>'#accordion', :href=>"##{collapse_id}", 'aria-expanded'=>'false', 'aria-controls'=>collapse_id
              end
            end
          end),
          (content_tag :div, :id=>collapse_id, :class=>'panel-collapse collapse', :role=>'tabpanel', 'aria-labelledby'=>heading_id do
            rules_table settings.map(&:codename), args
          end)
        ]
      end
    end
  end

  def rules_table settings, args={}
    wrap_with :table, :class=>'set-rules table' do
      [
        (content_tag(:tr, :class=>"rule-group") do
          wrap_each_with :th, %w(Setting Content Set), :class=>'rule-heading'
        end),
        (settings.map do |setting|
          if show_view? setting, args
            rule_card = card.fetch(:trait=>setting, :new=>{})
            nest(rule_card, :view=>:closed_rule).html_safe
          end
        end * "\n")
      ]
    end
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
      _render_core args.merge(:hide=>'set_label')
    end
  end

  view :closed_content do |args|
    ''
  end


  view :rule_navbar do |args|
    id = "rule-navbar-#{card.cardname.safe_key}-#{args[:home_view]}"

    navbar id, :toggle=>'Rules<span class="caret"></span>', :toggle_align=>:left,
               :class=>'slotter toolbar', :navbar_type=>'inverse', :collapsed_content=>close_link('pull-right visible-xs') do
      [
        content_tag(:span, 'Rules:', :class=>"navbar-text hidden-xs"),
        (wrap_with :ul, :class=>'nav navbar-nav nav-pills' do
          [
            pill_view_link( 'most common', :common_rules, args),
            pill_view_link( 'recently edited', :recent_rules, args),
            pill_view_link( 'grouped', :grouped_rules, args),
            pill_view_link( 'alphabetical', :all_rules, args),
            pill_view_link( 'field-related', :field_related_rules, args)
          ]
        end),
      ]
    end
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

def visible_setting_codenames
  @visible_settings ||=
    Card::Setting.groups.values.flatten.compact.reject do |setting|
      !setting.applies_to_cardtype(prototype.type_id)
    end.map(&:codename)
end

def visible_settings group
  Card::Setting.groups[group].reject do |setting|
    !setting or !setting.applies_to_cardtype(prototype.type_id)
  end
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
