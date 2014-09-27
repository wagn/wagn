=begin
describe Card::Loader do
  let(:card_double) { proxy Card }
  let(:pat_all_double) { proxy Card::AllSet }
  let(:format_double) { proxy Card::Format }
  let(:html_format_double) { proxy Card::HtmlFormat }
  it "should auto-load Card class methods from lib/wagn and mods" do
    expect(card_double).to receive(:load_set_modules)
    expect(card_double).to receive(:load_formats)
    expect(card_double).to receive(:load_sets)
    expect(card_double).to receive(:tracks).with(:any_args) # so Card still loads without core in failure testing
    expect(card_double.method(:version)).to be
    expect(card_double.method(:type_card)).to be
    expect(card_double.method(:file_path)).to be
  end
  it "should define Card methods from modules" do
    expect(pat_all_double.method(:set_modules)).to be
  end
  it "should define Formatter methods from modules" do
    expect(format_double.method(:render_core)).to be
    expect(format_double.method(:_render_raw)).to be
    expect(format_double.method(:render_core)).to be
    expect(format_double.method(:_render_raw)).to be
  end
  it "should define Formatter methods from modules" do
    expect(html_format_double.method(:render_core)).to be
    expect(html_format_double.method(:_render_raw)).to be
    expect(html_format_double.method(:render_core)).to be
    expect(html_format_double.method(:_render_raw)).to be
  end
end
=end
