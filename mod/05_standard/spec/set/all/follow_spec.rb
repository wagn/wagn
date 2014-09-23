# -*- encoding : utf-8 -*-

describe Card do
  before do
    Timecop.travel(Wagn.future_stamp)  # make sure we're ahead of all the test data
    @just_s = [Card["Sara"].id]
    @s_and_j= [Card["Sara"].id, Card["John"].id].sort
  end
end

#FIXME outdated tests

# describe "On Card Changes" do
#   before do
#     Card::Auth.current_id = Card['john'].id
#     Timecop.travel(Wagn.future_stamp)  # make sure we're ahead of all the test data
#   end
#
#   it "sends notifications of edits" do
#     double(Card::Mailer).change_notice( Card['Sara'].id, Card["Sara Watching"], "updated", "Sara Watching", nil )
#     Card["Sara Watching"].update_attributes :content => "A new change"
#   end
#
#   it "sends notifications of additions" do
#     new_card = Card.new :name => "Microscope", :type => "Optic"
#     double(Card::Mailer).change_notice( Card['Sara'].id, new_card,"created", "Optic", nil  )
#     new_card.save!
#   end
#
#   it "sends notification of updates" do
#     #  Card::EmailHtmlFormat.any_instance.should_receive('_render_change_notice').with( {watcher: is_a(Integer), watched:"Optic", action: "updated"})
#      #   expect_any_instance_of(Card::HtmlFormat).to receive('_render_change_notice')
#
#     double(Card::Mailer).change_notice( is_a(Integer), Card["Sunglasses"], "updated", "Optic", nil)
#     Card["Sunglasses"].update_attributes :content => 'updated content'
#   end
#
#   it "does not send notification to author of change" do
#     double(Card::Mailer).change_notice.with_any_args.times(any_times) do
#       |*a| expect(a[0]).not_to eq(Card::Auth.current_id)
#     end
#
#     Card["All Eyes On Me"].update_attributes :content => "edit by John"
#   end
#
#   it "does include author in wathers" do
#      expect(Card["All Eyes On Me"].watchers.member?(Card::Auth.current_id)).to be_truthy
#   end
# end
#
#
# describe "Trunk watcher notificatione" do
#   before do
#     Timecop.travel(Wagn.future_stamp)  # make sure we're ahead of all the test data
#
#     Card.create :type=>'Book', :name=>'Ulysses'
#     expect(@ulyss =Card['Ulysses']).to be
#     watchers_card = Card.fetch "Ulysses+*watchers", :new=>{}
#     c = Card['joe camel']
#     watchers_card << c
#     @jc_id = c.id
#     watchers_card.save
#
#     watchers_card = Card.fetch "Book+*watchers", :new=>{}
#     c = Card['joe admin']
#     watchers_card << c
#     @ja_id = c.id
#     watchers_card.save
#   end
#
#   it "sends notification to Joe Camel" do
#     name = "Ulysses+author"
#     double(Card::Mailer).change_notice( @ja_id, @ulyss, "updated", 'Book' , [[name, "created"]], is_a(Card))
#     double(Card::Mailer).change_notice( @jc_id, @ulyss, "updated", @ulyss.name , [[name, "created"]], is_a(Card))
#     c=Card.create :name=>name, :content => "James Joyce"
#   end
#
# end
