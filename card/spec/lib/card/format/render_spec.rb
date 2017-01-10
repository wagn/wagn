describe Card::Format::Render do
  describe "view cache" do
    before { Cardio.config.view_cache = true }

    let(:cache_key) do
      "a-Card::Format::HtmlFormat-normal-home_view:content;"\
      "nest_name:A;nest_syntax:A|content;view:contentcontent:show"
    end

    subject { Card::Cache[Card::View] }

    it "can be changed with nest option" do
      is_expected.to receive(:fetch).with cache_key
      render_content "{{A|content}}"
      is_expected.not_to receive(:fetch)
      render_content "{{A|cache:never}}"
    end
  end
end
