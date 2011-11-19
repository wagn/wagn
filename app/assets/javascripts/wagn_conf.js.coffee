window.wagn ||= {} #needed to run w/o *head.  eg. jasmine

wagn.conf = {
  
  editorContentFunctionMap : {
    '.tinymce-textarea'      : -> tinyMCE.getInstanceById(@id).getContent(),
    '.pointer-select'        : -> pointerContent $(this).val(),
    '.pointer-multiselect'   : -> pointerContent $(this).val(),
    '.pointer-radio-list'    : -> pointerContent $(this).find('input:checked').val(),
    '.pointer-list-ul'       : -> pointerContent $(this).find('input'        ).map( -> $(this).val() ),
    '.pointer-checkbox-list' : -> pointerContent $(this).find('input:checked').map( -> $(this).val() ),
    '.perm-editor'           : -> permissionsContent $(this) # must happen after pointer-list-ul, I think
  }
  
  editorInitFunctionMap : {
    '.tinymce-textarea' : -> wagn.conf.initTinyMCE(),
    '.date-editor'      : -> $(this).datepicker({ dateFormat: 'yy-mm-dd' })
  }

  initTinyMCE: ()->
    conf = if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {}
    conf['mode'] = "specific_textareas"
    conf['editor_selector'] = @id
    tinyMCE.init conf

}

$(window).load ->

  #pointer pack
  $('.pointer-item-add').live 'click', (event)->
    last_item = $(this).closest('ul').find '.pointer-li:last'
    new_item = last_item.clone()
    new_item.find('input').val ''
    last_item.after new_item
    event.preventDefault(); # Prevent link from following its href

  $('.pointer-item-delete').live 'click', ->
    item = $(this).closest 'li'
    if item.closest('ul').find('.pointer-li').length > 1
      item.remove()
    else
      item.find('input').val ''
    event.preventDefault(); # Prevent link from following its href

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

  # google analytics module
  initGoogleAnalytics()
  
permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').attr('checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))

pointerContent = (vals) ->
  list = $.map $.makeArray(vals), (v)-> if v then '[[' + v + ']]'
  $.makeArray(list).join "\n"

initGoogleAnalytics = ->
  return false unless wagn.googleAnalyticsKey
  if !pageTracker?
    gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
  pageTracker = _gat._getTracker(wagn.googleAnalyticsKey);
  pageTracker._trackPageview();
