
Card.error_codes.merge! permission_denied: [:denial, 403],
                        captcha: [:errors, 449]

module ClassMethods
  def repair_all_permissions
    Card.where(
      "(read_rule_class is null or read_rule_id is null) and trash is false"
    ).each do |broken_card|
      broken_card.include_set_modules
      broken_card.repair_permissions!
    end
  end
end

def repair_permissions!
  rule_id, rule_class = permission_rule_id_and_class :read
  update_columns read_rule_id: rule_id, read_rule_class: rule_class
end

# ok? and ok! are public facing methods to approve one action at a time
#
#   fetching: if the optional :trait parameter is supplied, it is passed
#      to fetch and the test is perfomed on the fetched card, therefore:
#
#      trait: :account      would fetch this card plus a tag codenamed :account
#      trait: :roles, new: {} would initialize a new card with default ({})
# options.

def ok? action
  @action_ok = true
  send "ok_to_#{action}"
  @action_ok
end

def ok_with_fetch? action, opts={}
  card = opts[:trait].nil? ? self : fetch(opts)
  card && card.ok_without_fetch?(action)
end

# note: method is chained so that we can return the instance variable @action_ok
alias_method_chain :ok?, :fetch

def ok! action, opts={}
  raise Card::PermissionDenied, self unless ok? action, opts
end

def who_can action
  # warn "who_can[#{name}] #{(prc=permission_rule_card(action)).inspect},
  # #{prc.first.item_cards.map(&:id)}" if action == :update
  permission_rule_card(action).item_cards.map(&:id)
end

def permission_rule_id_and_class action
  direct_rule_id = rule_card_id action
  require_permission_rule! direct_rule_id, action
  direct_rule = Card.fetch direct_rule_id, skip_modules: true
  [applicable_permission_rule_id(direct_rule, action),
   direct_rule.rule_class_name]
end

def applicable_permission_rule_id direct_rule, action
  if junction? && direct_rule.db_content =~ /^\[?\[?_left\]?\]?$/
    lcard = left_or_new(skip_virtual: true, skip_modules: true)
    if action == :create && lcard.real? && !lcard.action == :create
      action = :update
    end
    lcard.permission_rule_id_and_class(action).first
  else
    direct_rule.id
  end
end

def permission_rule_card action
  Card.fetch permission_rule_id_and_class(action).first
end

def require_permission_rule! rule_id, action
  return if rule_id
  # RULE missing.  should not be possible.
  # generalize this to handling of all required rules
  errors.add :permission_denied, "No #{action} rule for #{name}"
  raise Card::PermissionDenied, self
end

def rule_class_name
  trunk.type_id == Card::SetID ? cardname.trunk_name.tag : nil
end

def you_cant what
  "You don't have permission to #{what}"
end

def deny_because why
  @permission_errors << why if @permission_errors
  @action_ok = false
end

def permitted? action
  return if Card.config.read_only
  return true if action != :comment && Auth.always_ok?

  permitted_ids = who_can action
  if action == :comment && Auth.always_ok?
    # admin can comment if anyone can
    !permitted_ids.empty?
  else
    Auth.among? permitted_ids
  end
end

def permit action, verb=nil
  # not called by ok_to_read
  deny_because "Currently in read-only mode" if Card.config.read_only

  return if permitted? action
  verb ||= action.to_s
  deny_because you_cant("#{verb} #{name.present? ? name : 'this'}")
end

def ok_to_create
  permit :create
  return if !@action_ok || !junction?

  [:left, :right].each do |side|
    # left is supercard; create permissions will get checked there.
    next if side == :left && @superleft
    part_card = send side, new: {}
    # if no card, there must be other errors
    next unless part_card && part_card.new_card?
    unless part_card.ok? :create
      deny_because you_cant("create #{part_card.name}")
    end
  end
end

def ok_to_read
  return if Auth.always_ok?
  @read_rule_id ||= permission_rule_id_and_class(:read).first
  return if Auth.as_card.read_rules.member? @read_rule_id
  deny_because you_cant "read this"
