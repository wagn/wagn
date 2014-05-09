require 'byebug'

alias :old_method_missing :method_missing
def that_produces type
  type
end

def method_missing m, *args, &block
  case m
  when /that_produces_(.+)/
    return $1
  else
    old_method_missing m, args, block
  end
end


shared_examples_for 'a factory' do |filetype|
  context "when created" do
    it 'has a supplies card' do
      factory.supplies_card.should_not be_nil
    end
    it 'has a product card' do
      factory.product_card.should_not be_nil
    end
    it "generates #{filetype} file" do
      path = factory.product_card.attach.path
      path.should match "\.#{filetype}$"
    end
  end
end

shared_examples_for 'a content card factory' do |filetype|
  it_should_behave_like 'a factory', that_produces(filetype) do
    let(:factory) { factory_card }
  end
  
  context 'supplies card' do
    it "points to self" do
      factory_card.supplies_card.item_cards.should == [factory_card]
    end
  end
  
  context 'product card' do
    it 'creates file with supplied content' do
      changed_path = factory_card.product_card.attach.path
      File.open(changed_path) { |f| f.readlines.should == [card_content[:out]] }
    end
    it "updates #{filetype} file when content is changed" do
      changed_factory = factory_card
      changed_factory.putty :content =>card_content[:new_in]
      changed_path = changed_factory.product_card.attach.path
      File.open(changed_path) { |f| f.readlines.should == [card_content[:new_out]] }
    end
  end
end


shared_examples_for 'a pointer card factory' do |filetype|
  subject do
    change_factory = factory_card
    @depth = 4
    @expected_items = []
    Card::Auth.as_bot do
      (2*@depth).times do |i|
        @expected_items << Card.fetch( "basic level #{i}", :new =>  {:type => Card::BasicID } )
        @expected_items.last.save
      end
      last_level = false
      @depth.times do |i|
        next_level = Card.fetch(  "#{filetype} level #{@depth-i}", :new => {:type => :pointer } )
        next_level.content = ""
        next_level << @expected_items[@depth-i-1]
        next_level << last_level if last_level
        next_level << @expected_items[@depth+i]
        next_level.save!
        last_level = next_level
      end
      change_factory << last_level
      change_factory << supplier_card
      @expected_items << supplier_card
      change_factory.save!
    end
    change_factory
  end

  it_should_behave_like 'a factory', that_produces(filetype) do
    let(:factory) { factory_card }
  end
  
  describe 'supplies card' do
    it "contains items of all levels" do
      subject.supplies_card.item_cards.map(&:id).sort.should == @expected_items.map(&:id).sort
    end
    
    it "preserves order of items" do
      subject.supplies_card.item_cards.map(&:id).should == @expected_items.map(&:id)
    end
  end
  
  describe 'product card' do
    it 'creates #{filetype} file with supplied content' do
      path = subject.product_card.attach.path
      File.open(path) { |f| f.readlines.should == [card_content[:out]] }
    end
    
    it 'updates #{filetype} file if item is changed' do
      supplier_card.putty :content => card_content[:new_in]
      changed_path = subject.product_card.attach.path
      File.open(changed_path) { |f| f.readlines.should == [card_content[:new_out]] }
      change_factory = factory_card
    end
  end
end

# def init_tree type, level
#   Card::Auth.as_bot do
#     @first_level =  Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
#     last_level = false
#     level.times do |i|
#       next_level = Card.fetch(  "#{type} level #{@depth-i}", :new => {:type => type } )
#       next_level.content = ""
#       next_level << @basics[@depth-i-1]
#       next_level << last_level if last_level
#       next_level << @basics[@depth+i]
#       next_level.save!
#       last_level = next_level
#     end
#     @first_level << last_level
#     @first_level.save!
#   end
# end
# 
# def init_tree_top_down type, level
#   Card::Auth.as_bot do
#     @first_level = last_level = Card.fetch(  'my nested #{type}', :new => {:type => Card::SkinID } )
#     level.times do |i|
#       next_level = Card.fetch(  "#{type} level #{i}", :new => {:type => type } )
#       last_level.content = ""
#       last_level << @basics[i]
#       last_level << next_level
#       last_level << @basics[2*@depth-i-1]
#       last_level.save!
#       last_level = next_level
#     end
#     last_level.save!
#   end
# end
# 
# 
# 
# describe Factory do
#   
#   before(:all) do
#     @depth = 4
#     @basics = []
#     Card::Auth.as_bot do
#       (2*@depth).times do |i|
#         @basics << Card.fetch( "basic level #{i}", :new =>  {:type => Card::BasicID } )
#         @basics.last.save
#       end
#     end
#   end
#   
#   context 'after stored' do
#     before(:all) do
#         name = 'a factory style test'
#         @c = Card.fetch name, :new =>  { :type => :skin }
#     end
#     it 'creates supplies card' do
#       @c.supplies_card.should_not be_nil
#     end
#     it 'creates product card' do
#       @c.product_card.should_not be_nil
#     end
#   end
#   
#   context "supplies" do
#     
#     context 'for skins' do
#       
#       it "scans all levels" do
#         init_tree :skin, @depth
#         @first_level.supplies_card.item_cards.map(&:id).sort.should == @basics.map(&:id).sort
#       end
#       it "preserves order" do
#         init_tree :skin, @depth
#         @first_level.supplies_card.item_cards.map(&:id).should == @basics.map(&:id)
#       end
#     end
#     
#    
#   end
# end