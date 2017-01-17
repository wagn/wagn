
include_set Type::SearchType

format :html do
  COMMON_RULE_SETTINGS =
    [:create, :read, :update, :delete, :structure, :default, :style].freeze

  view :core, cache: :never do |args|
    voo.show :set_label, :rule_navbar
    voo.hide :set_navbar
    rule_view = params[:rule_view] || :common_rules
    _render rule_view
  end

  def with_label_and_navbars selected_view
    @selected_rule_navbar_view = selected_view
    wrap do
      [
        _optional_render_set_label,
        _optional_render_rule_navbar,
        _optional_render_set_navbar,
        yield
      ]
    end
  end

  view :all_rules do
    with_label_and_navbars :all_rules do
      rules_table card.visible_setting_codenames.sort
    end
  end

  view :grouped_rules do
    with_label_and_navbars :grouped_rules do
      wrap_with :div, class: "panel-group", id: "accordion",
                      role: "tablist", "aria-multiselectable" => "true" do
        Card::Setting.groups.keys.map do |group_key|
          _optional_render group_key
        end
      end
    end
  end

  view :recent_rules do
    with_label_and_navbars :recent_rules do
      recent_settings = Card[:recent_settings].item_cards.map(&:codename)
      settings = recent_settings.map(&:to_sym) & card.visible_setting_codenames
      rules_table settings
    end
  end

  view :common_rules do
    with_label_and_navbars :common_rules do
      settings = card.visible_setting_codenames & COMMON_RULE_SETTINGS
      # "&" = set intersection
      rules_table settings
    end
  end

  view :field_related_rules do
    with_label_and_navbars :field_related_rules do
      field_settings = [:default, :help, :structure]
      if card.type_id == PointerID
        # FIXME: should be done with override in pointer set module
        field_settings += [:input, :options, :options_label]
      end
      settings = card.visible_setting_codenames & field_settings
      rules_table settings
    end
  end

  view :set_label do
    wrap_with :h3, card.label, class: "set-label"
  end

  Card::Setting.groups.keys.each do |group_key|
    view group_key.to_sym do
      settings = card.visible_settings group_key
      return unless settings.present?
      group_panels group_key
    end
  end

  def group_panels group_key
    output [group_tab(group_key), group_tabpanel(group_key)]
  end

  def group_tab group_key
    heading_id = "heading-#{group_key}"
    wrap_with :div, class: "panel panel-default" do
      wrap_with :div, class: "panel-heading", role: "tab", id: heading_id do
        wrap_with :h4, class: "panel-title" do
          group_collapse_link group_key
        end
      end
    end
  end

  def group_collapse_link group_key
    collapse_id = group_collapse_id group_key
    group_name = Card::Setting.group_names[group_key] || group_key.to_s
    link_to group_name,
            href: "##{collapse_id}",
            "data-toggle" => "collapse",   "aria-expanded" => "false",
            "data-parent" => "#accordion", "aria-controls" => collapse_id
  end

  def group_collapse_id group_key
    "collapse-#{card.cardname.safe_key}-#{group_key}"
  end

  def group_tabpanel group_key
    collapse_id = group_collapse_id group_key
    heading_id =  "heading-#{group_key}"
    settings = card.visible_settings group_key
    wrap_with :div, id: collapse_id, class: "panel-collapse collapse",
                    role: "tabpanel", "aria-labelledby" => heading_id do
      rules_table settings.map(&:codename)
    end
  end

  def rules_table settings
    wrap_with :table, class: "set-rules table" do
      [rules_table_headings, rules_table_body(settings)]
    end
  end

  def rules_table_headings
    wrap_with :tr, class: "rule-group" do
      wrap_each_with :th, %w(Trait Content Set), class: "rule-heading"
    end
  end

  def rules_table_body settings
    settings.map do |setting|
      next unless show_view? setting
      rule_card = card.fetch trait: setting, new: {}
      nest(rule_card, view: :closed_rule).html_safe
    end * "\n"
  end

  view :editor do
    "Cannot currently edit Sets" # ENGLISH
  end

  view :template_link, cache: :never do
    wrap do
      link = link_to_view :template_editor, parent.voo.nest_syntax,
                          class: "slotter"
      "{{#{link}}}"
    end
  end

  view :template_closer do
    link_classes = "slotter glyphicon glyphicon-remove template-editor-close"
    link_to_view :template_link, "", class: link_classes
  end

  view :template_editor do
    wrap do
      [
        wrap_with(:div, "{{", class: "template-editor-left"),
        wrap_with(:div, class: "template-editor-main") do
          render_template_editor_frame
        end,
        wrap_with(:div, "}}", class: "template-editor-right")
      ]
    end
  end

  view :template_editor_frame do
    voo.title = card.label
    voo.hide :set_label
    template_frame do
      _render_core
    end
  end

  view :closed_content do
    ""
  end

  view :set_navbar do |args|
    id = "rule-navbar-#{card.cardname.safe_key}-#{voo.home_view}"
    related_sets = card.related_sets(true)
    return "" if related_sets.size <= 1
    navbar id, toggle: 'Rules<span class="caret"></span>', toggle_align: :left,
               class: "slotter toolbar", navbar_type: "inverse",
               collapsed_content: close_link("pull-right visible-xs") do
      [
        wrap_with(:span, "Set:", class: "navbar-text hidden-xs"),
        (wrap_with :ul, class: "nav navbar-nav nav-pills" do
          related_sets.map do |name, label|
            slot_opts = { subheader: showname(name),
                          subframe: true,
                          hide: "header set_label rule_navbar",
                          show: "subheader set_navbar" }
            link = link_to_card name, label, remote: true,
                                             path: { view: @slot_view,
                                                     slot: slot_opts }
            li_pill link, name == card.name
          end
        end)
      ]
    end
  end

  def li_pill content, active
    "<li role='presentation' #{"class='active'" if active}>#{content}</li>"
  end

  view :rule_navbar do
    navbar "rule-navbar-#{card.cardname.safe_key}-#{voo.home_view}",
           toggle: 'Rules<span class="caret"></span>', toggle_align: :left,
           class: "slotter toolbar", navbar_type: "inverse",
           collapsed_content: close_link("pull-right visible-xs") do
      [rule_navbar_heading, rule_navbar_content]
    end
  end

  def rule_navbar_heading
    wrap_with :span, "Rules:", class: "navbar-text hidden-xs"
  end

  def rule_navbar_pills
    pills = [["common",   :common_rules],
             ["by group", :grouped_rules],
             ["by name",  :all_rules]]
    pills.unshift ["field", :field_related_rules] if card.junction?
    pills.push ["recent", :recent_rules] if recently_edited_settings?
    pills
  end

  def rule_navbar_content
    wrap_with :ul, class: "nav navbar-nav nav-pills" do
      rule_navbar_pills.map do |label, symbol|
        view_link_pill label, symbol
      end
    end
  end

  def view_link_pill name, view
    selected_view = @selected_rule_navbar_view || @slot_view || voo.home_view
    link = link_to_view view, name, class: "slotter", role: "pill",
                                    path: { slot: { show: :rule_navbar } }
    li_pill link, selected_view == view
  end
