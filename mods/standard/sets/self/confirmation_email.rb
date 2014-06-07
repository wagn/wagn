format :email do
  view :config do |args|
    args.merge!(
      :to     => account.email,
      :from   => token_emails_from(account),
      :locals =>{
        :link        => wagn_url( "/update/#{account.left.cardname.url_key}?token=#{account.token}" ),
        :expiry_days => Wagn.config.token_expiry / 1.day 
      }
    )
    _final_config(args)  # Type: Email template 
  end
end
