wagn = {
  initializeEditors : (map) ->
    map = wagnConf.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call this
}

jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  
  setSlotContent: (val) -> @slot().html val

  setContentFieldsFromMap: (map) ->
    map = wagnConf.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
      
  setContentFields: (selector, fn) ->
    $.each this.find(selector), -> 
      $(this).setContentField(fn)
      
  setContentField: (fn)->
    this.closest('.editor').find('#card_content')[0].value = fn.call this[0]
}

#~~~~~ ( EVENTS )

$(window).load -> wagn.initializeEditors()

$('body').delegate '.standard-slotter', "ajax:success", (event, data) ->
  $(this).setSlotContent data

$('.card-new-form').live "ajax:success", (event, data, status, xhr) ->
  if xhr.status == 201
    window.location=data
  else
    $(this).setSlotContent data 

#$('.standard-slotter').live "ajax:success", (event, data) ->

$('.edit-content-link').live 'ajax:complete', ()->
  wagn.initializeEditors()

$('.new-cardtype-field').live 'change', ->
  cardtypeField = $(this)
  $.ajax '/card/new', {
    data: cardtypeField.closest('form').serialize()
    complete: (xhr, status) ->
      cardtypeField.setSlotContent xhr.responseText
      wagn.initializeEditors()
  }

$('.edit-cardtype-field').live 'change', ->
  $(this).closest('form').submit()

$('body').delegate '.card-form', 'submit', ->
  $(this).setContentFieldsFromMap()
  true

warn = (stuff) -> console.log stuff if console?

#Wagn.Messenger = {  
#  element: -> $('#alerts'),
#  alert: (message) ->
#    return if !@element()
#    @element().innerHTML = '<span style="color:red; font-weight: bold">' + message + '</span>';
#    #new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
#  note: (message) ->
#    return if !@element()
#    @element().innerHTML = message
#    #new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
#  log: (message) ->
#    return if !@element()
#    @element().innerHTML = message; 
#    #new Effect.Highlight( this.element(), {startcolor:"#eeeebb", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
#  flash: ->
#    if $('#notice') && $('#error')
#      flash = $('#notice').innerHTML + $('#error').innerHTML
#      @alert(flash) if flash != ''
#}
#


window.wagn = wagn
