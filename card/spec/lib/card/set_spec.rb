# -*- encoding : utf-8 -*-

# module Card::Set::Right::Account # won't this conflict with a real set (and fail to provide controlled test?)
#   extend Card::Set
#
#   card_accessor :role,   default: "request", type: :phrase
#   card_writer   :write,  default: "request", type: :phrase
#   card_reader   :read,   default: "request", type: :phrase
# end
#
# describe Card do
#   before do
#     @account_card = Card['sara'].fetch trait: :account
#   end
#
#   describe "Read and write card attribute" do
#     it "gets email attribute" do
#       expect(@account_card.role).to eq('request')
#     end
#
#     it "shouldn't have a reader method for card_writer" do
#       expect(@account_card.respond_to?( :write)).to be_falsey
#       expect(@account_card.method( :write= )).to be
#     end
#
#     it "shouldn't have a reader method for card_reader" do
#       expect(@account_card.method( :read)).to be
#       expect(@account_card.respond_to?( :read= )).to be_falsey
#     end
#
#     it "sets and saves attribute" do
#       @account_card.write= 'test_value'
#       @account_card.status= 'pending'
# #      @account_card.status.should == 'pending'
#       Card::Auth.as_bot { @account_card.save }
# #      Card.cache.reset
#       expect(tcard = Card['sara'].fetch(trait: :account)).to be
#       expect(tcard.status).to eq('pending')
#       expect(tcard.fetch(trait: :write).content).to eq('test_value')
#     end
#
#   end
#
#   let(:card) { Card.new(name: 'simple') }
#   let(:card_self) { Card.new(name: '*navbox') }
#   let(:card_right) { Card.new(name: 'card+*right') }
#   let(:card_type_search) { Card.new(name: 'search_me', type: Card::SearchID) }
#   let(:card_double) { Card }
#   let(:format_double) { object_double(Card.new(name: 'card+*right').format) }
#
#   #let(:html_format_double) { Card::HtmlFormat }
#   let(:html_format_double) { double("Card::HtmlFormat") }
#
#   it "should define Formatter methods from modules" do
#     expect(format_double).to respond_to(:render_navbox_self_core)
#     expect(format_double.method(:render_navbox_self_core)).to be
#     expect(format_double.method(:_render_right_right_raw)).to be
#     expect(format_double.method(:render_type_search_core)).to be
#     expect(format_double.method(:_final_type_search_raw)).to be
#   end
#   it "should call set render methods" do
#     expect(card_self).to receive(:_final_self_navbox_core)
#     card_self.format.render_core
#     #expect(card_right.format.method(:_render_right_right_raw)).to be
#     #expect(card_right.format).to respond_to(:_render_right_right_raw)
#     card_right.format.render_core
#     expect(card_type_search.method(:render_type_search_core)).to be
#     card_type_search.format.render_core
#     expect(card.method(:_final_type_search_raw)).to be
#     card.format.render_core
#   end
#   it "should define Formatter methods from modules" do
#     expect(html_format_double.method(:render_self_navbox_core)).to be
#     expect(html_format_double.method(:_render_right_right_raw)).to be
#     expect(html_format_double.method(:render_type_search_core)).to be
#     expect(html_format_double.method(:_final_type_search_raw)).to be
#   end
#   it "should define Formatter methods from modules" do
#     expect(card_self).to receive(:_final_self_navbox_titled)
#     card_self.render_titled
#     expect(card_right.method(:_render_right_right_edit)).to be
#     card_right.render_edit
#     expect(card_type_search.method(:render_type_search_menu)).to be
#     card_type_search.render_menu
#     expect(card.method(:_final_type_search_content)).to be
#     card.render_content
#   end
# end
