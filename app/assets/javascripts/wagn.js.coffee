
wagn.initializeEditors = (range, map) ->
  map = wagn.editorInitFunctionMap unless map?
  $.each map, (selector, fn) ->
    $.each range.find(selector), ->
      fn.call $(this)

wagn.prepUrl = (url, slot)->
  xtra = {}
  main = $('#main').children('.card-slot').attr 'card-name'
  xtra['main'] = main  if main?
  if slot
    home_view = slot.attr 'home_view'
    item      = slot.attr 'item' 
    xtra['home_view'] = home_view if home_view?
    xtra['item']      = item      if item?
  url + ( (if url.match /\?/ then '&' else '?') + $.param(xtra) )

jQuery.fn.extend {
  slot: -> 
    wagn.slot_this = this
    @closest '.card-slot'
  
  setSlotContent: (val) ->
    s = @slot()
    wagn.val = val
    v = $(val)
    v.attr 'home_view', s.attr 'home_view'
    v.attr 'item',      s.attr 'item'
    s.replaceWith v
    v
  
  notify: (message) -> 
    notice = @slot().find('.card-notice')
    return false unless notice[0]
    notice.html(message)

  report: (message) ->
    report = @slot().find('.card-report')
    return false unless report[0]
    report.hide()
    report.html(message)
    report.show 'drop', 750
    setTimeout (->report.hide 'drop', 750), 3000
    
  isMain: -> @slot().parent('#main')[0]
  
  loadCaptcha: -> Recaptcha.create wagn.recaptchaKey, this[0]

  autosave: ->
    slot = @slot()
    return if @attr('no-autosave')
    #might be better to put this href in the html
    href = wagn.rootPath + '/card/save_draft/~' + slot.attr('card-id')
    $.ajax href, {
      data : { 'card[content]' : @val() },
      complete: (xhr) -> slot.report('draft saved') 
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
  wagn.initializeEditors $('body')
  
  $('body').delegate '.slotter', "ajax:success", (event, data) ->
    newslot = $(this).setSlotContent data
    wagn.initializeEditors newslot

  $('body').delegate '.slotter', "ajax:error", (event, xhr) ->
    result = xhr.responseText
    if xhr.status == 303 #redirect
      window.location=result
    else if xhr.status == 403 #permission denied
      $(this).setSlotContent result
    else
      $(this).notify result
    
      s = $(this).slot()
      if xhr.status == 409 #edit conflict
        s.find('.current_revision_id').val s.find('.new-current-revision-id').text()
      else if xhr.status == 449
        s.find('.recaptcha-box').loadCaptcha()

      
    
  $('body').delegate 'button.slotter', 'click', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote($(this))

  $('.slotter').live 'ajax:beforeSend', (event, xhr, opt)->
    return if opt.skip_before_send
    
    unless opt.url.match /home_view/ #avoiding duplication.  could be better test?
      opt.url = wagn.prepUrl opt.url, $(this).slot()
    
    if $(this).is('form')
      if wagn.recaptchaKey and !($(this).find('.recaptcha-box')[0])
         newCaptcha(this)
         return false
      
      if data = $(this).data 'file-data'
        input = $(this).find '.file-upload'
        widget = input.data 'fileupload'
        wagn.opt = opt
        args = $.extend {}, (widget._getAJAXSettings data), { url: opt.url, context: this, success: opt.success }
        wagn.args = args
        args.skip_before_send = true
        $.ajax( args ).always (a, b, c) -> widget._onAlways a, b, c, args
        
        false
        #true

  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true
    
  $('body').delegate 'button.redirecter', 'click', ->
    window.location = $(this).attr('href')

  $('.card-slot').live 'dblclick', (event)->
    s = $(this)
    return false if s.find( '.edit-area' )[0]
    s.addClass 'slotter'
    s.attr 'href', wagn.rootPath + '/card/edit/~' + s.attr('card-id')
    $.rails.handleRemote(s)
    false # don't propagate up to next slot

  $('.comment-box').live 'dblclick', -> false

  $('body').delegate 'form.slotter', 'submit', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      if input and !(input.val().match /^REDIRECT/)
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
  

newCaptcha = (form)->
  recapUri = 'http://www.google.com/recaptcha/api/js/recaptcha_ajax.js'
  recapDiv = $('<div class="recaptcha-box"></div>')
  $(form).children().last().after recapDiv
  $.getScript recapUri, -> recapDiv.loadCaptcha()


warn = (stuff) -> console.log stuff if console?
