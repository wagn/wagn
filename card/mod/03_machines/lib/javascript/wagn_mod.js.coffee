
window.wagn ||= {} #needed to run w/o *head.  eg. jasmine


$.extend wagn,
  editorContentFunctionMap: {
    '.ace-editor-textarea': -> ace_editor_content this[0]
    '.tinymce-textarea': -> tinyMCE.get(@[0].id).getContent()
    '.pointer-select': -> pointerContent @val()
    '.pointer-multiselect': -> pointerContent @val()
    '.pointer-radio-list': -> pointerContent @find('input:checked').val()
    '.pointer-list-ul': ->
      pointerContent @find('input').map( -> $(this).val() )
    '.pointer-checkbox-list': ->
      pointerContent @find('input:checked').map( -> $(this).val() )
    '.pointer-select-list': ->
      pointerContent @find('.pointer-select select').map( -> $(this).val() )
    '.pointer-mixed': ->
      element = '.pointer-checkbox-sublist input:checked,\
                .pointer-sublist-ul input'
      pointerContent @find(element).map( -> $(this).val() )
    # must happen after pointer-list-ul, I think
    '.perm-editor': -> permissionsContent this
  }
  editorInitFunctionMap: {
    '.date-editor': -> @datepicker { dateFormat: 'yy-mm-dd' }
    'textarea': -> $(this).autosize()
    '.ace-editor-textarea': -> wagn.initAce $(this)
    '.tinymce-textarea': -> wagn.initTinyMCE @[0].id
    '.pointer-list-editor': ->
      @sortable({handle : '.handle', cancel : ''})
      wagn.initPointerList @find('input')
    '.file-upload': -> wagn.upload_file(this)
    '.etherpad-textarea': ->
      $(this).closest('form')
      .find('.edit-submit-button')
      .attr('class', 'etherpad-submit-button')
  }
  upload_file: (fileupload) ->
    # for file as a subcard in a form,
    # excess parameters are inlcuded in the request which cause errors.
    # only the file, type_id and attachment_card_name are needed
    # attachment_card_name is the original card name,
    # ex: card[subcards][+logo][image], card[file]
    $(fileupload).bind 'fileuploadsubmit', (e,data) ->
      $_this = $(this)
      card_name = $_this.siblings(".attachment_card_name:first").attr("name")
      type_id = $_this.siblings("#attachment_type_id").val()
      data.formData = {
        "card[type_id]": type_id,
        "attachment_upload": card_name
      }
    $_fileupload = $(fileupload)
    if $_fileupload.closest("form").attr("action").indexOf("update") > -1
      url = "/card/update/"+$(fileupload).siblings("#file_card_name").val()
    else
      url = "/card/create"
    $(fileupload).fileupload(
      url : url,
      dataType : 'html',
      done : wagn.doneFile,
      add : wagn.chooseFile,
      progressall : wagn.progressallFile
    )#, forceIframeTransport: true )

  initPointerList: (input)->
    optionsCard = input.closest('ul').data('options-card')
    input.autocomplete { source: wagn.prepUrl wagn.rootPath + '/' + optionsCard + '.json?view=name_complete' }

  setTinyMCEConfig: (string)->
    setter = ()->
      try
        $.parseJSON string
      catch
        {}
    wagn.tinyMCEConfig = setter()

  initAce: (textarea) ->
    type_code = textarea.attr "data-card-type-code"
    hash = {}
    hash["java_script"] = "javascript"
    hash["coffee_script"] = "coffee"
    hash["css"] = "css"
    hash["scss"] = "scss"
    hash["html"] = "html"
    hash["search_type"] = "json"
    hash["layout_type"] = "html"
    mode = hash[type_code]
    unless mode
      textarea.autosize()
      return
    editDiv = $("<div>",
      position: "absolute"
      width: "auto"
      height: textarea.height()
    ).insertBefore(textarea)
    textarea.css "visibility", "hidden"
    textarea.css "height", "0px"
    ace.config.set('basePath','/assets/ace')
    editor = ace.edit(editDiv[0])
    editor.renderer.setShowGutter true
    editor.getSession().setValue textarea.val()
    editor.setTheme "ace/theme/github"
    editor.getSession().setMode "ace/mode/" + mode
    editor.setOption "showPrintMargin", false
    editor.getSession().setTabSize 2
    editor.getSession().setUseSoftTabs true
    editor.setOptions maxLines: 30

    return


  initTinyMCE: (el_id) ->
    # verify_html: false -- note: this option needed for empty paragraphs to add space.
    conf = {
      plugins: 'autoresize'
      autoresize_max_height: 500
    }
    user_conf = if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {}
    hard_conf = {
      mode: 'exact'
      elements: el_id
      #CSS could be made optional, but it may involve migrating old legacy *tinyMCE settings to get rid of stale stuff.
      content_css: wagn.cssPath
      entity_encoding: 'raw'
    }
    $.extend conf, user_conf, hard_conf
    tinyMCE.init conf

