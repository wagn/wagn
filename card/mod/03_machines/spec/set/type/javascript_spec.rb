# -*- encoding : utf-8 -*-

describe Card::Set::Type::JavaScript do
  let(:js)                    { 'alert( "Hi" );'    }
  let(:compressed_js)         { 'alert("Hi");'      }
  let(:changed_js)            { 'alert( "Hello" );' }
  let(:compressed_changed_js) { 'alert("Hello");'   }

  def comment_with_source

  end

  it_should_behave_like "content machine", that_produces_js do
    let(:machine_card) do
      Card.gimme! "test javascript", type: :java_script, content: js
    end
    let(:card_content) do
      { in:          js,
        out:         "//test javascript\n#{compressed_js}",
        changed_in:  changed_js,
        changed_out: "//test javascript\n#{compressed_changed_js}" }
    end
  end

  it_behaves_like "machine input" do
    let(:create_machine_input_card) do
      Card.gimme! "test javascript", type: :java_script, content: js
    end
    let(:create_another_machine_input_card) do
      Card.gimme! "more javascript", type: :java_script, content: js
    end
    let(:create_machine_card) do
      Card.gimme! "script with js+*script", type: :pointer
    end
    let(:card_content) do
      { in:          js,
        out:         "//test javascript\n#{compressed_js}",
        changed_in:  changed_js,
        changed_out:  "//test javascript\n#{compressed_changed_js}",
        added_out:   "//test javascript\n#{compressed_js}\n"\
                     "//more javascript\n#{compressed_js}" }
    end
  end
end
