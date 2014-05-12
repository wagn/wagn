load 'spec/mods/zfactory/lib/factory_spec.rb'
load 'spec/mods/zfactory/lib/supplier_spec.rb'

describe Card::Set::Type::Javascript do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }


  it_should_behave_like 'a content card factory', that_produces_js do
    let(:factory_card)  { Card.gimme! "test javascript", :type => :javascript, :content => js}
    let(:card_content) do
       { in:       js,         out:     compressed_js, 
         new_in:   changed_js, new_out: compressed_changed_js }
    end
  end

  it_behaves_like "a supplier"  do
    let(:create_supplier_card) { Card.gimme! "test javascript", :type => :javascript, :content => js }
    let(:create_factory_card)  { Card.gimme! "script with js+*script", :type => :pointer }
    let(:card_content) do
       { in:       js,         out:     compressed_js, 
         new_in:   changed_js, new_out: compressed_changed_js }
    end
  end

end