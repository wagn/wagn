# -*- encoding : utf-8 -*-

load 'spec/mods/zfactory/lib/factory_spec.rb'
load 'spec/mods/zfactory/lib/supplier_spec.rb'

describe Card::Set::Type::Skin do
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  
  
  it_should_behave_like 'a pointer card factory', that_produces_css do
    let(:factory_card)  { Card.gimme! "test skin factory", :type => :skin, :content => ''}
    let(:supplier_card) { Card.gimme! "test skin supplier",  :type => :css, :content => css  }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
  
  it_behaves_like "a supplier"  do
    let(:create_supplier_card) { Card.gimme! "test skin supplier", :type => :css, :content => css }
    let(:create_factory_card)  { Card.gimme! "style with skin factory+*style", :type => :pointer }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
end
