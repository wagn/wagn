
wagn.initializeEditors = (map) ->
    map = wagn.conf.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call this

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000
#window.setInterval "alert('hi')", 3000

jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  setSlotContent: (val) -> @slot().replaceWith val
  notify: (message) -> 
    notice = @slot().find('.notice')
    return false unless notice[0]
    notice.html(message)
    true

  autosave: ->
    slot = @slot()
    return if @attr('no-autosave')
    href = '/card/save_draft/' + slot.attr('card_id')
    $.ajax href, {
      data : { 'card[content]' : @val() },
      complete: (xhr) -> slot.notify('draft saved') 
    }

  setContentFieldsFromMap: (map) ->
    map = wagn.conf.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each this.find(selector), ->
      $(this).setContentField(fn)     
  setContentField: (fn)->
    field = this.closest('.card-editor').find('.card-content')
    init_val = field.val()
    new_val = fn.call this[0]
    field.val new_val
    field.change() if init_val != new_val 
}

#~~~~~ ( EVENTS )

$(window).load -> wagn.initializeEditors()

$('body').delegate '.standard-slotter', "ajax:success", (event, data) ->
  warn "standard slotter success"
  $(this).setSlotContent data

$('body').delegate '.standard-slotter', "ajax:error", (event, xhr) ->
  warn "standard slotter error"
  result = xhr.responseText
  if xhr.status == 303
    window.location=result
  else 
    $(this).notify result or $(this).setSlotContent result

$('body').delegate '.standard-slotter', "ajax:complete", (event, xhr) ->
  warn "standard slotter complete"

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

$('.watch-toggle').live 'ajax:success', (event, data) ->
  $(this).closest('.watch-link').html data

$('.edit-cardtype-field').live 'change', ->
  $(this).closest('form').submit()

$('.autosave .card-content').live 'change', ->
  content_field = $(this)
  setTimeout ( -> content_field.autosave() ), 500


$('body').delegate '.card-form', 'submit', ->
  $(this).setContentFieldsFromMap()
  $(this).find('.card-content').attr('no-autosave','true')
  true

warn = (stuff) -> console.log stuff if console?

warn "this got loaded"
