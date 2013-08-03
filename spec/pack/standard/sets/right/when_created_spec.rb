# -*- encoding : utf-8 -*-
require 'wagn/spec_helper'

describe Card::Set::Right::WhenCreated do
  it 'should produce a text date' do
    render_card( :core, :name=>'A+*when created' ).should =~ /\w+ \d+/
  end
end
