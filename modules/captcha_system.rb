module CaptchaSystem
  protected
  def require_captcha  
    load_card unless @card  
    if captcha_required? and !verify_captcha(:model=>@card)
      render_card_errors(@card)
      return false
    end
    true
  end                  
  
  def verify_captcha(args={})          
    opts = {
      :model => @card,
      :timeout => 20
    }.merge(args)
    unless params[:recaptcha_challenge_field] and params[:recaptcha_response_field] 
      opts[:model].errors.add(:captcha, "is needed to verify that you're human")
      return false 
    end
    verify_recaptcha(opts) 
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

ApplicationController.send :include, CaptchaSystem
