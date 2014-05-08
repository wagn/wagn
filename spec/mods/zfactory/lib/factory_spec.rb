require 'byebug'


def init_tree type, level
  Card::Auth.as_bot do
    @first_level =  Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
    last_level = false
    level.times do |i|
      next_level = Card.fetch(  "#{type} level #{@depth-i}", :new => {:type => type } )
      next_level.content = ""
      next_level << @basics[@depth-i-1]
      next_level << last_level if last_level
      next_level << @basics[@depth+i]
      next_level.save!
      last_level = next_level
    end
    @first_level << last_level
    @first_level.save!
  end
end

def init_tree_top_down type, level
  Card::Auth.as_bot do
    @first_level = last_level = Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
    level.times do |i|
      next_level = Card.fetch(  "#{type} level #{i}", :new => {:type => type } )
      last_level.content = ""
      last_level << @basics[i]
      last_level << next_level
      last_level << @basics[2*@depth-i-1]
      last_level.save!
      last_level = next_level
    end
    last_level.save!
  end
end



describe Factory do
  
  before(:all) do
    @depth = 4
    @basics = []
    Card::Auth.as_bot do
      (2*@depth).times do |i|
        @basics << Card.fetch( "basic level #{i}", :new =>  {:type => Card::BasicID } )
        @basics.last.save
      end
    end
  end

  context 'after stored' do
    before(:all) do
        name = 'a factory style test'
        @c = Card.fetch name, :new =>  { :type => :skin }
    end
    it 'creates supplies card' do
      @c.supplies_card.should_not be_nil
    end
    it 'creates prodcut card' do
      @c.product_card.should_not be_nil
    end
  end
  
  context "supplies" do
    
    context 'for skins' do
      
      it "scans all levels" do
        init_tree :skin, @depth
        @first_level.supplies_card.item_cards.map(&:id).sort.should == @basics.map(&:id).sort
      end
      it "preserves order" do
        init_tree :skin, @depth
        @first_level.supplies_card.item_cards.map(&:id).should == @basics.map(&:id)
      end
    end
    
    context 'for pointers' do
      before(:all) do
        init_tree :pointer, @depth
      end
      
      it "contains items" do
        Card::Auth.as_bot do
          css = '#box { display: block }'
          @css_card = Card.create( :name => 'my css', :type => :css, :content => css  )

          
          @skin = Card.fetch 'my factory skin',:new => { :type => Card::SkinID }
          @skin.content = ''
          @skin << @css_card
          @skin.save!
        end
        input = @skin.supplies_card.item_cards
        input.should == [@css_card]
      end
  
      it "scans all levels" do
        @first_level.supplies_card.item_cards.map(&:id).sort.should == @basics.map(&:id).sort
      end
      
      it "preserves order" do
        @first_level.supplies_card.item_cards.map(&:id).should == @basics.map(&:id)
      end
    end
  end
end