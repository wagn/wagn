require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerTest < ActiveSupport::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }

    User.as(:wagbot) do
      # have these items created way in the past

      sara_account = ::User.create! :login=>"sara",:email=>'sara@user.com', :status => 'active', :password=>'sara_pass', :password_confirmation=>'sara_pass', :invite_sender=>User[:wagbot]
      Card.create! :name=>"Sara", :type=> "User", :extension=>sara_account       
      Card.create! :name => "Sunglasses", :type=>"Optic"
    end
    
  end  
  
  def test_truth
    assert true
  end
  
  ## see notifier test for data used in these tests
  # FIXME: the cache is not cleared properly between tests.  if the order changes
  #  (ie try renamed change notice below to change_notice) then *notify+*from gets stuck on.
  context "change notice" do
    setup do
      user =  ::User.find_by_login('sara')
      card =  Card["Sunglasses"]
      action = "edited"  
      CachedCard.bump_global_seq    
      Mailer.deliver_change_notice( user, card, action, card.name )
    end

    should "deliver a message" do
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
    
    context "change notice message" do
      setup do  
        CachedCard.bump_global_seq    
        @mail = ActionMailer::Base.deliveries[0]
      end
      should "be addressed to users email" do
        assert_equal ["sara@user.com"],  @mail.to
      end    
      should "be from Wag bot email" do
        assert_equal [User.find_by_login('wagbot').email], @mail.from
      end     
    end     
  end
  
  context "change notice with custom from" do
    setup do
      user =  ::User.find_by_login('sara')
      card =  Card["Sunglasses"]
      action = "edited"      
      User.as :wagbot
      Card.create! :name => "*notify+*from", :type=>"Phrase", :content=>"jiffy@lube.com"
      Mailer.deliver_change_notice( user, card, action, card.name )
      @mail = ActionMailer::Base.deliveries[0] 
    end
    should "be from custom address" do
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
