# -*- encoding : utf-8 -*-

describe Card::Set::Right::Script do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }
  let(:new_js)                { 'alert( "Hey" );'   }
  let(:compressed_new_js)     { 'alert("Hey");'   }

  it_should_behave_like 'pointer machine', that_produces_js do
    let(:machine_card)  { Card.gimme! 'test my style+*script', type: :pointer, content: '' }
    let(:machine_input_card) { Card.gimme! 'test js',  type: Card::JavaScriptID, content: js  }
    let(:another_machine_input_card) { Card.gimme! 'more js',  type: Card::JavaScriptID, content: new_js  }
    let(:expected_input_items) { nil }
    let(:input_type) { :java_script }
    let(:card_content) do
      { in:           js,         out:     compressed_js,
        changed_in:   changed_js, changed_out: compressed_changed_js,
        new_in:       new_js,     new_out:     compressed_new_js
      }
    end
  end
end
