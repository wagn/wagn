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
  '.tinymce-textarea'      : -> wagn.initTinyMCE @[0].id
  '.pointer-list-editor'   : -> @sortable(); wagn.initPointerList @find('input')
  '.file-upload'           : -> @fileupload( add: wagn.chooseFile )#, forceIframeTransport: true )
  '.etherpad-textarea'     : -> $(this).closest('form').find('.edit-submit-button').attr('class', 'etherpad-submit-button')
}

wagn.initPointerList = (input)-> 
  optionsCard = input.closest('ul').attr('options-card')
  input.autocomplete { source: wagn.prepUrl wagn.rootPath + '/' + optionsCard + '.json?view=name_complete' }

wagn.initTinyMCE = (el_id) ->
  # verify_html: false -- note: this option needed for empty paragraphs to add space.
  
  conf = if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {}
  $.extend conf, { 
    mode: 'exact'
    plugins: 'autoresize'
    autoresize_max_height: 500 #probably want to make several of these overridable....
    elements: el_id 
    content_css: wagn.rootPath + '/assets/application-all.css' + ',' + wagn.rootPath + wagn.local_css_path
    entity_encoding: 'raw'
  }    
  tinyMCE.init conf

wagn.chooseFile = (e, data) ->
  file = data.files[0]
  $(this).fileupload '_normalizeFile', 0, file # so file objects have same fields in all browsers
  $(this).closest('form').data 'file-data', data # stores data on form for use at submission time
  
  if name_field = $(this).slot().find( '.card-name-field' )
    # populates card name if blank
    if name_field[0] and name_field.val() == ''
      name_field.val file.name.replace( /\..*$/, '' ).replace( /_/g, ' ')

  editor = $(this).closest '.card-editor'
  editor.find('.choose-file').hide()
  editor.find('.chosen-filename').text file.name
  editor.find('.chosen-file').show()
  
  contentFieldName = this.name.replace( /attach\]$/, 'content]' )
  editor.append '<input type="hidden" value="CHOSEN" class="upload-card-content" name="' + contentFieldName + '">'
  # we add and remove the contentField to insure that nothing is added / updated when nothing is chosen. 
  

$(window).ready ->

  $('.cancel-upload').live 'click', ->
    editor = $(this).closest '.card-editor'
    editor.find('.chosen-file').hide()
    editor.find('.choose-file').show()
    $(this).closest('form').data 'file-data', null
    contentField = editor.find( '.upload-card-content' ).remove()

  #navbox pack
  $('.navbox').autocomplete {
    html: 'html',
    source: navbox_results,
    select: navbox_select
    # autoFocus: true,  
    # this makes it so the first option ("search") is pre-selected.
    # sadly, it also causes odd navbox behavior, resetting the search term
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

  #wagn_org pack (for now)
  $('.shade-view h1').live 'click', ->
    $(this).slot().find('.shade-content').slideToggle 1000

  # rstar pack
  $('body').delegate '.rule-submit-button', 'click', ->
    f = $(this).closest('form')
    if f.find('.set-editor input:checked').val()
      true
    else
      f.find('.set-editor').addClass('attention')
      $(this).notify 'To what Set of cards does this Rule apply?'
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
  f = this.element.closest 'form'
  view_field = f.find '[name=view]'
  orig_view = view_field.val()
  view_field.val 'complete'
  formData = f.serialize()
  view_field.val orig_view
      
  this.xhr = $.ajax {
		url: wagn.prepUrl wagn.rootPath + '/:search.json'
		data: formData
		dataType: "json"
		wagReq: ++reqIndex
		success: ( data, status ) ->
			response navboxize(request.term, data) if this.wagReq == reqIndex
		error: () ->
		  response [] if this.wagReq == reqIndex
	  }

navboxize = (term, results)->
  items = []

  $.each ['search', 'add', 'new'], (index, key)->
    if val = results[key]
      i = { type: key, value: term, prefix: key, label: '<strong class="highlight">' + term + '</strong>' }
      if key == 'search'
        i.term = term
      else if key == 'add'
        i.href = '/card/new?card[name]=' + encodeURIComponent(term)
      else if key == 'new'
        i.type = 'add' # for icon
        i.href = '/new/' + val[1]

      items.push i

  $.each results['goto'], (index, val) ->
    items.push { type: 'goto', prefix: 'go to', value: val[0], label: val[1], href: '/' + val[2] } 

  $.each items, (index, i) ->
    i.label = 
      '<span class="navbox-item-label '+ i.type + '-icon">' + i.prefix + ':</span> ' +
      '<span class="navbox-item-value">' + i.label + '</span>'

  items

navbox_select = (event, ui) ->
  if ui.item.term
    $(this).closest('form').submit()
  else
    window.location = wagn.rootPath + ui.item.href
    
  $(this).attr('disabled', 'disabled')
  