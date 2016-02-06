# -*- encoding : utf-8 -*-

describe Card::Reference do
  before do
    Card::Auth.current_id = Card::WagnBotID
  end

  describe 'references on hard templated cards should get updated' do
    it 'on structuree creation' do
      Card.create! name: 'JoeForm', type: 'UserForm'
      Card['JoeForm'].format.render(:core)
      assert_equal ['joe_form+age', 'joe_form+description', 'joe_form+name'],
                   Card['JoeForm'].includees.map(&:key).sort
    end

    it 'on template creation' do
      Card.create! name: 'SpecialForm', type: 'Cardtype'
      Card.create! name: 'Form1', type: 'SpecialForm', content: 'foo'
      Card.create! name: 'SpecialForm+*type+*structure', content: '{{+bar}}'
      Card['Form1'].format.render(:core)
      expect(Card['Form1'].includees.map(&:key)).to eq(['form1+bar'])
    end

    it 'on template update' do
      Card.create! name: 'JoeForm', type: 'UserForm'
      tmpl = Card['UserForm+*type+*structure']
      tmpl.content = '{{+monkey}} {{+banana}} {{+fruit}}'
      tmpl.save!
      Card['JoeForm'].format.render(:core)
      assert_equal ['joe_form+banana', 'joe_form+fruit', 'joe_form+monkey'],
                   Card['JoeForm'].includees.map(&:key).sort
    end
  end

  it 'in references should survive cardtype change' do
    newcard 'Banana', '[[Yellow]]'
    newcard 'Submarine', '[[Yellow]]'
    newcard 'Sun', '[[Yellow]]'
    newcard 'Yellow'
    yellow_refs = Card['Yellow'].referers.map(&:name).sort
    expect(yellow_refs).to eq(%w{ Banana Submarine Sun })

    y = Card['Yellow']
    y.type_id = Card.fetch_id 'UserForm'
    y.save!

    yellow_refs = Card['Yellow'].referers.map(&:name).sort
    expect(yellow_refs).to eq(%w{ Banana Submarine Sun })
  end

  it 'container inclusion' do
    Card.create name: 'bob+city'
    Card.create name: 'address+*right+*default', content: '{{_L+city}}'
    Card.create name: 'bob+address'
    expect(Card.fetch('bob+address').includees.map(&:name)).to eq(['bob+city'])
    expect(Card.fetch('bob+city').includers.map(&:name)).to eq(['bob+address'])
  end

  it 'pickup new links on rename' do
    @l = newcard('L', '[[Ethan]]')  # no Ethan card yet...
    @e = newcard('Earthman')
    @e.update_attributes! name: 'Ethan' # NOW there is an Ethan card
    #  do we need the links to be caught before reloading the card?
    expect(Card['Ethan'].referers.map(&:name).include?('L')).not_to eq(nil)
  end

  it 'should update references on rename when requested' do
    newcard 'watermelon', 'mmmm'
    newcard 'watermelon+seeds', 'black'
    lew = newcard('Lew', 'likes [[watermelon]] and [[watermelon+seeds|seeds]]')

    watermelon = Card['watermelon']
    watermelon.update_referers = true
    watermelon.name = 'grapefruit'
    watermelon.save!
    result = 'likes [[grapefruit]] and [[grapefruit+seeds|seeds]]'
    expect(lew.reload.content).to eq(result)
  end

  it 'should update referers on rename when requested (case 2)' do
    card = Card['Administrator Menu+*self+*read']
    old_refs = Card::Reference.where(referee_id: Card::AdministratorID)

    card.update_referers = true
    card.name = 'Administrator Menu+*type+*read'
    card.save

    new_refs = Card::Reference.where(referee_id: Card::AdministratorID)
    expect(old_refs).to eq(new_refs)
  end

  it 'should not update references when not requested' do
    watermelon = newcard 'watermelon', 'mmmm'
    watermelon_seeds = newcard 'watermelon+seeds', 'black'
    lew = newcard('Lew', 'likes [[watermelon]] and [[watermelon+seeds|seeds]]')

    assert_equal [watermelon.id, watermelon_seeds.id],
                 lew.references_out.map(&:referee_id),
                 'should store referee ids'

    watermelon = Card['watermelon']
    watermelon.update_referers = false
    watermelon.name = 'grapefruit'
    watermelon.save!

    correct_content = 'likes [[watermelon]] and [[watermelon+seeds|seeds]]'
    expect(lew.reload.content).to eq(correct_content)

    ref_types = lew.references_out.order(:id).map(&:ref_type)
    assert_equal ref_types, %w(L L P), 'need partial references!'
    actual_referee_ids = lew.references_out.order(:id).map(&:referee_id)
    assert_equal actual_referee_ids, [nil, nil, Card.fetch_id('seed')]
                 'only partial reference to "seeds" should have referee_id'
  end

  it 'update referencing content on rename junction card' do
    @ab = Card['A+B'] # linked to from X, included by Y
    @ab.update_attributes! name: 'Peanut+Butter', update_referers: true
    @x = Card['X']
    expect(@x.content).to eq('[[A]] [[Peanut+Butter]] [[T]]')
  end

  it 'update referencing content on rename junction card' do
    @ab = Card['A+B'] # linked to from X, included by Y
    @ab.update_attributes! name: 'Peanut+Butter', update_referers: false
    @x = Card['X']
    expect(@x.content).to eq('[[A]] [[A+B]] [[T]]')
  end

  it 'template inclusion' do
    Card.create! name: 'ColorType', type: 'Cardtype', content: ''
    Card.create! name: 'ColorType+*type+*structure', content: '{{+rgb}}'
    green = Card.create! name: 'green', type: 'ColorType'
    newcard 'rgb'
    green_rgb = Card.create! name: 'green+rgb', content: '#00ff00'

    expect(green.reload.includees.map(&:name)).to eq(['green+rgb'])
    expect(green_rgb.reload.includers.map(&:name)).to eq(['green'])
  end

  it 'simple link' do
    Card.create name: 'alpha'
    Card.create name: 'beta', content: 'I link to [[alpha]]'
    expect(Card['alpha'].referers.map(&:name)).to eq(['beta'])
    expect(Card['beta'].referees.map(&:name)).to eq(['alpha'])
  end

  it 'link with spaces' do
    Card.create! name: 'alpha card'
    Card.create! name: 'beta card', content: 'I link to [[alpha_card]]'
    expect(Card['beta card'].referees.map(&:name)).to eq(['alpha card'])
    expect(Card['alpha card'].referers.map(&:name)).to eq(['beta card'])
  end

  it 'simple inclusion' do
    Card.create name: 'alpha'
    Card.create name: 'beta', content: 'I nest {{alpha}}'
    expect(Card['beta'].includees.map(&:name)).to eq(['alpha'])
    expect(Card['alpha'].includers.map(&:name)).to eq(['beta'])
  end

  it 'non simple link' do
    Card.create name: 'alpha'
    Card.create name: 'beta', content: 'I link to [[alpha|ALPHA]]'
    expect(Card['beta'].referees.map(&:name)).to eq(['alpha'])
    expect(Card['alpha'].referers.map(&:name)).to eq(['beta'])
  end

  it 'query' do
    Card.create(
      type: 'Search',
      name: 'search with references',
      content: '{"name":"X", "right_plus":["Y",{"content":["in","A","B"]}]}'
    )
    y_referers = Card['Y'].referers.map &:name
    expect(y_referers).to include('search with references')

    search_referees = Card['search with references'].referees.map(&:name).sort
    expect(search_referees).to eq(%w{ A B X Y })
  end

  it 'handles contextual names in Basic cards' do
    Card.create type: 'Basic', name: 'basic w refs', content: '{{_+A}}'
    Card['A'].update_attributes! name: 'AAA', update_referers: true
    expect(Card['basic w refs'].content).to eq '{{_+AAA}}'
  end

  it 'handles contextual names in Search cards' do
    Card.create type: 'Search', name: 'search w refs', content: '{"name":"_+A"}'
    Card['A'].update_attributes! name: 'AAA', update_referers: true
    expect(Card['search w refs'].content).to eq '{"name":"_+AAA"}'
  end

  it 'should handle commented inclusion' do
    c = Card.create name: 'inclusion comment test', content: '{{## hi mom }}'
    expect(c.errors.any?).to be_falsey
  end

  it 'pickup new links on create' do
    @l = newcard('woof', '[[Lewdog]]')  # no Lewdog card yet...
    @e = newcard('Lewdog')              # now there is
    # NOTE @e.referers does not work, you have to reload
    expect(@e.reload.referers.map(&:name).include?('woof')).not_to eq(nil)
  end

  it 'pickup new inclusions on create' do
    @l = Card.create! name: 'woof', content: '{{Lewdog}}'
    # no Lewdog card yet...
    @e = Card.new name: 'Lewdog', content: 'grrr'
    # now it's inititated
    expect(@e.name_referers.map(&:name).include?('woof')).not_to eq(nil)
  end
end
