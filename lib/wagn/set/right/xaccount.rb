=begin
  module Wagn::Set::Rstar::Xaccount -- Devise authentication in Wagn

  This is a card "trait" module that will replace the current model 'User',
  so that the account will be represented by a "trait card", +*account.  When
  a card (for example a User card) has this plus card, it will allow
  authentication via this "account trait" defined in this plugin.

  How It Works

  A link on the card-menu or submenu will as
  Submenus

=end

module Wagn::Set::Rstar::Xaccount

  def self.included(base)
    super
    base.register_trait('*account', :account)
    Rails.logger.debug "including +*account #{base}"

    base.class_eval { attr_accessor :attribute }
    base.send :before_save, :save_account
  end

end
