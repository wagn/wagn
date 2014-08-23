# -*- encoding : utf-8 -*-

describe Card::Set::All::Rules do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  describe "setting data setup" do
    it "should make Set of +*type" do
      Card.create! :name=>"SpeciForm", :type=>'Cardtype'
      Card.create!( :name=>"SpeciForm+*type" ).type_code.should == :set
    end
  end

  describe "#rule" do
    it "retrieves Set based value" do
      Card.create :name => "Book+*type+*add help", :content => "authorize"
      Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "authorize"
    end

    it "retrieves default values" do
      #Card.create :name => "all Basic cards", :type => "Set", :content => "{\"type\": \"Basic\"}"  #defaults should work when other Sets are present
      assert c=Card.create(:name => "*all+*add help", :content => "lobotomize")
#      Card.default_rule(:add_help, :fallback=>:help).should == "lobotomize"
      Card.new( :type => "Basic" ).rule(:add_help, :fallback=>:help).should == "lobotomize"
    end

    it "retrieves single values" do
      Card.create! :name => "banana+*self+*help", :content => "pebbles"
      Card["banana"].rule(:help).should == "pebbles"
    end
    
    context 'with fallback' do
      before do
        Card.create :name => "*all+*help", :content => "edit any kind of card"
      end

      it "retrieves default setting" do
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "edit any kind of card"
      end

      it "retrieves primary setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "add any kind of card"
      end

      it "retrieves more specific default setting" do
        Card.create :name => "*all+*add help", :content => "add any kind of card"
        Card.create :name => "*Book+*type+*help", :content => "edit a Book"
        Card.new( :type => "Book" ).rule(:add_help, :fallback=>:help).should == "add any kind of card"
      end
    end
  end


  describe "#setting_codenames_by_group" do
    before do
      @pointer_settings =  [ :options, :options_label, :input ]
    end
    it "doesn't fail on nonexistent trunks" do
      Card.new(:name=>'foob+*right').setting_codenames_by_group.class.should == Hash
    end
    
    it "returns universal setting names for non-pointer set" do
      pending "Different api, we should just put the tests in a new spec for that"
      snbg = Card.fetch('*star').setting_codenames_by_group
      #warn "snbg #{snbg.class} #{snbg.inspect}"
      snbg.keys.length.should == 4
      snbg.keys.first.should be_a Symbol
      snbg.keys.member?( :pointer ).should_not be_true
    end


    it "returns pointer-specific setting names for pointer card" do
      c = Card.fetch 'Fruit+*type+*create+*self', :new=>{}
      snbg = c.setting_codenames_by_group
      snbg[:pointer].should == @pointer_settings
    end

  end
end
