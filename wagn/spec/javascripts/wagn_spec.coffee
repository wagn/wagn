
describe "Global Wagn variable", ->
  it "should be defined", ->
    expect(wagn).toBeDefined

describe "card-form", ->
  beforeEach ->
    jasmine.getFixtures().fixturesPath = '../../public/assets/jasmine'
    loadFixtures('card_form.html')

  it "should find a form", ->
    expect($('form')).toBeDefined

  it "should be able to populate the content field based on nearby selector", ->
    $('.tinymce-textarea').setContentField -> 1+2
    expect($('.card-content')).toHaveValue '3'

  it "should be able to populate all content fields in a form", ->
    $('form').setContentFields '.tinymce-textarea', -> 2+2
    expect($('.card-content')).toHaveValue '4'

  it "should be able to populate content fields from a map", ->
    $('form').setContentFieldsFromMap { '.tinymce-textarea': -> 3+2 }
    expect($('.card-content')).toHaveValue '5'

  it "should be able to find the slot from any element within", ->
    expect($('.card-content').slot()).toHaveClass 'card-slot'

  it "should be able to populate slot from any element within", ->
    $('.card-content').setSlotContent '<div class="card-slot">whoopee</div>'
    expect($('.card-slot')).toHaveHtml 'whoopee'


###
describe "tiny-mce", ->
  beforeEach ->
    loadFixtures('card_form.html')

  it 'should load', ->
    wagn.initializeTinyMCE
    expect($('form')).toContain('.mceEditor')
###
