require File.expand_path('../spec_helper', File.dirname(__FILE__))
include AuthenticatedTestHelper
include EmailSpec::Helpers
include EmailSpec::Matchers

describe Mailer do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"
  #include ActionMailer::Quoting

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end  

  #
  ## see notifier test for data used in these tests
  # FIXME: the cache is not cleared properly between tests.  if the order changes
  #  (ie try renamed change notice below to change_notice) then *notify+*from gets stuck on.
  context "account info, new password" do # forgot password
    before do
      user_id =  Card['sara'].id
      @user = User.where(:card_id=>user_id).first
      @user.generate_password
      @email = Mailer.account_info(@user, "New password subject", "Forgot my password")
    end

    context "new password message" do
      it "is addressed to users email" do
        @email.should deliver_to(@user.email)
      end    

      it "is from Wag bot email" do
        @email.should deliver_from(User.admin.email)
        #assert_equal [User.admin.email], @mail.from
      end     

      it "sends the right email" do
        @email.should have_body_text /foobarbaz/
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
      quoted_printable(subject, CHARSET)
    end

end
