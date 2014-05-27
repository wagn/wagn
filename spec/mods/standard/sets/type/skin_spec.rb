# -*- encoding : utf-8 -*-

describe Card::Set::Type::Skin do
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  
  
  it_should_behave_like 'pointer machine', that_produces_css do
    let(:machine_card)  { Card.gimme! "test skin factory", :type => :skin, :content => ''}
    let(:machine_input_card) { Card.gimme! "test skin supplier",  :type => :css, :content => css  }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
  
  it_behaves_like "machine input"  do
    let(:create_machine_input_card) { Card.gimme! "test skin supplier", :type => :css, :content => css }
    let(:create_machine_card)  { Card.gimme! "style with skin factory+*style", :type => :pointer }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
end
