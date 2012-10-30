module Wagn::Set::Right::Account

  def self.included(base)
    super
#    base.register_trait('*account', :account)
#    Rails.logger.debug "including +*account #{base}"

#    base.class_eval { attr_accessor :attribute }
#    base.send :before_save, :save_account
  end

end
