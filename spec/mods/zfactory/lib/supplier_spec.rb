require 'byebug'

class Card
  def self.gimme name, args = {}
    Card::Auth.as_bot do
      Card.fetch( name, :new => args )
    end
  end
  
  def putty args = {}
    Card::Auth.as_bot do
      if args.present? 
        update_attributes! (args) 
      else 
        save!
      end
    end
  end
end


describe Supplier do
  it 'responds to deliver' do
    card = Card.gimme "test css", :type => :css 
    card.should respond_to(:deliver)
  end
  
  it 'delivers card content' do
    css  = '#box { display: block }'
    supplier = Card.gimme "supplier", :type => :css 
    supplier.putty :content => css
    supplier.deliver.should == "#box{display:block}\n"
  end

  it 'updates factories' do
    css = '#box { display: block }'
    compressed_css =  "#box{display:block}\n"
    changed_css = '#box { display: inline }'
    changed_compressed_css = "#box{display:inline}\n"
    
    supplier = Card.gimme  "supplier", :type => :css
    supplier.putty content: css
    factory = Card.gimme 'supplied factory', :type => :skin
    factory << supplier
    factory.putty
    path = factory.product_card.attach.path
    File.open(path) { |f| f.readlines.should == [compressed_css] }
    
    supplier = Card.gimme "supplier"
    supplier.putty :content => changed_css
    factory = Card.gimme "supplied factory"
    changed_path = factory.product_card.attach.path
    changed_path.should_not == path
    File.open(changed_path) { |f| f.readlines.should == [changed_compressed_css] }
  end
end