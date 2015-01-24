describe Card::Log::Request do
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
    Card::Log::Request.write_log_entry controller
  end
  it 'creates csv file' do
    expect(File.exist? Card::Log::Request.path).to be_truthy
  end
  
  describe 'log file' do
    subject { File.read Card::Log::Request.path }
    
    it { is_expected.to include 'REMOTE_ADDR' }
    it { is_expected.to include 'REQUEST_METHOD' }
    it { is_expected.to include 'view' }
    it { is_expected.to include 'status' }
    it { is_expected.to include 'cardname' }
  end  
end


describe Card::Log::Performance do
  def test_log 
    Card::Log::Performance.start :method=>'test'
    yield
    Card::Log::Performance.stop  
  end
    
  it 'logs searches if enabled' do
    Cardio.config.performance_logger = { :methods=>[:search]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/search\:/).at_least(1)
    test_log do
      Card.search :name=>'all'
    end
  end
  
  it 'logs fetches if enabled' do
    Cardio.config.performance_logger = { :methods=>[:fetch] }
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/fetch/).at_least(1)
    test_log do
      Card.fetch 'all'
    end
  end
  
  it 'logs views if enabled' do
    Cardio.config.performance_logger = { :methods=>[:view]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/process: \*all/)
    expect(Rails.logger).to receive(:wagn).with(/view\:/)
    test_log do
      Card[:all].format.render_raw
    end
  end
  
  it 'logs events if enabled' do
    Cardio.config.performance_logger = { :methods=>[:event]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/process: c1/).once
    expect(Rails.logger).to receive(:wagn).at_least(1).with(/    \|--\([\d.]+ms\) event\:/)
    test_log do
      Card::Auth.as_bot { Card.fetch('c1').update_attributes!(:content=>'c1') }
    end
  end
  
  it "doesn't log methods if disabled" do
    Cardio.config.performance_logger = { :methods=>[]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    test_log do
      Card::Auth.as_bot { Card.fetch('c1').update_attributes!(:content=>'c1') }
      Card.search :name=>'all'
      Card.fetch 'all'
      Card[:all].format.render_raw
    end
  end
  
  it 'creates tree for nested method calls' do
    Cardio.config.performance_logger = { :methods=>[:view]}
    expect(Rails.logger).to receive(:wagn).with(/test/).once
    expect(Rails.logger).to receive(:wagn).with(/  \|--\([\d.]+ms\) process: c1/)
    expect(Rails.logger).to receive(:wagn).with(/    \|--\([\d.]+ms\) view\: core/)
    expect(Rails.logger).to receive(:wagn).with(/      \|--\([\d.]+ms\) view\: raw/)
    test_log do
      Card['c1'].format.render_core
    end
  end
end