# Can't get this to work yet.  Intent was to tighten up head tag.
#  initGoogleAnalytics: (key) ->
#    window._gaq.push ['_setAccount', key]
#    window._gaq.push ['_trackPageview']
#
#    initfunc = ()->
#      ga = document.createElement 'script'
#      ga.type = 'text/javascript'
#      ga.async = true
#      ga.src = `('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'`
#      s = document.getElementsByTagName('script')[0]
#      s.parentNode.insertBefore ga, s
#    initfunc()

  chooseFile: (e, data) ->
    data.form.find('button[type=submit]').attr('disabled',true)
    editor = $(this).closest '.card-editor'
    $('#progress').show()
    editor.append '<input type="hidden" class="extra_upload_param" value="true" name="attachment_upload">'
    editor.append '<input type="hidden" class="extra_upload_param" value="preview_editor" name="view">'
    data.submit()
    editor.find('.choose-file').hide()
    editor.find('.extra_upload_param').remove()

  progressallFile: (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('#progress .progress-bar').css('width', progress + '%')

  doneFile: (e, data) ->
    editor = $(this).closest '.card-editor'
    editor.find('.chosen-file').replaceWith data.result
    data.form.find('button[type=submit]').attr('disabled',false)

  isTouchDevice: ->
    if 'ontouchstart' of window or window.DocumentTouch and document instanceof DocumentTouch
      return true
    else
      return detectMobileBrowser()


  # source for this method: detectmobilebrowsers.com
  detectMobileBrowser = (userAgent) ->
    userAgent = navigator.userAgent or navigator.vendor or window.opera
    /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(userAgent) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(userAgent.substr(0, 4))


# sidebars

wrapDeckoLayout = () ->
  $footer  = $('body > footer').first()
  $('body > article, body > aside').wrapAll('<div class="container"/>')
  $('div.container > article, div.container > aside').wrapAll('<div class="row row-offcanvas">')
  if $footer
    $('body').append $footer

wrapSidebarToggle = (toggle) ->
  "<div class='container'><div class='row'>#{toggle}</div></div>"

sidebarToggle = (side) ->
  "<button class='offcanvas-toggle offcanvas-toggle-#{side} btn btn-secondary visible-xs' data-toggle='offcanvas-#{side}'><span class='glyphicon glyphicon-chevron-#{if side == 'left' then 'right' else 'left'}'/></button>"

singleSidebar = (side) ->
  $article = $('body > article').first()
  $aside   = $('body > aside').first()
  $article.addClass("col-xs-12 col-sm-9")
  $aside.addClass("col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-#{side}")
  if side == 'left'
    $('body').append($aside).append($article)
  else
    $('body').append($article).append($aside)

  wrapDeckoLayout()
  $article.prepend(wrapSidebarToggle(sidebarToggle(side)))


doubleSidebar = ->
  $article    = $('body > article').first()
  $asideLeft  = $('body > aside').first()
  $asideRight = $($('body > aside')[1])
  $article.addClass("col-xs-12 col-sm-6")
  $asideLeft.addClass("col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-left")
  $asideRight.addClass("col-xs-6 col-sm-3 sidebar-offcanvas sidebar-offcanvas-right")
  $('body').append($asideLeft).append($article).append($asideRight)

  wrapDeckoLayout()

  $article.prepend(wrapSidebarToggle("#{sidebarToggle('right')}#{sidebarToggle('left')}"))

$(window).ready ->

  #sidebar

  switch
    when $('body').hasClass('right-sidebar')
      singleSidebar('right')

    when $('body').hasClass('left-sidebar')
      singleSidebar('left')

    when $('body').hasClass('two-sidebar')
      doubleSidebar()

  $('[data-toggle="offcanvas-left"]').click ->
    $('.row-offcanvas').removeClass('right-active').toggleClass('left-active')
    $(this).find('span.glyphicon').toggleClass('glyphicon-chevron-left glyphicon-chevron-right')
  $('[data-toggle="offcanvas-right"]').click ->
    $('.row-offcanvas').removeClass('left-active').toggleClass('right-active')
    $(this).find('span.glyphicon').toggleClass('glyphicon-chevron-left glyphicon-chevron-right')




  $('body').on 'click', '.cancel-upload', ->
    editor = $(this).closest '.card-editor'
    editor.find('.choose-file').show()
    editor.find('.chosen-file').empty()
    editor.find('.progress').show()
    editor.find('#progress .progress-bar').css('width', '0%')
    editor.find('#progress').hide()


  #navbox mod
  $('.navbox').autocomplete {
    html: 'html',
    source: navbox_results,
    select: navbox_select
    # autoFocus: true,
    # this makes it so the first option ("search") is pre-selected.
    # sadly, it also causes odd navbox behavior, resetting the search term
  }



  #pointer mod
  $('body').on 'click', '.pointer-item-add', (event)->
    last_item = $(this).closest('.content-editor').find '.pointer-li:last'
    new_item = last_item.clone()
    input = new_item.find('input')
    input.val ''
    last_item.after new_item
    wagn.initPointerList(input)
    event.preventDefault() # Prevent link from following its href

  $('body').on 'click', '.pointer-item-delete', ->
    item = $(this).closest 'li'
    if item.closest('ul').find('.pointer-li').length > 1
      item.remove()
    else
      item.find('input').val ''

  $('body').on 'show.bs.tab', 'a.load[data-toggle=tab][data-url]', (e) ->
    tab_id = $(e.target).attr('href')
    url    = $(e.target).data('url')
    $(e.target).removeClass('load')
    $(tab_id).load(url)


  # toolbar mod
  $('body').on 'click', '.toolbar-pin.active', (e) ->
    e.preventDefault()
    $(this).blur()
    $('.toolbar-pin').removeClass('active').addClass('inactive')
    $.ajax '/*toolbar_pinned',
      type : 'PUT'
      data : 'card[content]=false'

  $('body').on 'click', '.toolbar-pin.inactive', (e) ->
    e.preventDefault()
    $(this).blur()
    $('.toolbar-pin').removeClass('inactive').addClass('active')
    $.ajax '/*toolbar_pinned',
      type : 'PUT'
      data : 'card[content]=true'



  # following mod
  $('body').on 'click', '.btn-item-delete', ->
    $(this).find('.glyphicon').addClass("glyphicon-hourglass").removeClass("glyphicon-remove")
  $('body').on 'click', '.btn-item-add', ->
    $(this).find('.glyphicon').addClass("glyphicon-hourglass").removeClass("glyphicon-plus")

  $('body').on 'mouseenter', '.btn-item-delete', ->
    $(this).find('.glyphicon').addClass("glyphicon-remove").removeClass("glyphicon-ok")
    $(this).addClass("btn-danger").removeClass("btn-primary")
  $('body').on 'mouseleave', '.btn-item-delete', ->
    $(this).find('.glyphicon').addClass("glyphicon-ok").removeClass("glyphicon-remove")
    $(this).addClass("btn-primary").removeClass("btn-danger")


  # modal mod

  $('body').on 'hidden.bs.modal', (event) ->
    modal_content = $(event.target).find('.modal-dialog > .modal-content')
    if $(event.target).attr('id') != 'modal-main-slot'
      slot = $( event.target ).slot()
      menu_slot = slot.find '.menu-slot:first'
      url  = wagn.rootPath + '/~' + slot.data('card-id')
      params = { view: 'menu' }
      params['is_main'] = true if slot.isMain()
      modal_content.empty()
      $.ajax url, {
        type : 'GET'
        data: params
        success : (data) ->
          menu_slot.replaceWith data
      }



#     for slot in $('.card-slot')
#       menu_slot = $(slot).find '.menu-slot:first'
#       if menu_slot.size() > 0
#         url  = wagn.rootPath + '/~' + $(slot).data('card-id')
#         params = { view: 'menu' }
#         params['is_main'] = true if $(slot).isMain()
#
#         $.ajax url, {
#           type: 'GET'
#           data: params
#           success : (data) ->
#             menu_slot.replaceWith data
#         }

#  $('body').on 'click', '.update-follow-link', (event) ->
#    anchor = $(this)
#    url  = wagn.rootPath + '/' + anchor.data('card_key') + '.json?view=follow_status'
#    modal =  anchor.closest('.modal')
#    modal.removeData()
#    $.ajax url, {
#      type : 'GET'
#      dataType : 'json'
#      success : (data) ->
#        tags = $(modal).parent().find('.follow-link')
#        tags.find('.follow-verb').html data.verb
#        tags.attr 'href', data.path
#        tags.attr 'title', data.title
#        tags.data 'follow', data
#    }

#  $('body').on 'click', '.follow-toggle', (event) ->
#    anchor = $(this)
#    url  = wagn.rootPath + '/update/' + anchor.data('rule_name') + '.json'
#    $.ajax url, {
#      type : 'POST'
#      dataType : 'json'
#      data : {
#        'card[content]' : '[[' + anchor.data('follow').content + ']]'
#        'success[view]' : 'follow_status'
#        'success[id]'   : anchor.data('card_key')
#      }
#      success : (data) ->
#        tags = anchor.closest('.modal').parent().find('.follow-toggle')
#        tags.find('.follow-verb').html data.verb
#        tags.attr 'title', data.title
#        tags.removeClass( 'follow-toggle-on follow-toggle-off').addClass data.class
#        tags.data 'follow', data
#    }
#    event.preventDefault() # Prevent link from following its href


  # permissions mod
  $('body').on 'click', '.perm-vals input', ->
    $(this).slot().find('#inherit').attr('checked',false)

  $('body').on 'click', '.perm-editor #inherit', ->
    slot = $(this).slot()
    slot.find('.perm-group input:checked').attr('checked', false)
    slot.find('.perm-indiv input').val('')

  # rstar mod
  $('body').on 'click', '.rule-submit-button', ->
    f = $(this).closest('form')
    checked = f.find('.set-editor input:checked')
    if checked.val()
      if checked.attr('warning')
        confirm checked.attr('warning')
      else
        true
    else
      f.find('.set-editor').addClass('attention')
      $(this).notify 'To what Set does this Rule apply?'
      false

#  $('body').on 'click', '.rule-cancel-button', ->
#    $(this).closest('tr').find('.close-rule-link').click()


  $('body').on 'click', '.submit-modal', ->
    $(this).closest('.modal-content').find('form').submit()

  #wagn_org mod (for now)
  $('body').on 'click', '.shade-view h1', ->
    toggleThis = $(this).slot().find('.shade-content').is ':hidden'
    toggleShade $(this).closest('.pointer-list').find('.shade-content:visible').parent()
    if toggleThis
      toggleShade $(this).slot()


  if firstShade = $('.shade-view h1')[0]
    $(firstShade).trigger 'click'


  # following not in use??

  $('body').on 'change', '.go-to-selected select', ->
    val = $(this).val()
    if val != ''
      window.location = wagn.rootPath + escape( val )

  # performance log mod
  $('body').on 'click', '.open-slow-items', ->

    panel = $(this).closest('.panel-group')
    panel.find('.open-slow-items').removeClass('open-slow-items').addClass('close-slow-items')
    panel.find('.toggle-fast-items').text("show < 100ms")
    panel.find('.duration-ok').hide()
    panel.find('.panel-danger > .panel-collapse').collapse('show').find('a > span').addClass('show-fast-items')

  $('body').on 'click', '.close-slow-items', ->
    panel = $(this).closest('.panel-group')
    panel.find('.close-slow-items').removeClass('close-slow-items').addClass('open-slow-items')
    panel.find('.toggle-fast-items').text("hide < 100ms")
    panel.find('.panel-danger > .panel-collapse').collapse('hide').removeClass('show-fast-items')
    panel.find('.duration-ok').show()

  $('body').on 'click', '.toggle-fast-items', ->
    panel = $(this).closest('.panel-group')
    if $(this).text() == 'hide < 100ms'
      panel.find('.duration-ok').hide()
      $(this).text("show < 100ms")
    else
      panel.find('.duration-ok').show()
      $(this).text("hide < 100ms")

  $('body').on 'click', '.show-fast-items', (event) ->
    $(this).removeClass('show-fast-items')
    panel = $(this).closest('.panel-group')
    panel.find('.duration-ok').show()
    panel.find('.show-fast-items').removeClass('show-fast-items')
    panel.find('.panel-collapse').collapse('show')
    event.stopPropagation()







toggleShade = (shadeSlot) ->
  shadeSlot.find('.shade-content').slideToggle 1000
  shadeSlot.find('.glyphicon').toggleClass 'glyphicon-triangle-right glpyphicon-triangle-bottom'

permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').is(':checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))

