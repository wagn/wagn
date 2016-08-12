format :html do
  def default_new_args args
    super args
    args.merge!(
      optional_help: :show, # , optional_menu: :never
      buttons: submit_button,
      account: card.fetch(trait: :account, new: {}),
      title: "Sign up",
      hidden: {
        success: (card.rule(:thanks) || "_self"),
        "card[type_id]" => card.type_id
      }
    )
    return unless Auth.signed_in? && args[:account].confirm_ok?
    invite_args args
  end

  def invite_args args
    args[:title] = "Invite"
    args[:buttons] = button_tag("Send Invitation", situation: "primary")
    args[:hidden][:success] = "_self"
  end

  view :new do |args|
    # FIXME: make more use of standard new view?

    frame_and_form :create, args, "main-success" => "REDIRECT" do
      [
        _render_name_formgroup(help: "usually first and last name"),
        _optional_render(:account_formgroups, args),
        (card.structure ? edit_slot : ""),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :account_formgroups do |args|
    sub_args = { structure: true }
    sub_args[:no_password] = true if Auth.signed_in?
    Auth.as_bot do
      subformat(args[:account])._render :content_formgroup, sub_args
    end # YUCK!!!!
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
    links = []
    if account.confirm_ok?
      links << link_to(
        "#{token_action} verification email",
        card_path("update/~#{card.id}?approve_with_token=true")
      )
      links << link_to(
        "Approve without verification",
        card_path("update/~#{card.id}?approve_without_token=true")
      )
    end
    if card.ok? :delete
      links << link_to("Deny and delete", card_path("delete/~#{card.id}"))
    end
    links
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
