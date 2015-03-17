
window.wagn ||= {} #needed to run w/o *head.  eg. jasmine


$.extend wagn,
  editorContentFunctionMap: {
    '.tinymce-textarea'      : -> tinyMCE.get(@[0].id).getContent()
    '.pointer-select'        : -> pointerContent @val()
    '.pointer-multiselect'   : -> pointerContent @val()
    '.pointer-radio-list'    : -> pointerContent @find('input:checked').val()
    '.pointer-list-ul'       : -> pointerContent @find('input'        ).map( -> $(this).val() )
    '.pointer-checkbox-list' : -> pointerContent @find('input:checked').map( -> $(this).val() )
    '.pointer-select-list'   : -> pointerContent @find('.pointer-select select').map( -> $(this).val() )
    '.pointer-mixed'         : -> pointerContent @find('.pointer-checkbox-sublist input:checked, .pointer-sublist-ul input').map( -> $(this).val() )
    '.perm-editor'           : -> permissionsContent this # must happen after pointer-list-ul, I think
  }

  editorInitFunctionMap: {
    '.date-editor'           : -> @datepicker { dateFormat: 'yy-mm-dd' }
    'textarea'               : -> wagn.initAce $(this)#$(this).autosize()
    '.tinymce-textarea'      : -> wagn.initTinyMCE @[0].id
    '.pointer-list-editor'   : -> @sortable({handle: '.handle', cancel: ''}); wagn.initPointerList @find('input')
    '.file-upload'           : -> @fileupload( add: wagn.chooseFile )#, forceIframeTransport: true )
    '.etherpad-textarea'     : -> $(this).closest('form').find('.edit-submit-button').attr('class', 'etherpad-submit-button')
  }

  initPointerList: (input)->
    optionsCard = input.closest('ul').attr('options-card')
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
      width: textarea.width()
      height: textarea.height()
      class: textarea.attr("class")
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
    
    textarea.closest("form").submit ->
      textarea.val editor.getSession().getValue()
      return

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
    file = data.files[0]
  #  $(this).fileupload '_normalizeFile', 0, file # so file objects have same fields in all browsers
    $(this).closest('form').data 'file-data', data # stores data on form for use at submission time

    if name_field = $(this).slot().find( '.name-editor input' )
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

  openMenu: (link, tapped) ->
    l = $(link)
    cm = l.data 'menu'
    if !cm?
      cm = wagn.generateMenu l.slot(), l.data('menu-vars')
      l.data 'menu', cm
      cm.menu position: { my:'right top', at:'left-2 top-3' }, icons: { submenu:'ui-icon-carat-1-w' } 
      #TODO submenu should use glyphicon glyphicon-menu-left
    
    if tapped
      cm.addClass 'card-menu-tappable'
      
    cm.show()
    cm.position my:'right top', at:'right+2 top+2', of: link

  closeMenu: (menu) ->
    $(menu).hide()
    $(menu).menu "collapseAll", null, true

  
  generateMenu: (slot, vars) ->
    template_clone = $.extend true, {}, wagn.menu_template
    items = wagn.generateMenuItems template_clone, vars
  
    m = $( '<ul class="card-menu">' + items.join("\n") +  '</ul>' )
    slot.append m
    m

  generateMenuItems: (template, vars)->
    items = []
    $.each template, (index, i)->
      return true if i.if && !vars[i.if]
    
      if i.text
        i.text = i.text.replace /\%\{([^}]*)\}/, (m, val)-> vars[val]      
        i.text = $('<div/>').text(i.text).html() #escapes html
      
      item = 
        if i.raw
          i.raw
        else if i.link
          vars[i.link]
        else if i.plain
          '<a>' + i.plain + '</a>'
        else if i.page
          page = vars[i.page] || i.page
          text = i.text || page
          if page == vars['self']
            relpath = vars['linkname']
          else if page.match /^[\w\+\*]+$/
            relpath = page
          else
            relpath = '?' + $.param( 'card[name]' : page ) 
            
          '<a href="' + wagn.rootPath + '/' + relpath + '">' + text + ' &crarr;</a>'
        else
          wagn.generateStandardMenuItem i, vars

      if item
        if i.list
          if listsub = wagn.generateListTemplate i.list, vars 
            i.sub = listsub if listsub.length > 0

        if i.sub
          item += '<ul>' + wagn.generateMenuItems(i.sub, vars).join("\n") + '</ul>'
    
        items.push('<li>' + item + '</li>')
    items

  generateListTemplate: (list, vars)->
    items = []
    if list_vars = vars[list.name]
      $.each list_vars, (index, itemvars)->
        template = $.extend {}, list.template
        $.map template, (val, key)->
          template[key] = itemvars[template[key]] || template[key]
        items.push template
    
    if list.append
      items = items.concat list.append
  
    items

  generateStandardMenuItem: (i, vars)->
    params = i.path_opts || {}
  
    if i.related
      i.view='related'
      params['related'] = if typeof(i.related) == 'object'
        $.extend {}, i.related, name: vars[i.related.name]
      else
        i.text ||= i.related
        { 'name': '+*' + i.related }
      
    if i.view #following basically reproduces link_to_view.  make own function?
      path = wagn.rootPath + '/'
      if vars['creator']
        path += vars['linkname']
      else
        params['card[name]'] = vars['self']
      
      params['view'] = i.view unless i.view == 'home'      
      path += '?' + $.param(params) unless $.isEmptyObject params
      
      text = i.text || i.view
      '<a href="' + path + '" data-remote="true" class="slotter">' + text + '</a>'


