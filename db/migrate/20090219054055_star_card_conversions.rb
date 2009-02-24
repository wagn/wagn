class StarCardConversions < ActiveRecord::Migration
  def self.up
    User.as :admin do
      f = "#{RAILS_ROOT}/public/stylesheets/local.css"
      css = File.exists?(f) ? File.read(f) : ""

      migrate_to('*css', css, 'HTML')    
      migrate_to('*title', System.site_name)
    
      migrate_to('*invite+*subject', ((card=Card['system setting+invitation email subject']) ? card.content : System.invitation_email_subject))
      migrate_to('*invite+*message', ((card=Card['system setting+invitation email body']) ? card.content : System.invitation_email_body), 'PlainText')
      migrate_to('*invite+*thanks', 'wagn/Invite_Success')
    
      migrate_to('*request+*to', System.invite_request_alert_email)
      migrate_to('*signup+*thanks', 'wagn/Signup_Success')


      Card.find_or_create(:name=>'Invite Success', :content=>'Your invitation has been sent')
      Card.find_or_create(:name=>'Signup Success', :content=>'Thank you for signing up')
      
      ss=Card['system setting'] and ss.confirm_destroy=true and ss.destroy!
      
      # newly in use, but not vital 
      #*account+*from
      #*request+*from
      #*request+*to
      #*signup+*message
      #*signup+*subject
    end
  end

  def self.migrate_to(name,content,type='Phrase')
    c = Card.find_or_create(:name=>name)
    c.content = content || ''
    c.type = type
    c.permit :edit, Role[:admin]
    c.save!
  end

  def self.down
  end
end
