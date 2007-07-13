class InvitationRequestObserver < ActiveRecord::Observer  
  observe Card::InvitationRequest
  
  def after_create(record)
    Notifier.deliver_invitation_request_alert(record) if System.invite_request_alert_email
  end
end