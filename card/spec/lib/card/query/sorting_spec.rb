describe Card::Query, "sorting" do
  subject do
    Card::Query.run @query.reverse_merge return: :name, sort: :name
  end

  it "sorts by create" do
    Card.create! name: "classic bootstrap skin head"
    # classic skin head is created more recently than classic skin,
    # which is in the seed data
    @query = { sort: "create", name: [:match, "classic bootstrap skin"] }
    is_expected.to eq(
                     ["classic bootstrap skin", "classic bootstrap skin head"]
                   )
  end

  it "sorts by name" do
    @query = { name: %w(in B Z A Y C X), sort: "name", dir: "desc" }
    is_expected.to eq(%w(Z Y X C B A))
  end

  it "sorts by content" do
    @query = { name: %w(in Z T A), sort: "content" }
    is_expected.to eq(%w(A Z T))
  end

  it "plays nice with match" do
    @query = { match: "Z", type: "Basic", sort: "content" }
    is_expected.to eq(%w(A B Z))
  end

  it "sorts by plus card content" do
    Card::Auth.as_bot do
      c = Card.fetch("Setting+*self+*table of contents")
      c.content = "10"
      c.save
      Card.create! name: "Basic+*type+*table of contents", content: "3"

      @query = {
        right_plus: "*table of contents",
        sort: { right: "*table_of_contents" },
        sort_as: "integer"
      }
      is_expected.to eq(%w(*all Basic+*type Setting+*self))
    end
  end

  it "sorts by count" do
    Card::Auth.as_bot do
      @query = {
        name: [:in, "*always", "*never", "*edited"],
        sort: { right: "*follow", item: "referred_to", return: "count" }
      }
      is_expected.to eq(["*never", "*edited", "*always"])
    end
  end

  #  it 'sorts by update' do
  #    # do this on a restricted set so it won't change every time we
  #    #  add a card..
  #    Card::Query.run(
  #    match: 'two', sort: 'update', dir: 'desc'
  #    ).map(&:name).should == ['One+Two+Three', 'One+Two','Two','Joe User']
  #    Card['Two'].update_attributes! content: 'new bar'
  #    Card::Query.run(
  #    match: 'two', sort: 'update', dir: 'desc'
  #    ).map(&:name).should == ['Two','One+Two+Three', 'One+Two','Joe User']
  #  end
end
