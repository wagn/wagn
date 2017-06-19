describe Card::Bootstrap do
  subject { described_class.new(format) }

  let(:format) { Card["A"].format(:html) }

  def render
    subject.render do
      yield
    end
  end

  it "loads components" do
    expect(subject).to respond_to(:form)
    expect(subject.form).to be_instance_of ActiveSupport::SafeBuffer
  end
  describe "html" do
    it "renderes plain text" do
      # expect(render { html "test" }).to eq "test"
    end
  end
end
