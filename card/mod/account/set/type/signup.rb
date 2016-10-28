format :html do
  def invitation?
    if @invitation.nil?
      @invitation = Auth.signed_in? && args[:account].confirm_ok?
    else
      @invitation
    end
  end

  view :new do
    voo.title = invitation? ? "Invite" : "Sign up"
    super()
  end

  def new_name_formgroup
    super "usually first and last name"
  end

  def new_content_formgroup
    [account_formgroups, (card.structure ? edit_slot : "")].join
  end

  def hidden_success override=nil
    override = card.rule(:thanks) unless invitation?
    super override
  end

  def new_buttons
    button_formgroup do
      [standard_submit_button, invite_button].compact
    end
  end

  def invite_button
    return unless invitation?
    button_tag "Send Invitation", situation: "primary"
  end

  def account_formgroups
    account = card.fetch trait: :account, new: {}
    Auth.as_bot do
      subformat(account)._render :content_formgroup, structure: true
    end
  end

  view :core do |_args|
    return if card.new_card? # necessary?
    headings = []
    by_anon = card.creator_id == AnonymousID
    headings << %(
      <strong>#{card.name}</strong> #{'was' unless by_anon} signed up on
      #{format_date card.created_at}
    )
    if (account = card.account)
      headings += verification_info account
    else
      headings << "ERROR: signup card missing account"
    end
    <<-HTML
      <div class="invite-links">
        #{headings.map { |h| "<div>#{h}</div>" }.join "\n"}
      </div>
      #{process_content render_raw}
    HTML
  end

  def verification_info account
    headings = []
    token_action = "Send"
    if account.token.present?
      headings << "A verification email has been sent " \
                  "#{"to #{account.email}" if account.email_card.ok? :read}"
      token_action = "Resend"
    end
    links = verification_links account, token_action
    headings << links * "" if links.any?
    headings
  end

  def verification_links account, token_action
    [
      approve_with_token_link(account, token_action),
      approve_without_token_link(account),
      deny_link
    ].compact
  end

  def approve_with_token_link account, token_action
    return unless account.confirm_ok?
    link_to_card card, "#{token_action} verification email",
                 path: { action: :update, approve_with_token: true }
  end

  def approve_without_token_link account
    return unless account.confirm_ok?
    link_to_card card, "Approve without verification",
                 path: { action: :update, approve_without_token: true }
  end

  def deny_link
    return unless card.ok? :delete
    link_to_card card, "Deny and delete", path: { action: :delete }
  end
end

event :activate_by_token, :validate, on: :update,
                                     when: proc { |c| c.has_token? } do
  abort :failure, "no field manipulation mid-activation" if subcards.present?
  # necessary because this performs actions as Wagn Bot
  abort :failure, "no account associated with #{name}" unless account

  account.validate_token! @env_token

  if account.errors.empty?
    account.token_card.used!
    activate_account
    Auth.signin id
    Auth.as_bot # use admin permissions for rest of action
    success << ""
  else
    resend_activation_token
    abort :success
  end
end

def has_token?
  @env_token = Env.params[:token]
end

event :activate_account do
  # FIXME: -- sends email before account is fully activated
  add_subfield :account
  subfield(:account).add_subfield :status, content: "active"
  self.type_id = Card.default_accounted_type_id
  account.send_welcome_email
end

event :approve_with_token, :validate,
      on: :update,
      when: proc { Env.params[:approve_with_token] } do
  abort :failure, "illegal approval" unless account.confirm_ok?
  account.reset_token
  account.send_account_verification_email
end

event :approve_without_token, :validate,
      on: :update,
      when: proc { Env.params[:approve_without_token] } do
  abort :failure, "illegal approval" unless account.confirm_ok?
  activate_account
end

event :resend_activation_token do
  account.reset_token
  account.send_account_verification_email
  message = "Please check your email for a new password reset link."
  if account.errors.any?
    message = "Sorry, #{account.errors.first.last}. #{message}"
  end
  success << { id: "_self", view: "message", message: message }
end

def signed_in_as_me_without_password?
  Auth.signed_in? && Auth.current_id == id && account.password.blank?
end

event :redirect_to_edit_password, :finalize,
      on: :update,
      when: proc { |c| c.signed_in_as_me_without_password? } do
  Env.params[:success] = account.edit_password_success_args
end

event :act_as_current_for_integrate_stage, :integrate,
      on: :create do
  Auth.current_id = id
end
