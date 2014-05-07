require 'byebug'


describe Factory do
  include Wagn::Location
  
  before(:all) do
    @depth = 4
    @basics = []
    Card::Auth.as_bot do
      (2*@depth).times do |i|
        #@basics << Card.create!( :name =>  "basic level #{i}",  :type => Card::BasicID  )
        @basics << Card.fetch( "basic level #{i}", :new =>  {:type => Card::BasicID } )
        @basics.last.save
      end
    end
  end

  context 'after stored' do
    it 'creates input card' do
      Card::Auth.as_bot do
        name = 'a style test'
        c = Card.fetch( "#{name}+*input" )
        c.delete! if c
        c = Card.fetch name
        c.delete! if c  
        c = Card.create!( :name => 'a style test',  :type => Card::SkinID )
        Card.fetch( "#{name}+*input" ).should_not be_nil
      end
    end
    it 'creates output card' do
      Card::Auth.as_bot do
        name = 'a style test'
        c  = Card.fetch( "#{name}+*input" )
        c.delete! if c
        c = Card.fetch name
        c.delete! if c  
        c = Card.create! :name => 'a style test',  :type => Card::SkinID 
        Card.fetch( "#{name}+*output" ).should_not be_nil
      end
    end
  end
  
  describe "factory_input_cards" do
    context 'for skins' do
      before do
        Card::Auth.as_bot do
          @first_level = last_level = Card.fetch( 'my nested skin', :new => {:type => Card::SkinID} )
          @depth.times do |i|
            last_level.content = ""
            next_level = Card.fetch( "skin level #{i}", :new => {:type => Card::SkinID} )
            last_level << @basics[i]
            last_level << next_level
            last_level << @basics[2*@depth-i-1]
            last_level.save
            last_level = next_level
          end
          last_level.save
        end
      end
      it "scans all levels" do
        @first_level.factory_input_cards.map(&:id).sort.should == @basics.map(&:id).sort
      end
      it "preserves order" do
        @first_level.factory_input_cards.map(&:id).should == @basics.map(&:id)
      end
    end
    
    context 'for pointers' do
      before do
        Card::Auth.as_bot do
          @first_level = last_level = Card.fetch 'my nested pointer', :new => {:type => Card::SkinID}
          @depth.times do |i|
            next_level = Card.fetch "pointer level #{i}", :new => {:type => Card::PointerID}
            last_level.content = ""
            last_level << @basics[i]
            last_level << next_level
            last_level << @basics[2*@depth-i-1]
            last_level.save
            last_level = next_level
          end
          last_level.save
        end
      end
      
      it "contains items" do
        Card::Auth.as_bot do
          css = '#box { display: block }'
          @css_card = Card.create!( {:name => 'my css', :type => Card::CssID, :content => css } )
          
          @skin = Card.fetch 'my skin', :new =>  {:type => Card::SkinID }
          @skin.content = ''
          @skin << @css_card
          @skin.save!
        end
        input = @skin.factory_input_cards
        input.should == [@css_card]
      end
  
      it "scans all levels" do
          @first_level.factory_input_cards.map(&:id).sort.should == @basics.map(&:id).sort
      end
      
      it "preserves order" do
          @first_level.factory_input_cards.map(&:id).should == @basics.map(&:id)
      end
    end
   end
end