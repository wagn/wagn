
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

  $('body').delegate 'button.standard-slotter', 'click', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote($(this))

  $('body').delegate 'form.standard-slotter', 'submit', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      return if input.val().match /^REDIRECT/
      input.val ( if target == 'REDIRECT' then target + ': ' + input.val() else target )    

    
  $('body').delegate 'button.redirecter', 'click', ->
    window.location = $(this).attr('href')

  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

  $('.init-editors').live 'ajax:success', ->
    wagn.initializeEditors()


    #more of this info should be in views; will need to refactor for HTTP DELETE anyway...
  $('.card-slot').delegate '.standard-delete', 'click', ->
    return if $(this).attr('success-ready') == 'true' #prevent double-click weirdness
    s = if $(this).isMain() then 'REDIRECT: TO-PREVIOUS' else 'TEXT:' + $(this).slot().attr('card-name') + ' removed'
    $(this).attr 'href', $(this).attr('href') + '?success=' + escape(s)
    $(this).attr 'success-ready', 'true'


  # might be able to use more of standard-slotter 
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
  
  $('#main').ajaxSend (event, xhr, opt) ->
    s = $(this).children('.card-slot')
    if s and mainName = s.attr('card-name')
      opt.url += ((if opt.url.match /\?/ then '&' else '?') + 'main=' + escape(mainName))



  

warn = (stuff) -> console.log stuff if console?
