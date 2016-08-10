# -*- encoding : utf-8 -*-

describe Card::Set::Type::CoffeeScript do
  let(:coffee)                    { 'alert "Hi"  '    }
  let(:compressed_coffee)         { '(function(){alert("Hi")}).call(this);'    }
  let(:changed_coffee)            { 'alert "Hello"  ' }
  let(:compressed_changed_coffee) { '(function(){alert("Hello")}).call(this);' }

  it_should_behave_like "content machine", that_produces_js do
    let(:machine_card) do
      Card.gimme! "coffee machine", type: Card::CoffeeScriptID,
                                    content: coffee
    end
    let(:card_content) do
      { in:         coffee,
        out:        "//coffee machine\n#{compressed_coffee}",
        changed_in: changed_coffee,
        changed_out: "//coffee machine\n#{compressed_changed_coffee}" }
    end
  end

  it_behaves_like "machine input"  do
    let(:create_machine_input_card) do
      Card.gimme! "coffee input", type: :coffee_script, content: coffee
    end
    let(:create_another_machine_input_card) do
      Card.gimme! "more coffee input", type: :coffee_script, content: coffee
    end
    let(:create_machine_card) do
      Card.gimme! "coffee machine+*script", type: :pointer
    end
    let(:card_content) do
      { in:          coffee,
        out:         "//coffee input\n#{compressed_coffee}",
        changed_in:  changed_coffee,
        changed_out: "//coffee input\n#{compressed_changed_coffee}",
        added_out:   "//coffee input\n#{compressed_coffee}\n"\
                     "//more coffee input\n#{compressed_coffee}" }
    end
  end
end
