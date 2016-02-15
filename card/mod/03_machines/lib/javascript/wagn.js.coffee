$.extend wagn,
  initializeEditors: (range, map) ->
    map = wagn.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each range.find(selector), ->
        fn.call $(this)

  prepUrl: (url, slot)->
    xtra = {}
    main = $('#main').children('.card-slot').data 'cardName'
    xtra['main'] = main if main?
    if slot
      xtra['is_main'] = true if slot.isMain()
      slotdata = slot.data 'slot'
      wagn.slotParams slotdata, xtra, 'slot' if slotdata?

    url + ( (if url.match /\?/ then '&' else '?') + $.param(xtra) )

  slotParams: (raw, processed, prefix)->
    $.each raw, (key, value)->
      cgiKey = prefix + '[' + snakeCase(key) + ']'
      if key == 'items'
        wagn.slotParams value, processed, cgiKey
      else
        processed[cgiKey] = value

  slotReady: (func)->
    $('document').ready ->
      $('body').on 'slotReady', '.card-slot', (e) ->
        e.stopPropagation()
        func.call this, $(this)
  pingName: (name, success)->
    $.getJSON wagn.rootPath + '/', { format: 'json', view: 'status', 'card[name]': name }, success

jQuery.fn.extend {
  slot: ->
    if @data('slot-selector')
      target_slot = @closest(@data('slot-selector'))
      parent_slot = @closest '.card-slot'

      # if slot-selector doesn't apply to a child, search in all parent slots and finally in the body
      while target_slot.length == 0 and parent_slot.length > 0
        target_slot = $(parent_slot).find(@data('slot-selector'))
        parent_slot = $(parent_slot).parent().closest '.card-slot'
      if target_slot.length == 0
        $('body').find(@data('slot-selector'))
      else
        target_slot
    else
      @closest '.card-slot'

  setSlotContent: (val) ->
    s = @slot()
    v = $(val)
    unless v[0]
    #   if slotdata = s.attr 'data-slot'
    #     v.attr 'data-slot', slotdata if slotdata?
    # else #simple text (not html)
      v = val
    s.replaceWith v
    v.trigger 'slotReady'
    v

  slotSuccess: (data) ->
    if data.redirect
      window.location=data.redirect
    else
      notice = @attr('notify-success')
      newslot = @setSlotContent data

      if newslot.jquery # sometimes response is plaintext
        wagn.initializeEditors newslot
        if notice?
          newslot.notify notice

  slotError: (status, result) ->
    if status == 403 #permission denied
      @setSlotContent result
    else
      @notify result
      if status == 409 #edit conflict
        @slot().find('.current_revision_id').val @slot().find('.new-current-revision-id').text()
      else if status == 449
        @slot().find('g-recaptcha').reloadCaptcha()

  notify: (message) ->
    slot = @slot()
    notice = slot.find '.card-notice'
    unless notice[0]
      notice = $('<div class="card-notice"></div>')
      form = slot.find('.card-form')
      if form[0]
        $(form[0]).append notice
      else
        slot.append notice
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

  reloadCaptcha: ->
    this[0].empty()
    grecaptcha.render this[0],
      sitekey: wagn.recaptchaKey

  autosave: ->
    slot = @slot()
    return if @attr 'no-autosave'
    multi = @closest '.form-group'
    if multi[0]
      return unless id = multi.data 'cardId'
      reportee = ': ' + multi.data 'cardName'
    else
      id = slot.data 'cardId'
      reportee = ''

    # #might be better to put this href base in the html
    submit_url  = wagn.rootPath + '/update/~' + id
    form_data = $('#edit_card_'+id).serializeArray().reduce( ((obj, item) ->
      obj[item.name] = item.value
      return obj
    ), { 'draft' : 'true', 'success[view]' : 'blank'});
    $.ajax submit_url, {
      data : form_data,
      type : 'POST'
    }
    ##{ 'card[content]' : @val() },

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


  $('body').on 'ajax:success', '.slotter', (event, data, c, d) ->
    unless event.slotSuccessful
      slot_top_pos = $(this).slot().offset().top
      $(this).slotSuccess data
      # should scroll to top after clicking on new page
      if $(this).hasClass "card-paging-link"
        $("body").scrollTop slot_top_pos
      event.slotSuccessful = true

  $('body').on 'loaded.bs.modal', null, (event) ->
    unless event.slotSuccessful
      wagn.initializeEditors $(event.target)
      $(event.target).find(".card-slot").trigger("slotReady")
      event.slotSuccessful = true

  $('body').on 'ajax:error', '.slotter', (event, xhr) ->
    $(this).slotError xhr.status, xhr.responseText

  $('body').on 'click', 'button.slotter', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote $(this)

  $('body').on 'ajax:beforeSend', '.slotter', (event, xhr, opt)->
    return if opt.skip_before_send

    unless opt.url.match /home_view/ #avoiding duplication.  could be better test?
      opt.url = wagn.prepUrl opt.url, $(this).slot()

    if $(this).is('form')
      if wagn.recaptchaKey and $(this).attr('recaptcha')=='on' and !($(this).find('.g-recaptcha')[0])
        if $('.g-recaptcha')[0]  # if there is already a recaptcha on the page then we don't have to load the recaptcha script
          addCaptcha(this)
        else
          initCaptcha(this)
        return false

      if data = $(this).data 'file-data'
        # NOTE - this entire solution is temporary.
        input = $(this).find '.file-upload'
        if input[1]
          $(this).notify "Wagn does not yet support multiple files in a single form."
          return false

        widget = input.data 'blueimpFileupload' #jQuery UI widget
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

  $('body').on 'submit', '.card-form', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.card-content').attr('no-autosave','true')
    true

  $('body').on 'click', '.submitter', ->
    $(this).closest('form').submit()

  $('body').on 'click', '.renamer-updater', ->
    $(this).closest('form').find('#card_update_referencers').val 'true'

  $('body').on 'submit', '.edit_name-view .card-form', ->
    confirmer = $(this).find '.alert'
    if confirmer.is ':hidden'
      if $(this).find('#referers').val() > 0
        $(this).find('.renamer-updater').show()

      confirmer.show 'blind'
      false



  $('body').on 'click', '.follow-updater', ->
    $(this).closest('form').find('#card_update_all_users').val 'true'

  $('body').on 'submit', '.edit-view.SELF-Xfollow_default .card-form', ->
    confirmer = $(this).find '.confirm_update_all-view'
    if confirmer.is ':hidden'
      $(this).find('.follow-updater').show()

      confirmer.show 'blind'
      false


  $('body').on 'click', 'button.redirecter', ->
    window.location = $(this).attr('href')

  unless wagn.noDoubleClick
    $('body').on 'dblclick', 'div', (event) ->
      t = $(this)
      return false if t.closest( '.nodblclick'  )[0]
      # fail if inside a div with "nodblclick" class
      return false if t.closest( '.card-header' )[0]
      # fail if inside a card header
      s = t.slot()
      return false if s.find( '.card-editor' )[0]
      # fail if there is an editor open in your slot
      return false unless s.data('cardId')
      # fail if slot has not card id
      s.addClass 'slotter'
      s.attr 'href', wagn.rootPath + '/card/edit/~' + s.data('cardId')
      $.rails.handleRemote(s)
      false # don't propagate up to next slot

#  $('body').on 'dblclick', '.nodblclick', -> false

  $('body').on 'submit', 'form.slotter', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      if input and !(input.val().match /^REDIRECT/)
        input.val ( if target == 'REDIRECT' then target + ': ' + input.val() else target )

  $('body').on 'change', '.live-type-field', ->
    $(this).data 'params', $(this).closest('form').serialize()
    $(this).data 'url', $(this).attr 'href'

  $('body').on 'change', '.edit-type-field', ->
    $(this).closest('form').submit()

  $('body').on 'change', '.autosave .card-content', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500

  $('body').on 'mouseenter', '[hover_content]', ->
    $(this).attr 'hover_restore', $(this).html()
    $(this).html $(this).attr( 'hover_content' )
  $('body').on 'mouseleave', '[hover_content]', ->
    $(this).html $(this).attr( 'hover_restore' )

  $('body').on 'keyup', '.name-editor input', ->
    box =  $(this)
    name = box.val()
    wagn.pingName name, (data)->
      return null if box.val() != name # avert race conditions
      status = data['status']
      if status
        ed = box.parent()
        leg = box.closest('fieldset').find('legend')
        msg = leg.find '.name-messages'
        unless msg[0]
          msg = $('<span class="name-messages"></span>')
          leg.append msg
        ed.removeClass 'real-name virtual-name known-name'
        slot_id = box.slot().data 'cardId' # use id to avoid warning when renaming to name variant
        if status != 'unknown' and !(slot_id && parseInt(slot_id) == data['id'])
          ed.addClass status + '-name known-name'
          link =
          qualifier = if status == 'virtual' #wish coffee would let me use  a ? b : c syntax here
            'in virtual'
          else
            'already in'
          msg.html '"<a href="' + wagn.rootPath + '/' + data['url_key'] + '">' + name + '</a>" ' + qualifier + ' use'
        else
          msg.html ''

  $('body').on 'click', '.render-error-link', (event) ->
    msg = $(this).closest('.render-error').find '.render-error-message'
    msg.show()
#    msg.dialog()
    event.preventDefault()


# important: this prevents jquery-mobile from taking over everything
# $( document ).on "mobileinit", ->
#   $.extend $.mobile , {
#     #autoInitializePage: false
#     #ajaxEnabled: false
#   }


initCaptcha = (form)->
  recapDiv = $("<div class='g-recaptcha' data-sitekey='#{wagn.recaptchaKey}'></div>")
  $(form).children().last().after recapDiv
  recapUri = "https://www.google.com/recaptcha/api.js"
  $.getScript recapUri  # renders the first element with "g-recaptcha" class when loaded

# call this if the recaptcha script is already initialized (via initCaptcha)
addCaptcha = (form)->
  recapDiv = $('<div class="g-recaptcha"></div>')
  $(form).children().last().after recapDiv
  grecaptcha.render recapDiv,
    sitekey: wagn.recaptchaKey

snakeCase = (str)->
  str.replace /([a-z])([A-Z])/g, (match)-> match[0] + '_' + match[1].toLowerCase()

warn = (stuff) -> console.log stuff if console?
