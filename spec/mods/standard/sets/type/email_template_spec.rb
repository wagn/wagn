require 'byebug'

describe Card::Set::Type::EmailTemplate do
  it 'send email on update' do
    Card::Auth.as_bot do
      Card.create! :name=>"mail template",  :type_code=>'email_template', :subcards=>{'+*message'=>{content: 'Hi Joe'}, 
                                                                                      '+*to'=>{content: 'joe@user.com'},
                                                                                      '+*from'=>{content: 'from@user.com'} } 
      #Card.create! :name=>"mail test"
      Card.create! :name=>"mail test+*self+*on update", type_code: :pointer, content: "[[mail template]]"
    end
    card = Card.fetch "mail test"
    byebug
    #expect {Card::Observer.deliver Card.fetch "mail template"}.to change { ActionMailer::Base.deliveries.count }.by(1)
    #expect { Card::Observer.send_event_mails card, on: "update" }.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect { Card::Auth.as_bot { card.update_attributes(content: "test") } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
  
  it 'send email on delete' do
    Card::Auth.as_bot do
      Card.create! :name=>"mail template",  :type_code=>'email_template', :subcards=>{'+*message'=>{content: 'Hi Joe'}, 
                                                                                      '+*to'=>{content: 'joe@user.com'},
                                                                                      '+*from'=>{content: 'from@user.com'} } 
      #Card.create! :name=>"mail test"
      Card.create! :name=>"mail test+*self+*on delete", type_code: :pointer, content: "[[mail template]]"
    end
    card = Card.fetch "mail test"
    byebug
    expect { Card::Auth.as_bot { card.delete } }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end