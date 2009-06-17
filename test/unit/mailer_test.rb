require File.dirname(__FILE__) + '/../test_helper'
require 'notifier'

class MailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
  end  
  
  def test_truth
    assert true
  end

  # 1. no existing run.  notify of changes up to $max_interval ago
  # 2. recent run.  notify of changes since last run.
  # 3. stale run.  notify of changes up to $max_interval ago


  # log:  $time.  Notified X users of Y cards that changed between T1 and T2 **

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
