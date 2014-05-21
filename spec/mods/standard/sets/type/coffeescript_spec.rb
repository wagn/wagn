# load 'spec/mods/zfactory/lib/machine_spec.rb'
# load 'spec/mods/zfactory/lib/machine_input_spec.rb'

describe Card::Set::Type::CoffeeScript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }


  it_should_behave_like 'content machine', that_produces_js do
    let(:machine_card)  { Card.gimme! "test coffeescript", :type => Card::CoffeeScriptID, :content => coffee}
    let(:card_content) do
       { in:       coffee,         out:     compressed_coffee, 
         new_in:   changed_coffee, new_out: compressed_changed_coffee }
    end
  end

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) { Card.gimme! "test coffeescript", :type => :coffee_script, :content => coffee }
    let(:create_machine_card)  { Card.gimme! "script with coffee+*script", :type => :pointer }
    let(:card_content) do
       { in:       coffee,         out:     compressed_coffee, 
         new_in:   changed_coffee, new_out: compressed_changed_coffee }
    end
  end

end