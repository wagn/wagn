# -*- encoding : utf-8 -*-

load 'spec/mods/zfactory/lib/factory_spec.rb'

describe Card::Set::Right::Script do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }
  
  
  it_should_behave_like 'a pointer card factory', that_produces_js do
    let(:factory_card)  { Card.gimme! "test my style+*script", :type => :pointer, :content => ''}
    let(:supplier_card) { Card.gimme! "test js",  :type => Card::JavascriptID, :content => js  }
    let(:card_content) do
       { in:       js,         out:     compressed_js, 
         new_in:   changed_js, new_out: compressed_changed_js }
    end
  end
end
