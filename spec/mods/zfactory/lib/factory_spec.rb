require 'byebug'

def safe_create name, args = {}
  Card::Auth.as_bot do
    if c = Card.fetch( name )
      c.delete!
    end
    if c = Card.fetch( "#{name}+supplies" )
      c.delete!
    end 
    if c = Card.fetch( "#{name}+product" )
      c.delete!
    end
    Card.create!( {:name => name}.merge( args ) )
  end
end


def safe_new name, args = {}
  Card::Auth.as_bot do
    if c = Card.fetch( name )
      c.delete!
    end
    if c = Card.fetch( "#{name}+supplies" )
      c.delete!
    end 
    if c = Card.fetch( "#{name}+product" )
      c.delete!
    end
    Card.fetch( name, :new => args )
  end
end

def init_tree type
  Card::Auth.as_bot do
    #@first_level = last_level = safe_create 'my nested pointer', :type => Card::SkinID
    #@depth.times do |i|
    #  next_level = safe_create "pointer level #{i}", :type => Card::PointerID
    #end
    @first_level =  Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
    last_level = false
    @depth.times do |i|
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

def init_tree_top_down type
  Card::Auth.as_bot do
    #@first_level = last_level = safe_create 'my nested pointer', :type => Card::SkinID
    #@depth.times do |i|
    #  next_level = safe_create "pointer level #{i}", :type => Card::PointerID
    #end
    @first_level = last_level = Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
    @depth.times do |i|
      next_level = Card.fetch(  "#{type} level #{i}", :new => {:type => type } )
      last_level.content = ""
      last_level << @basics[i]
      last_level << next_level
      last_level << @basics[2*@depth-i-1]
      last_level.save!
      #@garbage << last_level
      last_level = next_level
    end
    last_level.save!
    #@garbage << last_level
  end
end



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
    #@garbage = []
  end
  
  after(:all) do
    #@garbage += @basics
    #Card::Auth.as_bot do
    #  @garbage.each do |item|
#        item.delete!
      #   if c = Card.fetch("#{item.name}+supplies")
      #     c.delete!
      #   end
      #   if c = Card.fetch("#{item.name}+product")
      #     c.delete!
      #   end
      # end
      #end
  end

  context 'after stored' do
    before(:all) do
        name = 'a factory style test'
        #@c = safe_create name,  :type => :skin 
        @c = Card.fetch name, :new =>  { :type => :skin }
        #@garbage << @c
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
        init_tree :skin
        @first_level.supplies_card.item_cards.map(&:id).sort.should == @basics.map(&:id).sort
      end
      it "preserves order" do
        init_tree :skin
        @first_level.supplies_card.item_cards.map(&:id).should == @basics.map(&:id)
      end
    end
    
    context 'for pointers' do
      before(:all) do
        init_tree :pointer
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