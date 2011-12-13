
wagn.initializeEditors = (map) ->
    map = wagn.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each $.find(selector), ->
        fn.call $(this)

jQuery.fn.extend {
  slot: -> @closest '.card-slot'
  
  setSlotContent: (val) ->
    s = @slot()
    v = $(val)
    v.attr 'home_view', s.attr 'home_view'
    v.attr 'item',      s.attr 'item'
    s.replaceWith v
  
  notify: (message) -> 
    notice = @slot().find('.notice')
    return false unless notice[0]
    notice.html(message)
    true

  isMain: -> @slot().parent('#main')[0]

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
    $.each this.find(selector), ->
      $(this).setContentField(fn)     
  setContentField: (fn)->
    field = this.closest('.card-editor').find('.card-content')
    init_val = field.val() # tinymce-jquery overrides val()
    new_val = fn.call this
    field.val new_val
    field.change() if init_val != new_val  
}

#~~~~~ ( EVENTS )

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000

$(window).load ->
  wagn.initializeEditors()

  $('body').delegate '.slotter', "ajax:success", (event, data) ->
    $(this).setSlotContent data

  $('body').delegate '.slotter', "ajax:error", (event, xhr) ->
    result = xhr.responseText
    if xhr.status == 303 #redirect
      window.location=result
    else if xhr.status == 403 #permission denied
      $(this).setSlotContent result
    else 
      $(this).notify result or $(this).setSlotContent result
    

  $('body').delegate 'button.slotter', 'click', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote($(this))

  $('.slotter').live 'ajax:beforeSend', (event, xhr, opt)->
    return if opt.url.match /home_view/ #avoiding duplication.  could be better test?
    s = $(this).slot()
    main = $('#main').children('.card-slot').attr 'card-name'
    home_view = s.attr 'home_view'
    item      = s.attr 'item' 
    xtra = {}
    xtra['main']      = main      if main?
    xtra['home_view'] = home_view if home_view?
    xtra['item']      = item      if item?
    opt.url += ( (if opt.url.match /\?/ then '&' else '?') + $.param(xtra) ) 

  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

  $('.init-editors').live 'ajax:success', ->
    wagn.initializeEditors()
    
  $('body').delegate 'button.redirecter', 'click', ->
    window.location = $(this).attr('href')


  $('.card-slot').live 'dblclick', (event)->
    s = $(this)
    return false if s.find( '.edit-area' )[0]
    s.addClass 'slotter init-editors'
    s.attr 'href', wagn.root_path + '/card/edit/' + s.attr('card-id')
    $.rails.handleRemote(s)
    false # don't propagate up to next slot

  $('.comment-box').live 'dblclick', -> false

  $('body').delegate 'form.slotter', 'submit', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      if input and input.val().match /^REDIRECT/
        input.val ( if target == 'REDIRECT' then target + ': ' + input.val() else target )
        
  #more of this info should be in views; will need to refactor for HTTP DELETE anyway...
  $('.card-slot').delegate '.standard-delete', 'click', ->
    return if $(this).attr('success-ready') == 'true' #prevent double-click weirdness
    s = if $(this).isMain() then 'REDIRECT: TO-PREVIOUS' else 'TEXT:' + $(this).slot().attr('card-name') + ' removed'
    $(this).attr 'href', $(this).attr('href') + '?success=' + escape(s)
    $(this).attr 'success-ready', 'true'


  $('body').delegate '.live-type-field', 'change', ->
    $(this).data 'params', $(this).closest('form').serialize()
    $(this).data 'url', $(this).attr 'href'


  #unify these next two
  $('.edit-type-field').live 'change', ->
    $(this).closest('form').submit()

  $('.set-select').live 'change', ->
    $(this).closest('form').submit()

  $('.autosave .card-content').live 'change', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500
  



  

warn = (stuff) -> console.log stuff if console?
