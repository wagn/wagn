
wagn.initializeEditors = (range, map) ->
  map = wagn.editorInitFunctionMap unless map?
  $.each map, (selector, fn) ->
    $.each range.find(selector), ->
      fn.call $(this)

wagn.prepUrl = (url, slot)->
  xtra = {}
  main = $('#main').children('.card-slot').attr 'card-name'
  xtra['main'] = main if main?
  if slot
    xtra['is_main'] = true if slot.isMain()
    $.each slot[0].attributes, (i, att)->
      if (m = att.name.match /^slot-(.*)$/) and att.value?
        xtra['slot[' + m[1] + ']' ] = att.value

  url + ( (if url.match /\?/ then '&' else '?') + $.param(xtra) )

jQuery.fn.extend {
  slot: -> @closest '.card-slot'

  setSlotContent: (val) ->
    s = @slot()
    v = $(val)
    if val[0]
      $.each s[0].attributes, (i, att)->
        if att.name.match(/^slot-.*/) && att.value?
          v.attr att.name, att.value
    else #simple text (not html)
      v = val
    s.replaceWith v
    v

  notify: (message) ->
    notice = @slot().find '.card-notice'
    return false unless notice[0]
    notice.html message
    notice.show 'blind'

  report: (message) ->
    report = @slot().find '.card-report'
    return false unless report[0]
    report.hide()
    report.html message
    report.show 'drop', 750
    setTimeout (->report.hide 'drop', 750), 3000

  isMain: -> @slot().parent('#main')[0]

  loadCaptcha: -> Recaptcha.create wagn.recaptchaKey, this[0]

  autosave: ->
    slot = @slot()
    return if @attr 'no-autosave'
    multi = @closest 'fieldset'
    if multi[0]
      return unless id = multi.attr 'card-id'
      reportee = ': ' + multi.attr 'card-name'
    else
      id = slot.attr 'card-id'
      reportee = ''

    #might be better to put this href base in the html

    $.ajax wagn.rootPath + '/card/save_draft/~' + id, {
      data : { 'card[content]' : @val() },
      type : 'POST',
      success: () -> slot.report 'draft saved' + reportee
    }

  setContentFieldsFromMap: (map) ->
    map = wagn.editorContentFunctionMap unless map?
    this_form = $(this)
    $.each map, (selector, fn)->
      this_form.setContentFields(selector, fn)
  setContentFields: (selector, fn) ->
    $.each @find(selector), ->
      $(this).setContentField(fn)
  setContentField: (fn)->
    field = @closest('.card-editor').find('.card-content')
    init_val = field.val() # tinymce-jquery overrides val(); that's why we're not using it.
    new_val = fn.call this
    field.val new_val
    field.change() if init_val != new_val
}

#~~~~~ ( EVENTS )

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000

$(window).ready ->
  $.ajaxSetup cache: false

  setTimeout (-> wagn.initializeEditors $('body')), 10
  #  dislike the timeout, but without this forms with multiple TinyMCE editors were failing to load properly

  $('body').delegate '.slotter', "ajax:success", (event, data) ->
    notice = $(this).attr('notify-success')
    newslot = $(this).setSlotContent data
    wagn.initializeEditors newslot
    if notice?
      newslot.notify notice

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
    $.rails.handleRemote $(this)

  $('.slotter').live 'ajax:beforeSend', (event, xhr, opt)->
    return if opt.skip_before_send

    unless opt.url.match /home_view/ #avoiding duplication.  could be better test?
      opt.url = wagn.prepUrl opt.url, $(this).slot()

    if $(this).is('form')
      if wagn.recaptchaKey and $(this).attr('recaptcha')=='on' and !($(this).find('.recaptcha-box')[0])
         newCaptcha(this)
         return false

      if data = $(this).data 'file-data'
        # NOTE - this entire solution is temporary.
        input = $(this).find '.file-upload'
        if input[1]
          $(this).notify "Wagn does not yet support multiple files in a single form."
          return false
        widget = input.data 'fileupload' #jQuery UI widget

        unless widget._isXHRUpload(widget.options) # browsers that can't do ajax uploads use iframe
          $(this).find('[name=success]').val('_self') # can't do normal redirects.
          # iframe response not passed back; all responses treated as success.  boo
          opt.url += '&simulate_xhr=true'
          # iframe is not xhr request, so would otherwise get full response with layout
          iframeUploadFilter = (data)-> data.find('body').html()
          opt.dataFilter = iframeUploadFilter
          # gets rid of default html and body tags

        args = $.extend opt, (widget._getAJAXSettings data), url: opt.url
        # combines settings from wagn's slotter and jQuery UI's upload widget
        args.skip_before_send = true #avoid looping through this method again

        $.ajax( args )
        false

  $('body').delegate '.card-form', 'submit', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

