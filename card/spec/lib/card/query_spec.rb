# -*- encoding : utf-8 -*-

A_JOINEES = %w{ B C D E F }

CARDS_MATCHING_TWO = ['Joe User', 'One+Two', 'One+Two+Three', 'Two']

describe Card::Query do

  describe 'append' do
    it 'should find real cards' do
      expect(Card::Query.run(
        name: [:in, 'C', 'D', 'F'],
        append: 'A'
      ).map(&:name).sort).to eq(
        ['C+A', 'D+A', 'F+A']
      )
    end

    it 'should absolutize names' do
      expect(Card::Query.run(
        name: [:in, 'C', 'D', 'F'],
        append: '_right',
        context: 'B+A'
      ).map(&:name).sort).to eq(
        ['C+A', 'D+A', 'F+A']
      )
    end

    it 'should find virtual cards' do
      expect(Card::Query.run(
        name: [:in, 'C', 'D'],
        append: '*plus cards'
      ).map(&:name).sort).to eq(
        ['C+*plus cards', 'D+*plus cards']
      )
    end
  end

  describe 'in' do
    it 'should work for content options' do
      expect(Card::Query.run(
        in: ['AlphaBeta', 'Theta']
      ).map(&:name).sort).to eq(
        %w(A+B T)
      )
    end

    it 'should find the same thing in full syntax' do
      expect(Card::Query.run(
        content: [:in,'Theta','AlphaBeta']
      ).map(&:name).sort).to eq(
        %w(A+B T)
      )
    end

    it 'should work on types' do
      expect(Card::Query.run(
        type: [:in,'Cardtype E', 'Cardtype F']
      ).map(&:name).sort).to eq(
        %w(type-e-card type-f-card)
      )
    end
  end


  describe 'member_of/member' do
    it 'member_of should find members' do
      expect(Card::Query.run(
        member_of: 'r1'
      ).map(&:name).sort).to eq(
        %w(u1 u2 u3)
      )
    end
    it 'member should find roles' do
      expect(Card::Query.run(
        member: { match: 'u1' }
      ).map(&:name).sort).to eq(
        %w(r1 r2 r3)
      )
    end
  end


  describe 'not' do
    it 'should exclude cards matching not criteria' do
      expect(Card::Query.run(
        plus: 'A', not: {plus: 'A+B'}
      ).map(&:name).sort).to eq(
        %w{ B D E F }
      )
    end
  end

  describe 'multiple values' do
    it 'should handle multiple values for relational keys' do
      expect(Card::Query.run(
        member_of: [:all, { name: 'r1' }, { key: 'r2' }], return: :name
      ).sort).to eq(
        %w{ u1 u2 }
      )

      expect(Card::Query.run(
        member_of: [{ name: 'r1' }, { key: 'r2' }], return: :name
      ).sort).to eq(
        %w{ u1 u2 }
      )

      expect(Card::Query.run(
        member_of: { any: [{ name: 'r1' }, { key: 'r2' }] }, return: :name
      ).sort).to eq(
        %w{ u1 u2 u3 }
      )

      expect(Card::Query.run(
        member_of: [:any, { name: 'r1' }, { key: 'r2' } ], return: :name
      ).sort).to eq(
        %w{ u1 u2 u3 }
      )
    end

    it 'should handle multiple values for plus_relational keys' do
      expect(Card::Query.run(
        right_plus: [:all, 'e', 'c'],
        return: :name
      ).sort).to eq(
        %w{ A }
      ) #explicit conjunction

      expect(Card::Query.run(
        right_plus: [['e',{}], 'c' ], return: :name
      ).sort).to eq(
        %w{ A }
      ) # first element is array

      expect(Card::Query.run(
        right_plus: ['e', 'c'], return: :name
      ).sort).to eq(
        []
      ) # NOT interpreted as multi-value
    end

    it 'should handle multiple values for plus_relational keys' do
      expect(Card::Query.run(
        refer_to: [:and, 'a', 'b'], return: :name
      ).sort).to eq(
        %w{ Y }
      )

      expect(Card::Query.run(
        refer_to: ['a', 'T'], return: :name
      ).sort).to eq(
        %w{ X Y }
      )

      expect(Card::Query.run(
        refer_to: [:or,  'b', 'z'], return: :name
      ).sort).to eq(
        %w{ A B Y}
      )
    end

  end


  describe 'edited_by/editor_of' do
    it 'should find card edited by joe using subquery' do
      expect(Card::Query.run(
        edited_by: { match: 'Joe User' }, sort: 'name'
      )).to include(
        Card['JoeLater'], Card['JoeNow']
      )
    end

    it 'should find card edited by Wagn Bot' do
      #this is a weak test, since it gives the name, but different sorting mechanisms in other db setups
      #was having it return *account in some cases and 'A' in others
      expect(Card::Query.run(
        edited_by: 'Wagn Bot', name: 'A', return: 'name', limit: 1
      ).first).to eq(
        'A'
      )
    end

    it 'should fail gracefully if user isn\'t there' do
      expect(Card::Query.run(
        edited_by: 'Joe LUser', sort: 'name', limit: 1
      )).to eq(
        []
      )
    end

    it 'should not give duplicate results for multiple edits' do
      c=Card['JoeNow']
      c.content = 'testagagin'
      c.save
      c.content = 'test3'
      c.save!
      expect(Card::Query.run(
        edited_by: 'Joe User'
      ).map(&:name).count('JoeNow')).to eq 1
    end

    it 'should find joe user among card\'s editors' do
      expect(Card::Query.run(
        editor_of: 'JoeLater'
      ).map(&:name)).to eq(
        ['Joe User']
      )
    end
  end

  describe 'created_by/creator_of' do
    before do
      Card.create name: 'Create Test', content: 'sufficiently distinctive'
    end

    it "should find Joe User as the card's creator" do
      c = Card.fetch 'Create Test'
      expect(Card::Query.run(
        creator_of: 'Create Test'
      ).first.name).to eq(
        'Joe User'
      )
    end

    it 'should find card created by Joe User' do
      expect(Card::Query.run(
        created_by: 'Joe User', eq: 'sufficiently distinctive'
      ).first.name).to eq(
        'Create Test'
      )
    end
  end

  describe 'last_edited_by/last_editor_of' do
    before do
      c=Card.fetch('A')
      c.content='peculicious'
      c.save!
    end

    it "should find Joe User as the card's last editor" do
      expect(Card::Query.run(
        last_editor_of: 'A'
      ).first.name).to eq(
        'Joe User'
      )
    end

    it 'should find card created by Joe User' do
      expect(Card::Query.run(
        last_edited_by: 'Joe User', eq: 'peculicious'
      ).first.name).to eq(
        'A'
      )
    end
  end

  describe 'keyword' do
    it 'should escape nonword characters' do
      expect(Card::Query.run(
        match: 'two :(!'
      ).map(&:name).sort).to eq(
        CARDS_MATCHING_TWO
      )
    end
  end

  describe 'search count' do
    it 'should return integer' do
      keyword_search = Card.create!(
        name: 'ksearch', type: 'Search', content: '{"match":"$keyword"}'
      )
      expect(keyword_search.count(
        vars: {keyword: 'two'}
      )).to eq(
        CARDS_MATCHING_TWO.length
      )
    end
  end

  describe 'cgi_params' do
    it 'should match content from cgi' do
      expect(Card::Query.run(
        match: '$keyword', vars: {keyword: 'two'}
      ).map(&:name).sort).to eq(
        CARDS_MATCHING_TWO
      )
    end
  end

  describe 'content equality' do
    it 'should match content explicitly' do
      expect(Card::Query.run(
        content: ['=',"I'm number two"]
      ).map(&:name)).to eq(
        ['Joe User']
      )
    end

    it 'should match via shortcut' do
      expect(Card::Query.run(
        '='=>"I'm number two"
      ).map(&:name)).to eq(
        ['Joe User']
      )
    end
  end

  describe 'links' do
    it 'should handle refer_to' do
      expect(Card::Query.run(
        refer_to: 'Z'
      ).map(&:name).sort).to eq(
        %w{ A B }
      )
    end

    it 'should handle link_to' do
      expect(Card::Query.run(
        link_to: 'Z'
      ).map(&:name)).to eq(
        %w{ A }
      )
    end

    it 'should handle include' do
      expect(Card::Query.run(
        include: 'Z'
      ).map(&:name)).to eq(
        %w{ B }
      )
    end

    it 'should handle linked_to_by' do
      expect(Card::Query.run(
        linked_to_by: 'A'
      ).map(&:name)).to eq(
        %w{ Z }
      )
    end

    it 'should handle included_by' do
      expect(Card::Query.run(
        included_by: 'B'
      ).map(&:name)).to eq(
        %w{ Z }
      )
    end

    it 'should handle referred_to_by' do
      expect(Card::Query.run(
        referred_to_by: 'X'
      ).map(&:name).sort).to eq(
        %w{ A A+B T }
      )
    end
  end

  describe 'relative links' do
    it('should handle relative refer_to')  { expect(Card::Query.run(
      refer_to: '_self', context: 'Z'
      ).map(&:name).sort).to eq(%w{ A B }) }
  end

  describe 'permissions' do
    it 'should not find cards not in group' do
      Card::Auth.as_bot  do
        Card.create name: 'C+*self+*read', type: 'Pointer', content: '[[R1]]'
      end
      expect(Card::Query.run(
        plus: 'A'
      ).map(&:name).sort).to eq(
        %w{ B D E F }
      )
    end
  end

  describe 'basics' do
    it 'should be case insensitive for name' do
      expect(Card::Query.run(
        name: 'a'
      ).first.name).to eq(
        'A'
      )
    end

    it 'should find plus cards' do
      expect(Card::Query.run(
        plus: 'A'
      ).map(&:name).sort).to eq(
        A_JOINEES
      )
    end

    it 'should find connection cards' do
      expect(Card::Query.run(
        part: 'A'
      ).map(&:name).sort).to eq(
        %w{ A+B A+C A+D A+E C+A D+A F+A }
      )
    end

    it 'should find left connection cards' do
      expect(Card::Query.run(
        left: 'A'
      ).map(&:name).sort).to eq(
        %w{ A+B A+C A+D A+E }
      )
    end

    it 'should find right connection cards' do
      [ { right: 'A'},                         # query by name
        { right: { content: 'Alpha [[Z]]' } }  # query by content
      ].each do |statement|

        expect(Card::Query.run(
          statement
        ).map(&:name).sort).to eq(
          %w{ C+A D+A F+A }
        )
      end
    end

    it 'should return count' do
      expect(Card.count_by_wql( part: 'A' )).to eq(7)
    end
  end

  describe 'limit and offset' do
    it 'should return limit' do
      expect(Card::Query.run(
        part: 'A', limit: 5
      ).size).to eq(
        5
      )
    end

    it 'should not break if offset but no limit' do
      expect(Card::Query.run(
        part: 'A', offset: 5
      ).size).not_to eq(
        0
      )
    end

  end

  describe 'type' do
    user_cards = [
      'Big Brother', 'Joe Admin', 'Joe Camel', 'Joe User', 'John',
      'Narcissist', 'No Count', 'Optic fan', 'Sample User', 'Sara',
      'Sunglasses fan', 'u1', 'u2', 'u3'
    ].sort

    it 'should find cards of this type' do
      expect(Card::Query.run(
        type: '_self', context: 'User'
      ).map(&:name).sort).to eq(
        user_cards
      )
    end

    it 'should find User cards ' do
      expect(Card::Query.run(
        type: 'User'
      ).map(&:name).sort).to eq(
        user_cards
      )
    end

    it 'should handle casespace variants' do
      expect(Card::Query.run(
        type: 'users'
      ).map(&:name).sort).to eq(
        user_cards
      )
    end
  end

  describe 'trash handling' do
    it 'should not find cards in the trash' do
      Card['A+B'].delete!
      expect(Card::Query.run(
        left: 'A'
      ).map(&:name).sort).to eq(
        ['A+C', 'A+D', 'A+E']
      )
    end
  end

  describe 'order' do
    it 'should sort by create' do
      Card.create! name: 'classic bootstrap skin head'
      # classic skin head is created more recently than classic skin,
      # which is in the seed data
      expect( Card::Query.run(
        sort: 'create', name: [:match,'classic bootstrap skin']
      ).map(&:name) ).to eq(
        ['classic bootstrap skin', 'classic bootstrap skin head']
      )
    end

    it 'should sort by name' do
      expect(Card::Query.run(
        name: %w{ in B Z A Y C X }, sort: 'alpha', dir: 'desc'
      ).map(&:name)).to eq(
        %w{ Z Y X C B A }
      )

      expect(Card::Query.run(
        name: %w{ in B Z A Y C X }, sort: 'name', dir: 'desc'
      ).map(&:name)).to eq(
        %w{ Z Y X C B A }
      )
      #Card.create! name: 'the alphabet'
      #Card::Query.run(
      #name: ['in', 'B', 'C', 'the alphabet'], sort: 'name'
      #).map(&:name).should ==  ['the alphabet', 'B', 'C']
    end

    it 'should sort by content' do
      expect(Card::Query.run(
        name: %w{ in Z T A }, sort: 'content'
      ).map(&:name)).to eq(
        %w{ A Z T }
      )
    end

    it 'should play nice with match' do
      expect(Card::Query.run(
        match: 'Z', type: 'Basic', sort: 'content'
      ).map(&:name)).to eq(
        %w{ A B Z }
      )
    end

    it 'should sort by plus card content' do
      Card::Auth.as_bot do
        c = Card.fetch('Setting+*self+*table of contents')
        c.content = '10'
        c.save
        c = Card.create! name: 'Basic+*type+*table of contents', content: '3'

        expect(Card::Query.run(
          right_plus: '*table of contents',
          sort: { right: '*table_of_contents'}, sort_as: 'integer'
        ).map(&:name)).to eq(
          %w{ *all Basic+*type Setting+*self }
        )
      end
    end

    it 'should sort by count' do
      Card::Auth.as_bot do
        expect(Card::Query.run(
          name: [:in,'*always', '*never', '*edited'],
          sort: { right: '*follow', item: 'referred_to', return: 'count' }
        ).map(&:name)).to eq(
          ['*never', '*edited', '*always']
        )
      end
    end

  #  it 'should sort by update' do
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
  #

  end

  describe 'match' do
    it 'should reach content and name via shortcut' do
      expect(Card::Query.run(
        match: 'two'
      ).map(&:name).sort).to eq(
        CARDS_MATCHING_TWO
      )
    end

    it 'should get only content when content is explicit' do
      expect(Card::Query.run(
        content: [:match, 'two']
      ).map(&:name).sort).to eq(
        ['Joe User']
      )
    end

    it 'should get only name when name is explicit' do
      expect(Card::Query.run(
        name: [:match, 'two']
      ).map(&:name).sort).to eq(
        ['One+Two','One+Two+Three','Two'].sort
      )
    end
  end

  describe 'and' do
    it 'should act as a simple passthrough' do
      expect(Card::Query.run(
        and: { match: 'two' }
      ).map(&:name).sort).to eq(
        CARDS_MATCHING_TWO
      )

      expect(Card::Query.run(
        and: {}, type: 'Cardtype E'
      ).first.name).to eq(
        'type-e-card'
      )
    end

    it 'should work within "or"' do
      expect(Card::Query.run(
        or: { name: 'Z', and: { left: 'A', right: 'C' } },
        return: :name, sort: :name
      )).to eq(
        ['A+C','Z']
      )
    end
  end

  describe 'any/or' do
    it 'should work with :plus' do
      expect(Card::Query.run(
        plus: 'A', or: { name: 'B', match: 'K' }, return: :name, sort: :name
      )).to eq(
        %w{ B }
      )

      expect(Card::Query.run(
        plus: 'A', any: { name: 'B', match: 'K'}, return: :name, sort: :name
      )).to eq(
        %w{ B }
      )

      expect(Card::Query.run(
        or: { right_plus: 'A', plus: 'B' }, return: :name, sort: :name
      )).to eq(
        %w{ A C D F }
      )
    end
  end

  describe 'offset' do
    it 'should not break count' do
      expect(Card.count_by_wql(
        match: 'two', offset: 1
      )).to eq(
        CARDS_MATCHING_TWO.length
      )
    end
  end


  #=end
  describe 'found_by' do
    before do
      Card::Auth.current_id = Card::WagnBotID
      c = Card.create(
        name: 'Simple Search', type: 'Search', content: '{"name":"A"}'
      )
    end

    it 'should find cards returned by search of given name' do
      expect(Card::Query.run(
        found_by: 'Simple Search'
      ).first.name).to eq(
        'A'
      )
    end

    it 'should find cards returned by virtual cards' do
      expect(Card::Query.run(
        found_by: 'Image+*type+by name', return: :name, sort: :name
      )).to eq(
        Card.search type: 'Image', return: :name, sort: :name
      )
    end

    it 'should play nicely with other properties and relationships' do
      expect(Card::Query.run(
        plus: { found_by: 'Simple Search' }, return: :name, sort: :name
      )).to eq( Card::Query.run(
        plus: { name: 'A' }, return: :name, sort: :name
      ))

      expect(Card::Query.run(
        found_by: 'A+*self', plus: 'C', return: :name, sort: :name
      )).to eq(
        %w{ A }
      )
    end

    it 'should be able to handle _self' do
      expect(Card::Query.run(
        context: 'Simple Search',
        left: {found_by: '_self'},
        right: 'B',
        return: :name
      ).first).to eq(
        'A+B'
      )
    end

  end

  describe 'relative' do
    it 'should clean wql' do
      expect( Card::Query.new(
        part: '_self',context: 'A'
      ).statement[:part]).to eq(
        'A'
      )
    end

    it 'should find connection cards' do
      expect(Card::Query.run(
        part: '_self', context: 'A'
      ).map(&:name).sort).to eq(
        %w{ A+B A+C A+D A+E C+A D+A F+A }
      )
    end

    it 'should be able to use parts of nonexistent cards in search' do
      expect(Card['B+A']).to be_nil
      expect(Card::Query.run(
        left: '_right', right: '_left', context: 'B+A'
      ).map(&:name)).to eq(
        ['A+B']
      )
    end

    it 'should find plus cards for _self' do
      expect(Card::Query.run(
        plus: '_self', context: 'A'
      ).map(&:name).sort).to eq(
        A_JOINEES
      )
    end

    it 'should find plus cards for _left' do
      expect(Card::Query.run(
        plus: '_left', context: 'A+B'
      ).map(&:name).sort).to eq(
        A_JOINEES
      )
    end

    it 'should find plus cards for _right' do
      expect(Card::Query.run(
        plus: '_right', context: 'C+A'
      ).map(&:name).sort).to eq(
        A_JOINEES
      )
    end

  end


  describe 'nested permissions' do
    it 'are generated by default' do
      perm_count = 0
      sql = Card::Query.new(left: { name: 'X' }).sql
      sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
        perm_count+=1
      end
      expect(perm_count).to eq(2)
    end

#    it 'are not generated inside .without_nested_permissions block' do
#      perm_count = 0
#      Card::Query.without_nested_permissions do
#        Card::Query.run(
#      { left: {name: 'X'}}).sql.scan( /read_rule_id IN \([\d\,]+\)/ ) do |m|
#          perm_count+=1
#        end
#      end
#      perm_count.should == 1
#    end
  end

  #describe 'return values' do
  #  # FIXME: should do other return thingies here
  #  it 'returns name_content' do
  #    Card::Query.run(
  #    { name: 'A+B', return: 'name_content' }
  #    ).should == {
  #      'A+B' => 'AlphaBeta'
  #    }
  #  end
  #end
end
