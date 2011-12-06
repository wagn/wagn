window.wagn ||= {} #needed to run w/o *head.  eg. jasmine

wagn.editorContentFunctionMap = {
  '.tinymce-textarea'      : -> @html(),
  '.pointer-select'        : -> pointerContent @val(),
  '.pointer-multiselect'   : -> pointerContent @val(),
  '.pointer-radio-list'    : -> pointerContent @find('input:checked').val(),
  '.pointer-list-ul'       : -> pointerContent @find('input'        ).map( -> $(this).val() ),
  '.pointer-checkbox-list' : -> pointerContent @find('input:checked').map( -> $(this).val() ),
  '.perm-editor'           : -> permissionsContent this # must happen after pointer-list-ul, I think
}

wagn.editorInitFunctionMap = {
  '.date-editor'         : -> @datepicker({ dateFormat: 'yy-mm-dd' }),
  '.tinymce-textarea'    : -> @tinymce(if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {})
  '.pointer-list-editor' : -> @sortable(); wagn.initPointerAutoComplete @find('input')
}

wagn.initPointerAutoComplete = (input)->
  optionsCard = input.closest('ul').attr('options-card')
  input.autocomplete { source: wagn.root_path + '/' + optionsCard + '.json?view=name_complete' }


$(window).load ->

  #pointer pack
  $('.pointer-item-add').live 'click', (event)->
    last_item = $(this).closest('.content-editor').find '.pointer-li:last'
    new_item = last_item.clone()
    input = new_item.find('input')
    input.val ''
    last_item.after new_item
    wagn.initPointerAutoComplete(input)    
    event.preventDefault() # Prevent link from following its href

  $('.pointer-item-delete').live 'click', ->
    item = $(this).closest 'li'
    if item.closest('ul').find('.pointer-li').length > 1
      item.remove()
    else
      item.find('input').val ''
    event.preventDefault() # Prevent link from following its href

  # permissions pack
  $('.perm-vals input').live 'click', ->
    $(this).slot().find('#inherit').attr('checked',false)
  
  $('.perm-editor #inherit').live 'click', ->
    slot = $(this).slot()
    slot.find('.perm-group input:checked').attr('checked', false)
    slot.find('.perm-indiv input').val('')

  # rstar pack
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

  
permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').attr('checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))

pointerContent = (vals) ->
  list = $.map $.makeArray(vals), (v)-> if v then '[[' + v + ']]'
  $.makeArray(list).join "\n"

