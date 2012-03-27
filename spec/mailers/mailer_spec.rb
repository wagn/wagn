require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Mailer do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  #include ActionMailer::Quoting

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = Mail.new
  end  

  #
  ## see notifier test for data used in these tests
  # FIXME: the cache is not cleared properly between tests.  if the order changes
  #  (ie try renamed change notice below to change_notice) then *notify+*from gets stuck on.
  context "change notice" do
    before do
      user =  Card['sara'].id
      card =  Card["Sunglasses"]
      action = "edited"  
      Mailer.change_notice( user, card, action, card.name ).deliver
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
        assert_equal [User.admin.email], @mail.from
      end     
    end     
  end
  
  describe "flexmail" do
    # FIXME: at least two tests should be here, with & w/o attachment.
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, Mailer::CHARSET)
    end

end
