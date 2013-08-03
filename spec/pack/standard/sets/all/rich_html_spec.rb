# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::All::RichHtml do
  context :missing do
    it "should prompt to add" do
      render_content('{{+cardipoo|open}}').match(/Add \<span/ ).should_not be_nil
    end
  end
end
