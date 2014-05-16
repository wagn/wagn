# -*- encoding : utf-8 -*-

load 'spec/mods/standard/lib/machine_spec.rb'

describe Card::Set::Right::Style do
#  describe "#delet"
#  it "should delete tempfile"
  let(:skin_card)              { Card.gimme! "test skin", :type => :skin, :content => '[[test css]]'}
  let(:css)                    { "#box { display: block }"  }
  let(:compressed_css)         { "#box{display:block}\n"    }
  let(:changed_css)            { "#box { display: inline }" }
  let(:compressed_changed_css) { "#box{display:inline}\n"   }
  
  
  it_should_behave_like 'pointer machine', that_produces_css do
    let(:machine_card)  { Card.gimme! "test my style+*style", :type => :pointer, :content => '[[test skin]]'}
    let(:machine_input_card) { Card.gimme! "test css",  :type => :css, :content => css  }
    let(:card_content) do
       { in:       css,         out:     compressed_css, 
         new_in:   changed_css, new_out: compressed_changed_css }
    end
  end
end
