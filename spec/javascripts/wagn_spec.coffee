describe "Global Wagn variable", ->
  it "should be defined", ->
    expect(wagn).toBeDefined

describe "card-form", ->
  beforeEach ->
    loadFixtures('card_form.html')
  
  it "should find a form", ->
    expect($('form')).toBeDefined

  it "should be able to populate the content field based on nearby selector", ->
    wagn.setContentFields $('form'), '.tinymce-textarea', -> 1+2 
    expect($('#card_content')).toHaveValue '3'

  it "should be able to populate content fields from a map", ->
    wagn.setContentFieldsFromMap $('form'), { '.tinymce-textarea': -> 3+2 }
    expect($('#card_content')).toHaveValue '5'
    
###
describe "tiny-mce", ->
  beforeEach ->
    loadFixtures('card_form.html')
  
  it 'should load', ->
    wagn.initializeTinyMCE
    expect($('form')).toContain('.mceEditor')
###