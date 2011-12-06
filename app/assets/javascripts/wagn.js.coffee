
wagn.initializeEditors = (map) ->
    map = wagn.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call $(this)


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
    #might be better to put this href in the html
    href = wagn.root_path + '/card/save_draft/' + slot.attr('card-id')
    $.ajax href, {
      data : { 'card[content]' : @val() },
      complete: (xhr) -> slot.notify('draft saved') 
    }

  setContentFieldsFromMap: (map) ->
    map = wagn.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)-> 
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    wagn.fn = fn if selector.match /tinymce/
    $.each this.find(selector), ->
      $(this).setContentField(fn)     
  setContentField: (fn)->
    field = this.closest('.card-editor').find('.card-content')
    init_val = field[0].value # tinymce-jquery overrides val()
    new_val = fn.call this
    field.val new_val
    field.change() if init_val != new_val 
}

#~~~~~ ( EVENTS )

setInterval (-> $('.card-form').setContentFieldsFromMap()), 5000

$(window).load ->
  wagn.initializeEditors()

  $('body').delegate '.standard-slotter', "ajax:success", (event, data) ->
#    warn "standard slotter success"
    $(this).setSlotContent data

  $('body').delegate '.standard-slotter', "ajax:error", (event, xhr) ->
#    warn "standard slotter error"
    result = xhr.responseText
    if xhr.status == 303 #redirect
      window.location=result
    else if xhr.status == 403 #permission denied
      $(this).setSlotContent result
    else 
      $(this).notify result or $(this).setSlotContent result

#  $('body').delegate '.standard-slotter', "ajax:complete", (event, xhr) ->
#    warn "standard slotter complete"

  $('body').delegate 'button.standard-slotter', 'click', ->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote($(this))


  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

  $('.init-editors').live 'ajax:success', ->
    wagn.initializeEditors()

  # might be able to use more of standard-slotter if 
  $('.live-cardtype-field').live 'change', ->
    field = $(this)
    $.ajax field.attr('href'), {
      data: field.closest('form').serialize()
      complete: (xhr, status) ->
        field.setSlotContent xhr.responseText
        wagn.initializeEditors()
    }

  #should eventually work with standard-slotter (if done with views)
  $('.watch-toggle').live 'ajax:success', (event, data) ->
    $(this).closest('.watch-link').html data

  #unify these next two
  $('.edit-cardtype-field').live 'change', ->
    $(this).closest('form').submit()

  $('.set-select').live 'change', ->
    $(this).closest('form').submit()

  $('.autosave .card-content').live 'change', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500

  $('.navbox').autocomplete {
    html: 'html',
    autoFocus: true,
    source: navbox_results,
    select: navbox_select
  }
  
  $('#main').ajaxSend (event, xhr, opt) ->
    s = $(this).children('.card-slot')
    if s and mainName = s.attr('card-name')
      opt.url += ((if opt.url.match /\?/ then '&' else '?') + 'main=' + escape(mainName))


reqIndex = 0 #prevents race conditions

navbox_results = (request, response) ->
  this.xhr = $.ajax {
		url: wagn.root_path + '/*search.json?view=complete',
		data: request,
		dataType: "json",
		wagReq: ++reqIndex,
		success: ( data, status ) ->
			response navboxize(request.term, data) if this.wagReq == reqIndex
		error: () ->
		  response [] if this.wagReq == reqIndex
	  }

navboxize = (term, results)->
  items = []
  $.each results, (key, val)->
    if key == 'goto'
      $.each val, (index, gval) ->
        items.push { type: key, prefix: 'Go to', value: gval[0], label: gval[1], href: '/wagn/' + gval[2] }
    else
      i = { type : key, value : term, label : '<strong class="highlight">' + term + '</strong>' }
      if !val #nothing
      else if key == 'search'
        i.prefix = 'Search'
        i.href  = '/*search?_keyword=' + escape(term)
      else if key == 'add'
        i.prefix = 'Create'
        i.href = '/card/new?card[name]=' + escape(term)
      else if key == 'type'
        i.type = 'add'
        i.prefix = 'Create'
        i.label = '<strong class="highlight">' + val[0] + '</strong> <em>(type)</em>' 
        i.href = '/new/' + val[1]
      
      items.push i if val
    
  $.each items, (index, i)->
    i.href = wagn.root_path + i.href
    i.label = 
      '<span class="navbox-item-label '+ i.type + '-icon">' + i.prefix + ':</span> ' +
      '<span class="navbox-item-value">' + i.label + '</span>'
        
  items
  
navbox_select = (event, ui) ->
  $(this).attr('disabled', 'disabled')
  window.location = ui.item.href
  

warn = (stuff) -> console.log stuff if console?
