wagn = {
  initializeEditors : (map) ->
    map = wagnConf.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call this
}

jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  setSlotContent: (val) -> @slot().replaceWith val

  setContentFieldsFromMap: (map) ->
    map = wagnConf.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each this.find(selector), -> 
      $(this).setContentField(fn)     
  setContentField: (fn)->
    this.closest('.editor').find('.card-content')[0].value = fn.call this[0]
}

#~~~~~ ( EVENTS )

$(window).load -> wagn.initializeEditors()

$('body').delegate '.standard-slotter', "ajax:success", (event, data) ->
  wagn.obj = this
  $(this).setSlotContent data

$('body').delegate '.standard-slotter', "ajax:error", (event, xhr) ->
  result = xhr.responseText
  slot = $(this).slot()
  notice = slot.find('.notice')
  if xhr.status == 303
    window.location=result
  else if notice[0]
    notice.html(result)
  else  
    slot.setSlotContent result

$('.init-editors').live 'ajax:success', ->
  wagn.initializeEditors()

$('body').delegate 'button.standard-slotter', 'click', ->
  return false if !$.rails.allowAction $(this)
  $.rails.handleRemote($(this))

$('body').delegate '.rule-submit-button', 'click', ->
  f = $(this).closest('form')
  if f.find('.set-editor input:checked').val()
    true
  else
    f.find('.set-editor').addClass('attention')
    f.find('.notice').text('To what Set of cards does this Rule apply?')
    false

$('body').delegate '.rule-cancel-button', 'click', ->
  $(this).closest('tr').find('.close-rule-link').click()

$('.live-cardtype-field').live 'change', ->
  field = $(this)
  $.ajax field.attr('href'), {
    data: field.closest('form').serialize()
    complete: (xhr, status) ->
      field.setSlotContent xhr.responseText
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
