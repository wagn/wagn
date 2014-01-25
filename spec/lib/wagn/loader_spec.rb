require 'wagn/spec_helper'

describe Wagn::Loader do
  let(:card) { Card.new(:name=>'simple') }
  let(:card_double) { proxy Card }
  let(:format_double) { proxy Card::Format }
  let(:html_format_double) { proxy Card::HtmlFormat }
  it "should auto-load Card class methods from lib/wagn and mods" do
    card_double.should_receive(:load_set_modules)
    card_double.should_receive(:load_formats)
    card_double.should_receive(:load_sets)
    card_double.should_receive(:tracks).with(:any_args) # so Card still loads without core in failure testing
    card_double.method(:version).should be
    card_double.method(:method_key).should be
  end
  it "should define Card methods from modules" do
    card.method(:set_modules).should be
  end
  it "should define Formatter methods from modules" do
    format_double.method(:render_core).should be
    format_double.method(:_render_raw).should be
    format_double.method(:render_core).should be
    format_double.method(:_render_raw).should be
  end
  it "should define Formatter methods from modules" do
    html_format_double.method(:render_core).should be
    html_format_double.method(:_render_raw).should be
    html_format_double.method(:render_core).should be
    html_format_double.method(:_render_raw).should be
  end
end
