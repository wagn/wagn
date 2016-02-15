# -*- encoding : utf-8 -*-

# describe Card::Set::All::AttributeTracking do
#   context "new card" do
#     before(:each) do
#       Card::Auth.as_bot do
#         @c = Card.new name: "New Card", content: "Great Content"
#       end
#     end
#
#     it "should have updates" do
#       described_class::Updates.should === @c.updates
#     end
#
#     it "should track changes" do
#       @c.name.should == 'New Card'
#       @c.name = 'Old Card'
#       @c.name.should == 'Old Card'
#     end
#   end
# end