end

def ok_to_update
  permit :update
  if @action_ok && type_id_changed? && !permitted?(:create)
    deny_because you_cant("change to this type (need create permission)")
  end
  ok_to_read if @action_ok
end

def ok_to_delete
  permit :delete
end

def ok_to_comment
  permit :comment, "comment on"
  return unless @action_ok
  deny_because "No comments allowed on templates" if is_template?
  deny_because "No comments allowed on structured content" if structure
end

event :clear_read_rule, :store, on: :delete do
  self.read_rule_id = self.read_rule_class = nil
end

event :set_read_rule, :store,
      on: :save, changed: [:type_id, :name] do
  read_rule_id, read_rule_class = permission_rule_id_and_class(:read)
  self.read_rule_id = read_rule_id
  self.read_rule_class = read_rule_class
end

event :set_field_read_rules,
      after: :set_read_rule, on: :update, changed: :type_id do
  # find all cards with me as trunk and update their read_rule
  # (because of *type plus right)
  # skip if name is updated because will already be resaved

  Auth.as_bot do
    fields.each do |field|
      field.refresh.update_read_rule
    end
  end
end

def update_read_rule
  Card.record_timestamps = false
  reset_patterns # why is this needed?
  rcard_id, rclass = permission_rule_id_and_class :read
  # these two are just to make sure vals are correct on current object
  self.read_rule_id = rcard_id
  self.read_rule_class = rclass
  Card.where(id: id).update_all read_rule_id: rcard_id, read_rule_class: rclass
  expire_hard

  # currently doing a brute force search for every card that may be impacted.
  # may want to optimize(?)
  Auth.as_bot do
    fields.each do |field|
      field.update_read_rule if field.rule(:read) == "_left"
    end
  end

ensure
  Card.record_timestamps = true
end

def add_to_read_rule_update_queue updates
  @read_rule_update_queue = Array.wrap(@read_rule_update_queue).concat updates
end

event :check_permissions, :validate do
  task =
    if @action != :delete && comment # will be obviated by new comment handling
      :comment
    else
      @action
    end
  track_permission_errors do
    ok? task
  end
end

def track_permission_errors
  @permission_errors = []
  result = yield

  @permission_errors.each do |message|
    errors.add :permission_denied, message
  end
  @permission_errors = nil

  result
end

def recaptcha_on?
  have_recaptcha_keys? &&
    Env[:controller]   &&
    !Auth.signed_in?   &&
    !Auth.needs_setup? &&
    !Auth.always_ok?   &&
    Card.toggle(rule(:captcha))
end

def have_recaptcha_keys?
  @@have_recaptcha_keys =
    if defined?(@@have_recaptcha_keys)
      @@have_recaptcha_keys
    else
      !!(Card.config.recaptcha_public_key && Card.config.recaptcha_private_key)
    end
end

event :recaptcha, :validate do
  if !@supercard && !Env[:recaptcha_used] && recaptcha_on?
    Env[:recaptcha_used] = true
    Env[:controller].verify_recaptcha model: self, attribute: :captcha
  end
end

module Accounts
  # This is a short-term hack that is used in account-related cards to allow a
  # permissions pattern where permissions are restricted to the owner of the
  # account (and, by default, Admin)
  # That pattern should be permitted by our card representation
  # (without creating separate rules for each account holder) but is not yet.

  def permit action, verb=nil
    if action == :comment then @action_ok = false
    elsif action == :create  then @superleft ? true : super(action, verb)
      # restricts account creation to subcard handling on permitted card
      # (unless explicitly permitted)
    elsif own_account? then true
    else
      super action, verb
    end
  end
end

module Follow
  def ok_to_update
    permit :update
  end

  def ok_to_create
    permit :create
  end

  def ok_to_delete
    permit :delete
  end

  def permit action, verb=nil
    if [:create, :delete, :update].include?(action) && Auth.signed_in? &&
       (user = rule_user) && Auth.current_id == user.id
      return true
    else
      super action, verb
    end
  end
end
