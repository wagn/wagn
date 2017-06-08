# -*- encoding : utf-8 -*-

describe Card::Set::Self::Search do
  def keyword_search value
    Card::Env.params[:vars] = { keyword: value }
    Card[:search].format.search_with_params
  end

  it "processes wql" do
    expect(keyword_search('{"type":"user"}')).to include Card["Joe User"]
  end
end