pointerContent = (vals) ->
  list = $.map $.makeArray(vals), (v)-> if v then '[[' + v + ']]'
  $.makeArray(list).join "\n"

ace_editor_content = (element) ->
  ace_div = $(element).siblings(".ace_editor")
  editor = ace.edit(ace_div[0])
  editor.getSession().getValue()

#navbox mod
reqIndex = 0 #prevents race conditions

navbox_results = (request, response) ->
  f = this.element.closest 'form'
  formData = f.serialize() + '&view=complete'

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
      i = { value: term, prefix: key, icon: 'plus', label: '<strong class="highlight">' + term + '</strong>' }
      if key == 'search'
        i.icon = key
        i.term = term
      else if key == 'add'
        i.href = '/card/new?card[name]=' + encodeURIComponent(val)
      else if key == 'new'
        i.type = 'add' # for icon
        i.href = '/new/' + val[1]

      items.push i

  $.each results['goto'], (index, val) ->
    items.push { icon: 'share-alt', prefix: 'go to', value: val[0], label: val[1], href: '/' + val[2] }

  $.each items, (index, i) ->
    i.label =
      '<span class="glyphicon glyphicon-'+ i.icon + '"></span><span class="navbox-item-label">' + i.prefix + ':</span> ' +
      '<span class="navbox-item-value">' + i.label + '</span>'

  items

navbox_select = (event, ui) ->
  if ui.item.term
    $(this).closest('form').submit()
  else
    window.location = wagn.rootPath + ui.item.href

  $(this).attr('disabled', 'disabled')