end

def followed_by? user_id=nil
  all_members_followed_by? user_id
end

def default_follow_set_card
  self
end

def inheritable?
  return true if junction_only?
  cardname.trunk_name.junction? &&
    cardname.tag_name.key == Card::Set::Self.pattern.key
end

def subclass_for_set
  current_set_pattern_code = tag.codename
  Card.set_patterns.find do |set|
    current_set_pattern_code == set.pattern_code
  end
end

def junction_only?
  if @junction_only.nil?
    @junction_only = subclass_for_set.junction_only
  else
    @junction_only
  end
end

def label
  if (klass = subclass_for_set)
    klass.label cardname.left
  else
    ""
  end
end

def uncapitalized_label
  label = label.to_s
  return label unless label[0]
  label[0] = label[0].downcase
  label
end

def follow_label
  if (klass = subclass_for_set)
    klass.follow_label cardname.left
  else
    ""
  end
end

def follow_rule_name user=nil
  if user
    if user.is_a? String
      "#{name}+#{user}+#{Card[:follow].name}"
    else
      "#{name}+#{user.name}+#{Card[:follow].name}"
    end
  else
    "#{name}+#{Card[:all].name}+#{Card[:follow].name}"
  end
end

def all_user_ids_with_rule_for setting_code
  Card.all_user_ids_with_rule_for self, setting_code
end

def setting_codenames_by_group
  result = {}
  Card::Setting.groups.each do |group, settings|
    visible_settings =
      settings.reject { |s| !s || !s.applies_to_cardtype(prototype.type_id) }
    unless visible_settings.empty?
      result[group] = visible_settings.map(&:codename)
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
    !setting || !setting.applies_to_cardtype(prototype.type_id)
  end
end

def all_members_followed?
  all_members_followed_by? Auth.current_id
end

def all_members_followed_by? user_id=nil
  return false unless prototype.followed_by?(user_id)
  return true if set_followed_by? user_id
  broader_sets.each do |b_s|
    if (set_card = Card.fetch(b_s)) && set_card.set_followed_by?(user_id)
      return true
    end
  end
  false
end

def set_followed?
  set_followed_by? Auth.current_id
end

def set_followed_by? user_id=nil
  (
    user_id &&
    (user = Card.find(user_id)) && Card.fetch(follow_rule_name(user.name))
  ) || Card.fetch(follow_rule_name)
end

def broader_sets
  prototype.set_names[1..-1]
end

def prototype
  opts = subclass_for_set.prototype_args cardname.trunk_name
  Card.fetch opts[:name], new: opts
end

def related_sets with_self=false
  if subclass_for_set.anchorless?
    prototype.related_sets with_self
  else
    left(new: {}).related_sets with_self
  end
end
