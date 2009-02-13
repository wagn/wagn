class InvitationRequestObserver < ActiveRecord::Observer  
  observe Card::InvitationRequest
  
  def after_create(record)
    # *Starry  *request+*alert
    Notifier.deliver_invitation_request_alert(record) if System.setting('*invite+*to')
  end
end