# -*- encoding : utf-8 -*-


RSpec.describe Card::Query do
  A_JOINEES = %w(B C D E F).freeze
  CARDS_MATCHING_TWO = ["Joe User", "One+Two", "One+Two+Three",
                        "script: slot+*all+*script+*machine cache",
                        "Two"].freeze

  subject do
    Card::Query.run @query.reverse_merge return: :name, sort: :name
  end

  it "does not alter original statement" do
    @query = { right_plus: { name: %w(in tag source) } }
    query_clone = @query.deep_clone
    subject # runs query
    expect(query_clone).to eq(@query)
  end

  describe "append" do
    it "finds real cards" do
      @query = {
        name: [:in, "C", "D", "F"],
        append: "A"
      }
      is_expected.to eq(%w(C+A D+A F+A))
    end

    it "absolutizes names" do
      @query = {
        name: [:in, "C", "D", "F"],
        append: "_right",
        context: "B+A"
      }
      is_expected.to eq(%w(C+A D+A F+A))
    end

    it "finds virtual cards" do
      @query = {
        name: [:in, "C", "D"],
        append: "*plus cards"
      }
      is_expected.to eq(["C+*plus cards", "D+*plus cards"])
    end
  end

  describe "in" do
    it "works for content options" do
      @query = { in: %w(AlphaBeta Theta) }
      is_expected.to eq(%w(A+B T))
    end

    it "finds the same thing in full syntax" do
      @query = { content: [:in, "Theta", "AlphaBeta"] }
      is_expected.to eq(%w(A+B T))
    end

    it "works on types" do
      @query = { type: [:in, "Cardtype E", "Cardtype F"] }
      is_expected.to eq(%w(type-e-card type-f-card))
    end
  end

  describe "member_of/member" do
    it "member_of should find members" do
      @query = { member_of: "r1" }
      is_expected.to eq(%w(u1 u2 u3))
    end

    it "member should find roles" do
      @query = { member: { match: "u1" } }
      is_expected.to eq(%w(r1 r2 r3))
    end
  end

  describe "not" do
    it "excludes cards matching not criteria" do
      Card::Auth.as_bot
      @query = { plus: "A", not: { plus: "A+B" } }
      is_expected.to eq(%w(B D E F))
    end
  end

  describe "multiple values" do
    it "handles :all as the first element of an Array" do
      @query = { member_of: [:all, { name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2))
    end

    it "handles act like :all by default" do
      @query = { member_of: [{ name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2))
    end

    it "handles :any as the first element of an Array" do
      @query = { member_of: [:any, { name: "r1" }, { key: "r2" }] }
      is_expected.to eq(%w(u1 u2 u3))
    end

    it "handles :any as a relationship" do
      @query = { member_of: { any: [{ name: "r1" }, { key: "r2" }] } }
      is_expected.to eq(%w(u1 u2 u3))
    end

    it "handles explicit conjunctions in plus_relational keys" do
      @query = { right_plus: [:all, "e", "c"] }
      is_expected.to eq(%w(A))
    end

    it "handles multiple values for right_part in compound relations" do
      @query = { right_plus: [["e", {}], "c"] }
      is_expected.to eq(%w(A)) # first element is array
    end

    it "does not interpret simple arrays as multi values for plus" do
      @query = { right_plus: %w(e c) }
      is_expected.to eq([]) # NOT interpreted as multi-value
    end

    it "handles :and for references" do
      @query = { refer_to: [:and, "a", "b"] }
      is_expected.to eq(%w(Y))
    end

    it "handles :or for references" do
      @query = { refer_to: [:or, "b", "z"] }
      is_expected.to eq(%w(A B Y))
    end

    it "handles treat simple arrays like :all for references" do
      @query = { refer_to: %w(A T) }
      is_expected.to eq(%w(X Y))
    end
  end

  describe "edited_by/editor_of" do
    it "finds card edited by joe using subquery" do
      @query = { edited_by: { match: "Joe User" } }
      is_expected.to eq(%w(JoeLater JoeNow))
    end

    it "finds card edited by Wagn Bot" do
      # this is a weak test, since it gives the name, but different sorting
      # mechanisms in other db setups
      # was having it return *account in some cases and 'A' in others
      @query = { edited_by: "Wagn Bot", name: "A" }
      is_expected.to eq(%w(A))
    end

    it "fails gracefully if user isn't there" do
      @query = { edited_by: "Joe LUser" }
      is_expected.to eq([])
    end

    it "does not give duplicate results for multiple edits" do
      c = Card["JoeNow"]
      c.content = "testagagin"
      c.save
      c.content = "test3"
      c.save!
      @query = { edited_by: "Joe User" }
      is_expected.to eq(%w(JoeLater JoeNow))
    end

    it "finds joe user among card's editors" do
      @query = { editor_of: "JoeLater" }
      is_expected.to eq(["Joe User"])
    end
  end

  describe "updated_by/updater_of" do
    it "finds card updated by Narcissist" do
      @query = { updated_by: "Narcissist" }
      is_expected.to eq(%w(Magnifier+lens))
    end

    it "finds Narcississt as the card's updater" do
      @query = { updater_of: "Magnifier+lens" }
      is_expected.to eq(%w(Narcissist))
    end

    it "does not give duplicate results for multiple updates" do
      @query = { updater_of: "First" }
      is_expected.to eq(["Wagn Bot"])
    end

    it "does not give results if not updated" do
      @query = { updater_of: "Sunglasses+price" }
      is_expected.to be_empty
    end

    it "'or' doesn't mess up updated_by SQL" do
      @query = { or: { updated_by: "Narcissist" } }
      puts Card::Query.new(@query).sql
      is_expected.to eq(%w(Magnifier+lens))
    end

    it "'or' doesn't mess up updater_of SQL" do
      @query = { or: { updater_of: "First" } }
      puts Card::Query.new(@query).sql
      is_expected.to eq(["Wagn Bot"])
    end
  end

  describe "created_by/creator_of" do
    before do
      Card.create name: "Create Test", content: "sufficiently distinctive"
    end

    it "finds Joe User as the card's creator" do
      @query = { creator_of: "Create Test" }
      is_expected.to eq(["Joe User"])
    end

    it "finds card created by Joe User" do
      @query = { created_by: "Joe User", eq: "sufficiently distinctive" }
      is_expected.to eq(["Create Test"])
    end
  end

  describe "last_edited_by/last_editor_of" do
    before do
      c = Card.fetch("A")
      c.content = "peculicious"
      c.save!
    end

    it "finds Joe User as the card's last editor" do
      @query = { last_editor_of: "A" }
      is_expected.to eq(["Joe User"])
    end

    it "finds card created by Joe User" do
      @query = { last_edited_by: "Joe User", eq: "peculicious" }
      is_expected.to eq(["A"])
    end
  end

  describe "keyword" do
    it "escapes nonword characters" do
      @query = { match: "two :(!" }
      is_expected.to eq(CARDS_MATCHING_TWO)
    end
  end

  describe "search count" do
    it "returns integer" do
      search = Card.create!(
        name: "tmpsearch",
        type: "Search",
        content: '{"match":"two"}'
      )
      expect(search.count).to eq(CARDS_MATCHING_TWO.length + 1)
    end
  end

  describe "cgi_params" do
    it "matchs content from cgi" do
      @query = { match: "$keyword", vars: { keyword: "two" } }
      is_expected.to eq(CARDS_MATCHING_TWO)
    end
  end

  describe "content equality" do
    it "matchs content explicitly" do
      @query = { content: ["=", "I'm number two"] }
      is_expected.to eq(["Joe User"])
    end

    it "matchs via shortcut" do
      @query = { "=" => "I'm number two" }
      is_expected.to eq(["Joe User"])
    end
  end

  describe "links" do
    it "handles refer_to" do
      @query = { refer_to: "Z" }
      is_expected.to eq(%w(A B))
    end

    it "handles link_to" do
      @query = { link_to: "Z" }
      is_expected.to eq(%w(A))
    end

    it "handles include" do
      @query = { include: "Z" }
      is_expected.to eq(%w(B))
    end

    it "handles linked_to_by" do
      @query = { linked_to_by: "A" }
      is_expected.to eq(%w(Z))
    end

    it "handles included_by" do
      @query = { included_by: "B" }
      is_expected.to eq(%w(Z))
    end

    it "handles referred_to_by" do
      @query = { referred_to_by: "X" }
      is_expected.to eq(%w(A A+B T))
    end
  end

  describe "compound relationships" do
    it "right_plus should handle subqueries" do
      @query = { right_plus: ["*create", refer_to: "Anyone"] }
      is_expected.to eq(["Fruit+*type", "Sign up+*type"])
    end

    it "plus should handle subqueries" do # albeit more slowly :)
      @query = { plus: ["*create", refer_to: "Anyone"] }
      is_expected.to eq(["Fruit+*type", "Sign up+*type"])
    end
  end

  describe "relative links" do
    it "handles relative refer_to" do
      @query = { refer_to: "_self", context: "Z" }
      is_expected.to eq(%w(A B))
    end
  end

  describe "permissions" do
    it "does not find cards not in group" do
      Card::Auth.as_bot do
        Card.create name: "C+*self+*read", type: "Pointer", content: "[[R1]]"
      end
      @query = { plus: "A" }
      is_expected.to eq(%w(B D E F))
    end
  end

  describe "basics" do
    it "is case insensitive for name" do
      @query = { name: "a" }
      is_expected.to eq(["A"])
    end

    it "finds plus cards" do
      @query = { plus: "A" }
      is_expected.to eq(A_JOINEES)
    end

    it "finds connection cards" do
      @query = { part: "A" }
      is_expected.to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
    end

    it "finds left connection cards" do
      @query = { left: "A" }
      is_expected.to eq(%w(A+B A+C A+D A+E))
    end

    it "finds right connection cards based on name" do
      @query = { right: "A" }
      is_expected.to eq(%w(C+A D+A F+A))
    end

    it "finds right connection cards based on content" do
      @query = { right: { content: "Alpha [[Z]]" } }
      is_expected.to eq(%w(C+A D+A F+A))
    end

    it "returns count" do
      expect(Card.count_by_wql part: "A").to eq(7)
    end
  end

  describe "limit and offset" do
    it "returns limit" do
      @query = { part: "A", limit: 5 }
      expect(subject.size).to eq(5)
    end

    it "does not break if offset but no limit" do
      @query = { part: "A", offset: 5 }
      expect(subject.size).not_to eq(0)
    end

    it "does not break count" do
      query = { match: "two", offset: 1 }
      expect(Card.count_by_wql(query)).to eq(CARDS_MATCHING_TWO.length)
    end
  end

  describe "type" do
    user_cards = [
      "Big Brother", "Joe Admin", "Joe Camel", "Joe User", "John",
      "Narcissist", "No Count", "Optic fan", "Sample User", "Sara",
      "Sunglasses fan", "u1", "u2", "u3"
    ].sort

    it "finds cards of this type" do
      @query = { type: "_self", context: "User" }
      is_expected.to eq(user_cards)
    end

    it "finds User cards " do
      @query = { type: "User" }
      is_expected.to eq(user_cards)
    end

    it "handles casespace variants" do
      @query = { type: "users" }
      is_expected.to eq(user_cards)
    end
  end

  describe "trash handling" do
    it "does not find cards in the trash" do
      Card["A+B"].delete!
      @query = { left: "A" }
      is_expected.to eq(["A+C", "A+D", "A+E"])
    end
  end

  describe "order" do
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

  describe "match" do
    it "reachs content and name via shortcut" do
      @query = { match: "two" }
      is_expected.to eq(CARDS_MATCHING_TWO)
    end

    it "gets only content when content is explicit" do
      @query = { content: [:match, "two"] }
      is_expected.to eq(["Joe User", "script: ace+*all+*script+*machine cache",
                         "script: slot+*all+*script+*machine cache"])
    end

    it "gets only name when name is explicit" do
      @query = { name: [:match, "two"] }
      is_expected.to eq(["One+Two", "One+Two+Three", "Two"])
    end
  end

  describe "and" do
    it "acts as a simple passthrough with operators" do
      @query = { and: { match: "two" } }
      is_expected.to eq(CARDS_MATCHING_TWO)
    end

    it "acts as a simple passthrough with relationships" do
      @query = { and: {}, type: "Cardtype E" }
      is_expected.to eq(["type-e-card"])
    end

    it 'works within "or"' do
      @query = { or: { name: "Z", and: { left: "A", right: "C" } } }
      is_expected.to eq(["A+C", "Z"])
    end
  end

  describe "any" do
    it "works with :plus" do
      @query = { plus: "A", any: { name: "B", match: "K" } }
      is_expected.to eq(["B"])
    end

    it "works with multiple plusses" do
      @query = { or: { right_plus: "A", plus: "B" } }
      is_expected.to eq(%w(A C D F))
    end
  end

  describe "found_by" do
    before do
      Card::Auth.as_bot
      Card.create(
        name: "Simple Search", type: "Search", content: '{"name":"A"}'
      )
    end

    it "finds cards returned by search of given name" do
      @query = { found_by: "Simple Search" }
      is_expected.to eq(["A"])
    end

    it "finds cards returned by virtual cards" do
      image_cards = Card.search type: "Image", return: :name, sort: :name
      @query = { found_by: "Image+*type+by name" }
      is_expected.to eq(image_cards)
    end

    it "plays nicely with other properties and relationships" do
      explicit_query = { plus: { name: "A" }, return: :name, sort: :name }
      @query = { plus: { found_by: "Simple Search" } }
      is_expected.to eq(Card::Query.run(explicit_query))
    end

    it "plays work with virtual cards" do
      @query = { found_by: "A+*self", plus: "C" }
      is_expected.to eq(["A"])
    end

    it "is able to handle _self" do
      @query = {
        context: "Simple Search",
        left: { found_by: "_self" },
        right: "B",
        return: :name
      }
      is_expected.to eq(["A+B"])
    end
  end

  describe "relative" do
    it "cleans wql" do
      query = Card::Query.new(part: "_self", context: "A")
      expect(query.statement[:part]).to eq("A")
    end

    it "finds connection cards" do
      @query = { part: "_self", context: "A" }
      is_expected.to eq(%w(A+B A+C A+D A+E C+A D+A F+A))
    end

    it "is able to use parts of nonexistent cards in search" do
      expect(Card["B+A"]).to be_nil
      @query = { left: "_right", right: "_left", context: "B+A" }
      is_expected.to eq(["A+B"])
    end

    it "finds plus cards for _self" do
      @query = { plus: "_self", context: "A" }
      is_expected.to eq(A_JOINEES)
    end

    it "finds plus cards for _left" do
      @query = { plus: "_left", context: "A+B" }
      is_expected.to eq(A_JOINEES)
    end

    it "finds plus cards for _right" do
      @query = { plus: "_right", context: "C+A" }
      is_expected.to eq(A_JOINEES)
    end
  end

  describe "nested permissions" do
    it "are generated by default" do
      perm_count = 0
      sql = Card::Query.new(left: { name: "X" }).sql
      sql.scan(/read_rule_id IN \([\d\,]+\)/) do
        perm_count += 1
      end
      expect(perm_count).to eq(2)
    end
  end

  describe "return part of name" do
    subject do
      Card::Query.run right: "C", return: @return, sort: :name
    end
    it "handles _left" do
      @return = "_left"
      is_expected.to eq %w(A+B A)
    end

    it "handles _right" do
      @return = "_right"
      is_expected.to eq %w(C C)
    end

    it "handles _LL" do
      @return = "_LL"
      is_expected.to eq ["A", ""]
    end
  end
end
