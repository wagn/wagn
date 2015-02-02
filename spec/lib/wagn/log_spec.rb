
describe Wagn::Log::Request do
  before do
    controller = double()
    allow(controller).to receive(:env) do
      hash = {}
      %w( REMOTE_ADDR REQUEST_METHOD REQUEST_URI HTTP_ACCEPT_LANGUAGE HTTP_REFERER).each do |key|
        hash[key] = key
      end
      hash
    end
    card = double()
    allow(card).to receive(:name) { 'cardname' }
    allow(controller).to receive(:card) { card }
    allow(controller).to receive(:action_name) { 'action_name' }
    allow(controller).to receive(:params) { {'view' => 'view'} }
    allow(controller).to receive(:status) { 'status' }
    Wagn::Log::Request.write_log_entry controller
  end
  it 'creates csv file' do
    expect(File.exist? Wagn::Log::Request.path).to be_truthy
  end
  
  describe 'log file' do
    subject { File.read Wagn::Log::Request.path }
    
    it { is_expected.to include 'REMOTE_ADDR' }
    it { is_expected.to include 'REQUEST_METHOD' }
    it { is_expected.to include 'view' }
    it { is_expected.to include 'status' }
    it { is_expected.to include 'cardname' }
  end  
end

# describe Wagn::Log::AllInstanceMethods do
#   it 'tracks all instance methods when included' do
#     class Card
#       include Wagn::Log::AllInstanceMethods
#     end
#     Wagn.config.performance_logger = { :methods=>[:action]}
#     expect(Rails.logger).to receive(:wagn).with(/test/).once
#     expect(Rails.logger).to receive(:wagn).with(/action/)
#     all = Card[:all]
#     test_log do
#       all.action
#     end
#   end
# end
#
# describe Wagn::Log::AllSingletonMethods do
#   it 'tracks all class methods when included' do
#     class Card
#       include Wagn::Log::AllSingletonMethods
#     end
#     Wagn.config.performance_logger = { :methods=>[:error_codes]}
#     expect(Rails.logger).to receive(:wagn).with(/test/).once
#     expect(Rails.logger).to receive(:wagn).with(/error_codes/)
#     test_log do
#       Card.error_codes
#     end
#   end
# end
#
# describe Wagn::Log::AllMethods do
#   it 'tracks all methods when included' do
#     class Card
#       include Wagn::Log::AllMethods
#     end
#     Wagn.config.performance_logger = { :methods=>[:error_codes, :action] }
#     expect(Rails.logger).to receive(:wagn).with(/test/).once
#     expect(Rails.logger).to receive(:wagn).with(/error_codes/)
#     expect(Rails.logger).to receive(:wagn).with(/action/)
#     all = Card[:all]
#     test_log do
#       Card.error_codes
#       all.action
#     end
#   end
# end


describe Wagn::Log::Performance do  
  

  
  
  describe  Wagn::Log::Performance::BigBrother do
    def log_config opts
       Wagn::Log::Performance.load_config opts
    end
    
    it 'watches instance method' do
      class Card
        extend Wagn::Log::Performance::BigBrother
        watch_instance_method :action
      end
      expect(Rails.logger).to receive(:wagn).with(/test/).once
      expect(Rails.logger).to receive(:wagn).with(/action/)
      all = Card[:all]
      test_log do
        all.action
      end
    end
    
    
    it 'watches all methods' do
      class Card
         extend Wagn::Log::Performance::BigBrother
         watch_all_methods
      end
      expect(Rails.logger).to receive(:wagn).with(/test/).once
      expect(Rails.logger).to receive(:wagn).with(/action/)
      expect(Rails.logger).to receive(:wagn).with(/error_codes/)
      all = Card[:all]
      test_log do
        all.action
        Card.error_codes
      end
    end
    
    it 'watches singleton method' do
      class Card
        extend Wagn::Log::Performance::BigBrother
        watch_singleton_method :error_codes
      end
      expect(Rails.logger).to receive(:wagn).with(/test/).once
      expect(Rails.logger).to receive(:wagn).with(/error_codes/)
      test_log do
        Card.error_codes
      end
    end
    
    it 'watches all class methods' do
      class Card
        extend Wagn::Log::Performance::BigBrother
        watch_all_singleton_methods
      end
      expect(Rails.logger).to receive(:wagn).with(/test/).once
      expect(Rails.logger).to receive(:wagn).with(/error_codes/)
      test_log do
        Card.error_codes
      end
    end
    
    
    it 'crazy shit' do
      log_config( {Card::Set::Type::Skin => {:item_names => {:message=>:content, :title=>"skin item names"}}} )
      expect_logger_to_receive(/skin item names/) do
        Card['classic skin'].item_names
        Card['*all+*read'].item_names
      end
    end
    
    
