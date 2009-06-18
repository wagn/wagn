require File.dirname(__FILE__) + '/../test_helper'   
require 'timecop'    

class NotifierTest < Test::Unit::TestCase  
  FUTURE = Time.local(2020,1,1,0,0,0)
  
  def self.add_test_data
    User.as(:wagbot) do
      # have these items created way in the past

      Timecop.freeze(FUTURE - 1.day) do
        # fwiw Timecop is apparently limited by ruby Time object, which goes only to 2037 and back to 1900 or so.
        #  whereas DateTime can represent all dates. 

        john_account = ::User.create! :login=>"john",:email=>'john@user.com', :status => 'active', :password=>'john_pass', :password_confirmation=>'john_pass', :invite_sender=>User[:wagbot]
        sara_account = ::User.create! :login=>"sara",:email=>'sara@user.com', :status => 'active', :password=>'sara_pass', :password_confirmation=>'sara_pass', :invite_sender=>User[:wagbot]

        Card.create! :name=>"John", :type=> "User", :extension=>john_account
        Card.create! :name=>"Sara", :type=> "User", :extension=>sara_account       

        Card.create! :name => "Sara Watching+*watchers",  :content => "[[Sara]]"
        Card.create! :name => "All Eyes On Me+*watchers", :content => "[[Sara]]\n[[John]]"
        Card.create! :name => "John Watching+*watchers",  :content => "[[John]]"
        Card.create! :name => "No One Sees Me"  

        Card.create! :name => "Optic", :type => "Cardtype"
        Card.create! :name => "Optic+*watchers", :content => "[[Sara]]"
        Card.create! :name => "Sunglasses", :type=>"Optic"

        # TODO: I would like to setup these card definitions with something like Cucumbers table feature.
      end
    end
  end  

  setup do                             
    CachedCard.reset_cache; 
    CachedCard.bump_global_seq  # should figure out how not to have to do this all over..
    Timecop.freeze(FUTURE)  # make sure we're ahead of all the test data
    User.as(:sara)          # default editor

  end

  context "Card#watchers" do
    should "return users watching this card specifically" do
      assert_equal ["Sara", "John"], Card["All Eyes On Me"].watchers.map(&:name)
    end
    
    should "return users watching cards of this type" do
      assert_equal ["Sara"], Card["Sunglasses"].watchers.map(&:name)
    end
  end
  
  context "Given no previous runs" do
    setup do
      Card["John Watching"].update_attributes :content => "An old change"
    end
    
    context "Notifier.recently_changed()" do
      should "return cards changed since max_interval" do
        Timecop.freeze(FUTURE + Notifier.max_interval + 1.day) do
          Card["Sara Watching"].update_attributes :content => "A new change"
          assert_equal ["Sara Watching"], Notifier.recently_changed.map(&:name)
        end
      end  
    end    
    
    context "Notifier.send_notifications()" do
      should "send notifications about recent changes to watchers" do
        Timecop.freeze(FUTURE + Notifier.max_interval + 1.day) do
          Card["Sara Watching"].update_attributes :content => "A new change"   
          
          Notifier.send_notifications()
        end
      end
    end
    
  end    
end