#  $('.submitter').live 'click', ->
#    $(this).closest('form').submit()
   
  $('.renamer-updater').live 'click', ->
    $(this).closest('form').find('.update_referencers').val 'true'
        
  $('body').delegate '.card-name-form', 'submit', (event) ->
    confirmer = $(this).find '.confirm-rename'
    if confirmer.is ':hidden'
      if $(this).find('#referers').val() > 0
        $(this).find('.renamer-updater').show()
        
      confirmer.show 'blind'
      false
    
  $('body').delegate 'button.redirecter', 'click', ->
    window.location = $(this).attr('href')

  unless wagn.noDoubleClick
    $('.card-slot').live 'dblclick', (event)->
      s = $(this)
      return false if s.find( '.card-editor' )[0]
      return false if s.closest( '.card-header' )[0]
      return false unless s.attr('card-id')
      s.addClass 'slotter'
      s.attr 'href', wagn.rootPath + '/card/edit/~' + s.attr('card-id')
      $.rails.handleRemote(s)
      false # don't propagate up to next slot

  $('.nodblclick').live 'dblclick', -> false

  $('body').delegate 'form.slotter', 'submit', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      if input and !(input.val().match /^REDIRECT/)
        input.val ( if target == 'REDIRECT' then target + ': ' + input.val() else target )

  #more of this info should be in views; will need to refactor for HTTP DELETE anyway...
  $('.card-slot').delegate '.standard-delete', 'click', ->
    return if $(this).attr('success-ready') == 'true' #prevent double-click weirdness
    s = if $(this).isMain() then 'REDIRECT: *previous' else 'TEXT:' + $(this).slot().attr('card-name') + ' removed'
    $(this).attr 'href', $(this).attr('href') + '?success=' + encodeURIComponent(s)
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

  $('[hover_content]').live 'mouseenter', ->
    $(this).attr 'hover_restore', $(this).html()
    $(this).html $(this).attr( 'hover_content' )
  $('[hover_content]').live 'mouseleave', ->
    $(this).html $(this).attr( 'hover_restore' )
    
  $('.name-editor input').live 'keyup', ->
    box =  $(this)
    name = box.val()
    wagn.pingName name, (data)->
      return null if box.val() != name # avert race conditions
      status = data['status']
      ed = box.parent()
      inst = box.closest('fieldset').find '.instruction'
      ed.removeClass 'real-name virtual-name known-name'
      slot_id = box.slot().attr 'card-id' # use id to avoid warning when renaming to name variant
      if status != 'unknown' and !(slot_id && parseInt(slot_id) == data['id'])
        ed.addClass status + '-name known-name'
        link = 
        qualifier = if status == 'virtual' #wish coffee would let me use  a ? b : c syntax here
          'in virtual'
        else
          'already in'
        inst.html '"<a href="' + wagn.rootPath + '/' + data['url_key'] + '">' + name + '</a>" ' + qualifier + ' use'
      else
        inst.html ''

newCaptcha = (form)->
  recapUri = 'http://www.google.com/recaptcha/api/js/recaptcha_ajax.js'
  recapDiv = $('<div class="recaptcha-box"></div>')
  $(form).children().last().after recapDiv
  $.getScript recapUri, -> recapDiv.loadCaptcha()



wagn.pingName = (name, success)->
  $.getJSON wagn.rootPath + '/', { format: 'json', view: 'status', 'card[name]': name }, success

warn = (stuff) -> console.log stuff if console?
