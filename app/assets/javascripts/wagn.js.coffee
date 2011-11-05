
wagn = {
  contentFieldFunctions: {
    '.tinymce-textarea' : -> tinyMCE.getInstanceById( @id ).getContent()
  }
  
  initEditors: ->
    tinyMCE.init wagn.tinyMCEArgs()
#    tinyMCE.execInstanceCommand( '#{eid}-tinymce', 'mceFocus' )
  
  tinyMCEArgs: ->
      conf = if tinyMCEConfig? then tinyMCEConfig else {}
      conf['mode'] = "specific_textareas"
      conf['editor_selector'] = "tinymce-textarea"
      conf
}


jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  
  setSlotContent: (val) -> @slot().html val

  setContentFieldsFromMap: (map) -> 
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
      
  setContentFields: (selector, fn) ->
    $.each this.find(selector), -> 
      $(this).setContentField(fn)
      
  setContentField: (fn)->
    this.closest('.editor').find('#card_content')[0].value = fn.call this[0]
}

$(window).load -> wagn.initEditors()

$('.card-new-form .cardtype-field').live 'change', ->
  cardtypeField = $(this)
  $.ajax '/card/new', {
    data: cardtypeField.closest('form').serialize()
    complete: (xhr, status) ->
      cardtypeField.setSlotContent xhr.responseText
      wagn.initEditors()   
  }

$('.card-new-form').live "ajax:success", (event, data, status, xhr) ->
  if xhr.status == 201
    window.location=data
  else
    $(this).setSlotContent data 

$('.card-edit-form').live "ajax:success", (event, data) ->
  $(this).setSlotContent data

$('.edit-content-link').live 'ajax:success', (event, data) ->
  $(this).setSlotContent data
  wagn.initEditors()
  

$('body').delegate '.card-form', 'submit', ->
  $(this).setContentFieldsFromMap wagn.contentFieldFunctions
  false

#warn = (stuff) -> console.log stuff if console?

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
#Wagn.runQueue = (queue) ->
#  result = true
#  if queue? then $.each queue, ->
#    result = false if !@call()
#  result
#
#Wagn.onLoadQueue   = []
#Wagn.onSaveQueue   = {}
#Wagn.onCancelQueue = {}
#
#Wagn.EditorContent = {
#  '.tinymce-textarea': -> tinyMCE.getInstanceById( @id ).getContent()
#}

  


#jQuery(window).bind('load', wagnOnload)


window.wagn = wagn
