module CaptchaSystem
  protected
  def require_captcha 
    load_card unless @card  
    if captcha_required?
      if params[:recaptcha_challenge_field] and params[:recaptcha_response_field] 
        if verify_recaptcha(:model=>@card, :timeout=>20)
          return true
        end
      else 
        @card.errors.add(:captcha, "Since you're not signed in, we need to verify that you're human in the captcha below")
      end
      render_card_errors(@card)
      return false
    end
    true
  end

  def captcha_required?   
    setting = nil
    setting = System.toggle_setting("#{@card.type}+*captcha") if @card
    setting = System.toggle_setting('*captcha') if setting.nil?
    setting = false if setting.nil?
    not logged_in? and setting
  end  
  
  def self.included(base)
    base.send :helper_method, :captcha_required?
  end
end