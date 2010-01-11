require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailer do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end  

  #
  ## see notifier test for data used in these tests
  # FIXME: the cache is not cleared properly between tests.  if the order changes
  #  (ie try renamed change notice below to change_notice) then *notify+*from gets stuck on.
  context "change notice" do
    before do
      user =  ::User.find_by_login('sara')
      card =  Card["Sunglasses"]
      action = "edited"  
      user.deliver_change_notice( card, action, card.name )
    end

    it "deliver a message" do
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
    
    context "change notice message" do
      before do  
        @mail = ActionMailer::Base.deliveries[0]
      end
      it "is addressed to users email" do
        assert_equal ["sara@user.com"],  @mail.to
      end    
      it "is from Wag bot email" do
        assert_equal [User.find_by_login('wagbot').email], @mail.from
      end     
    end     
  end
  
  context "change notice with custom from" do
    before do
      user =  ::User.find_by_login('sara')
      card =  Card["Sunglasses"]
      action = "edited"      
      User.as :wagbot
      Card.create! :name => "*notify+*from", :type=>"Phrase", :content=>"jiffy@lube.com"
      user.deliver_change_notice( card, action, card.name )
      @mail = ActionMailer::Base.deliveries[0] 
    end       
    
    it "is from custom address" do
      assert_equal @mail.from, ["jiffy@lube.com"]
    end
  end
  

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