$(window).ready ->

  $('body').on 'click', '.cancel-upload', ->
    editor = $(this).closest '.card-editor'
    editor.find('.chosen-file').hide()
    editor.find('.choose-file').show()
    $(this).closest('form').data 'file-data', null
    contentField = editor.find( '.upload-card-content' ).remove()

  #navbox mod
  $('.navbox').autocomplete {
    html: 'html',
    source: navbox_results,
    select: navbox_select
    # autoFocus: true,
    # this makes it so the first option ("search") is pre-selected.
    # sadly, it also causes odd navbox behavior, resetting the search term
  }

  $('body').on 'mouseenter', '.card-menu-link', ->
    wagn.openMenu this, false
    
  $('body').on 'mouseleave', '.card-menu', ->
    wagn.closeMenu this

  $(document).on 'tap', '.card-header', (event) ->
    link = $(this).find('.card-menu-link')
    unless !link[0] or                                             # no gear
        link.data('menu') or                                       # already has menu
        event.pageX - $(this).offset().left < $(this).width() / 2  # left half of header
      
      wagn.openMenu link, true
      event.preventDefault()
  
  $(document).on 'tap', 'body', (event) ->
    unless $(event.target).closest('.card-header')[0] or $(event.target).closest('.card-menu-link')[0]
      $('.card-menu').hide()
      # this and mouseleave should use a close menu method that handles collapsing. (though not seeing bad behavior...)

  $(document).on 'tap', '.ui-menu-icon', (event)->
    $(this).closest('li').trigger('mouseenter')
    event.preventDefault()


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

  $('body').on 'click', '.follow-toggle', (event) ->
    anchor = $(this)
    url  = wagn.rootPath + '/update/' + anchor.data('rule_name') + '.json'
    $.ajax url, {
      type : 'POST'
      dataType : 'json'
      data : {
        'card[content]' : '[[' + anchor.data('follow').content + ']]'
        'success[view]' : 'follow_status'
        'success[id]'   : anchor.data('card_key')
      }
      success : (data) ->
        tags = anchor.closest('.card-menu').find('.follow-toggle')
        tags.find('.follow-verb').html data.verb
        tags.attr 'title', data.title
        tags.removeClass( 'follow-toggle-on follow-toggle-off').addClass data.class
        tags.data 'follow', data
    }
    event.preventDefault() # Prevent link from following its href
    

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


  
