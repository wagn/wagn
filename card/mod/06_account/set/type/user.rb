
include Basic

attr_accessor :email

format :html do
  view :setup, tags: :unknown_ok,
               perms: ->(_r) { Auth.needs_setup? } do |args|
    account = card.fetch trait: :account, new: {}
    Auth.as_bot do
      frame_and_form :create, args do
        [
          _render_name_formgroup(help: "usually first and last name"),
          subformat(account)._render(:content_formgroup, structure: true),
          _render_button_formgroup(args)
        ]
      end
    end
  end

  def default_setup_args args
    args.merge!(
      title: "Welcome, Wagneer!",
      optional_help: :show,
      optional_menu: :never,
      help_text: help_text,
      buttons: setup_button,
      hidden: {
        success: "REDIRECT: #{Card.path_setting '/'}",
        "card[type_id]" => Card.default_accounted_type_id,
        "setup" => true
      }
    )
  end

  def help_text
    text = "<h3>To get started, set up an account.</h3>"
    if Card.config.action_mailer.perform_deliveries == false
      text += <<-HTML
        <br>WARNING: Email delivery is turned off.
        Change settings in config/application.rb to send sign up notifications.'
      HTML
    end
    text
  end

  def setup_button
    submit_button text: "Set up", disable_with: "Setting up"
  end
end

event :setup_as_bot, before: :check_permissions, on: :create,
                     when: proc { Card::Env.params[:setup] } do
  abort :failure unless Auth.needs_setup?
  Auth.as_bot
  # we need bot authority to set the initial administrator roles
  # this is granted and inspected here as a separate event for
  # flexibility and security when configuring initial setups
end

event :setup_first_user, :prepare_to_store, on: :create,
                                            when: proc { Card::Env.params[:setup] } do
  add_subcard "signup alert email+*to", content: name
  add_subfield :roles, content: Card[:administrator].name
end

event :signin_after_setup, :integrate, on: :create,
                                       when: proc { Card::Env.params[:setup] } do
  Auth.signin id
end

def follow follow_name, option="*always"
  return unless
    (card = Card.fetch follow_name) &&
    (set_card = card.default_follow_set_card) &&
    (follow_rule_name = set_card.follow_rule_name(name)) &&
    (follow_rule = Card.fetch follow_rule_name, new: {})
  follow_rule.drop_item "*never"
  follow_rule.add_item option
  follow_rule.save!
end
