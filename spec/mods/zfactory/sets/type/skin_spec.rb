# -*- encoding : utf-8 -*-

load 'spec/mods/zfactory/lib/factory_spec.rb'

describe Card::Set::Type::Skin do
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  
  
  it_should_behave_like 'a pointer card factory', that_produces_css do
    let(:factory_card)  { Card.gimme "test skin factory", :type => :skin, :content => ''}
    let(:supplier_card) { c = Card.gimme("test skin supply",  :type => :css, :content => css); c.putty; c  }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
end
