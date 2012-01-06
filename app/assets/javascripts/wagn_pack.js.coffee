window.wagn ||= {} #needed to run w/o *head.  eg. jasmine

wagn.editorContentFunctionMap = {
  '.tinymce-textarea'      : -> tinyMCE.get(@[0].id).getContent()
  '.pointer-select'        : -> pointerContent @val()
  '.pointer-multiselect'   : -> pointerContent @val()
  '.pointer-radio-list'    : -> pointerContent @find('input:checked').val()
  '.pointer-list-ul'       : -> pointerContent @find('input'        ).map( -> $(this).val() )
  '.pointer-checkbox-list' : -> pointerContent @find('input:checked').map( -> $(this).val() )
  '.perm-editor'           : -> permissionsContent this # must happen after pointer-list-ul, I think
}

wagn.editorInitFunctionMap = {
  '.date-editor'           : -> @datepicker { dateFormat: 'yy-mm-dd' }
  '.tinymce-textarea'      : -> wagn.initTinyMCE(@[0].id)
  '.pointer-list-editor'   : -> @sortable(); wagn.initPointerList @find('input')
  '.file-upload'           : -> @fileupload( add: wagn.chooseFile )
  '.etherpad-textarea'   : -> $(this).closest('form').find('.edit-submit-button').attr('class', 'etherpad-submit-button')
}

wagn.initPointerList = (input)-> 
  optionsCard = input.closest('ul').attr('options-card')
  input.autocomplete { source: wagn.prepUrl wagn.rootPath + '/' + optionsCard + '.json?view=name_complete' }

wagn.initTinyMCE = (el_id) ->
  conf = if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {}
  $.extend conf, { 
    mode: "exact", 
    elements: el_id, 
    content_css: wagn.rootPath + '/assets/application-all.css,' + wagn.local_css_path
    verify_html: false,
    entity_encoding: 'raw'
  }    
  tinyMCE.init conf

wagn.chooseFile = (e, data) ->
  s = $(this).slot()
  filename = data.files[0].fileName
  $(this).closest('form').data 'file-data', data
  if name_field = s.find( '.card-name-field' ) 
    if name_field[0] and name_field.val() == ''
      name_field.val filename.replace /\..*/, ''
  s.find('.choose-file').hide()
  s.find('.chosen-filename').text filename
  s.find('.chosen-file').show()


$(window).load ->

  $('.cancel-upload').live 'click', ->
    s = $(this).slot()
    s.find('.chosen-file').hide()
    s.find('.choose-file').show()
    $(this).closest('form').data 'file-data', null

  #navbox pack
  $('.navbox').autocomplete {
    html: 'html',
    autoFocus: true,
    source: navbox_results,
    select: navbox_select
  }

  #pointer pack
  $('.pointer-item-add').live 'click', (event)->
    last_item = $(this).closest('.content-editor').find '.pointer-li:last'
    new_item = last_item.clone()
    input = new_item.find('input')
    input.val ''
    last_item.after new_item
    wagn.initPointerList(input)    
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


  # etherpad pack
  $('body').delegate '.etherpad-submit-button', 'click', ->
    wagn.padform = $(this).closest('form')

    padsrc = $(wagn.padform).find('iframe')[0].src
    if (qindex = padsrc.indexOf('?')) != -1
      padsrc = padsrc.slice(0,qindex)

    # perform an ajax call on contentsUrl and write it to the parent
    $.get padsrc + '/export/html', (data) ->
       $(wagn.padform).find('.etherpad-textarea')[0].value = data
       $(wagn.padform)[0].submit()
    false

  
permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').attr('checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))

pointerContent = (vals) ->
  list = $.map $.makeArray(vals), (v)-> if v then '[[' + v + ']]'
  $.makeArray(list).join "\n"




#navbox pack
reqIndex = 0 #prevents race conditions

navbox_results = (request, response) ->
  this.xhr = $.ajax {
		url: wagn.prepUrl wagn.rootPath + '/*search.json?view=complete'
		data: request
		dataType: "json"
		wagReq: ++reqIndex
		success: ( data, status ) ->
			response navboxize(request.term, data) if this.wagReq == reqIndex
		error: () ->
		  response [] if this.wagReq == reqIndex
	  }

navboxize = (term, results)->
  items = []

  $.each ['search', 'add' ,'type'], (index, key)->
    val = results[key]
    i = { type: key, value: term, prefix: 'Create', label: '<strong class="highlight">' + term + '</strong>' }
    if !val #nothing
    else if key == 'search'
      i.prefix = 'Search'
      i.href  = '/*search?view=content&_keyword=' + escape(term)
    else if key == 'add'
      i.href = '/card/new?card[name]=' + escape(term)
    else if key == 'type'
      i.type = 'add'
      i.label = '<strong class="highlight">' + val[0] + '</strong> <em>(type)</em>' 
      i.href = '/new/' + val[1]

    items.push i if val

  $.each results['goto'], (index, val) ->
    items.push { type: 'goto', prefix: 'Go to', value: val[0], label: val[1], href: '/' + val[2] } 

  $.each items, (index, i)->
    i.href = wagn.rootPath + i.href
    i.label = 
      '<span class="navbox-item-label '+ i.type + '-icon">' + i.prefix + ':</span> ' +
      '<span class="navbox-item-value">' + i.label + '</span>'

  items

navbox_select = (event, ui) ->
  $(this).attr('disabled', 'disabled')
  window.location = ui.item.href