it 'crazy shit' do   # log arbitrary card method
  log_config( [:content] )
  expect_logger_to_receive(/content/) do
    Card[:all].content
  end
end

it 'more crazy shit' do # log arbitrary method
  log_config( { Wagn => { :singleton=>[:gem_root] } } )
  expect_logger_to_receive(/gem_root/) do
    Wagn.gem_root
  end
end
 
it 'holy shit' do  # log arbitary set method and customize log message
  log_config( {Card::Set::Type::Skin => {:item_names => {:title=>"skin item names",:message=>:content}}} )
  expect_logger_to_receive_once(/skin item names/) do
    Card['classic skin'].item_names
    Card['*all+*read'].item_names
  end
end

it 'almighty shit' do  # use method arguments and procs to customize log messages
  log_config( :instance => { :name= => { :title => proc { |method_context| "change name '#{method_context.name}' to"}, :message=>1 } } )
  expect_logger_to_receive_once(/change name 'c1' to: Alfred/) do
    Card['c1'].name = 'Alfred'
  end
end
    
    
    it 'holy shit' do
      class Card
        def test a, b 
          Rails.logger.wagn("orignal method is still alive") 
        end
        def self.test a, b; end
      end
      log_config( { Card => { :instance => { :test=> {
                                                        :method=>:name, 
                                                        :message=>1
                                                       }}}} )

      expect(Rails.logger).to receive(:wagn).once.with('still alive')
      expect_logger_to_receive(/\*all\: magic/) do
        Card[:all].test "ignore this argument", "magic"
        Card.test "you won't", "get this one"
      end
    end
    
    def expect_logger_to_receive_once message
      allow(Rails.logger).to receive(:wagn).with(/((?!#{message}).)*/ )
      expect(Rails.logger).to receive(:wagn).once.with(message)
      Wagn::Log::Performance.start :method=>'test'
      yield
      Wagn::Log::Performance.stop  
    end
    
    
    
    def expect_logger_to_receive message
      allow(Rails.logger).to receive(:wagn)
      expect(Rails.logger).to receive(:wagn).once.with(message)

      Wagn::Log::Performance.start :method=>'test'
      yield
      Wagn::Log::Performance.stop  
    end
  end
  
  it 'logs searches if enabled' do
    Wagn.config.performance_logger = { :methods=>[:search]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/search\:/).at_least(1)
    test_log do
      Card.search :name=>'all'
    end
  end
  
  it 'logs fetches if enabled' do
    Wagn.config.performance_logger = { :methods=>[:fetch] }
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/fetch/).at_least(1)
    test_log do
      Card.fetch 'all'
    end
  end
  
  it 'logs views if enabled' do
    Wagn.config.performance_logger = { :methods=>[:view]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/process: \*all/)
    expect(Rails.logger).to receive(:wagn).with(/view\:/)
    test_log do
      Card[:all].format.render_raw
    end
  end
  
  it 'logs events if enabled' do
    Wagn.config.performance_logger = { :methods=>[:event]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/process: c1/).once
    expect(Rails.logger).to receive(:wagn).at_least(1).with(/    \|--\([\d.]+ms\) event\:/)
    test_log do
      Card::Auth.as_bot { Card.fetch('c1').update_attributes!(:content=>'c1') }
    end
  end
  
  it "doesn't log methods if disabled" do
    Wagn.config.performance_logger = { :methods=>[]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    test_log do
      Card::Auth.as_bot { Card.fetch('c1').update_attributes!(:content=>'c1') }
      Card.search :name=>'all'
      Card.fetch 'all'
      Card[:all].format.render_raw
    end
  end
  
  it 'creates tree for nested method calls' do
    Wagn.config.performance_logger = { :methods=>[:view]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/  \|--\([\d.]+ms\) process: c1/)
    expect(Rails.logger).to receive(:wagn).with(/    \|--\([\d.]+ms\) view\: core/)
    expect(Rails.logger).to receive(:wagn).with(/      \|--\([\d.]+ms\) view\: raw/)
    test_log do
      Card['c1'].format.render_core
    end
  end
end
