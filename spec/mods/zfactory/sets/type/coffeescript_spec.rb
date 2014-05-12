load 'spec/mods/zfactory/lib/factory_spec.rb'
load 'spec/mods/zfactory/lib/supplier_spec.rb'

describe Card::Set::Type::Coffeescript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }


  it_should_behave_like 'a content card factory', that_produces_js do
    let(:factory_card)  { Card.gimme! "test coffeescript", :type => Card::CoffeescriptID, :content => coffee}
    let(:card_content) do
       { in:       coffee,         out:     compressed_coffee, 
         new_in:   changed_coffee, new_out: compressed_changed_coffee }
    end
  end

  it_behaves_like "a supplier"  do
    let(:create_supplier_card) { Card.gimme! "test coffeescript", :type => :coffeescript, :content => coffee }
    let(:create_factory_card)  { Card.gimme! "script with coffee+*script", :type => :pointer }
    let(:card_content) do
       { in:       coffee,         out:     compressed_coffee, 
         new_in:   changed_coffee, new_out: compressed_changed_coffee }
    end
  end

end