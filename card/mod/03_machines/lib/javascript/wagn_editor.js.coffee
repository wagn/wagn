$.extend wagn,
  editorContentFunctionMap: {
    '.prosemirror-editor': -> prosemirrorContent @[0].id
    '.ace-editor-textarea': -> aceEditorContent this[0]
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
    '.prosemirror-editor': -> wagn.initProseMirror @[0].id
    '.ace-editor-textarea': -> wagn.initAce $(this)
    '.tinymce-textarea': -> wagn.initTinyMCE @[0].id
    '.pointer-list-editor': ->
      @sortable({handle: '.handle', cancel: ''})
      wagn.initPointerList @find('input')
    '.file-upload': -> wagn.upload_file(this)
    '.etherpad-textarea': ->
      $(this).closest('form')
      .find('.edit-submit-button')
      .attr('class', 'etherpad-submit-button')
  }

  initPointerList: (input) ->
    optionsCard = input.closest('ul').data('options-card')
    input.autocomplete {
      source: wagn.prepUrl wagn.rootPath + '/' + optionsCard +
              '.json?view=name_complete'
    }

  setTinyMCEConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    wagn.tinyMCEConfig = setter()

  initProseMirror: (el_id) ->
    createProseMirror(el_id, { "menuBar": true, "tooltipMenu": false })

  aceConfigByTypeCode: {
    default: (editor) ->
      editor.renderer.setShowGutter true
      editor.setTheme "ace/theme/github"
      editor.setOption "showPrintMargin", false
      editor.getSession().setTabSize 2
      editor.getSession().setUseSoftTabs true
      editor.setOptions maxLines: 30
  }

  configAceEditor: (editor, mode) ->
    configurer = wagn.aceConfigByTypeCode[mode] ||
                 wagn.aceConfigByTypeCode['default']
    configurer(editor)

  initAce: (textarea) ->
    #type_code = textarea.attr "data-card-type-code"
    #mode = wagn.aceModeByTypeCode[type_code]
    mode = textarea.attr "data-ace-mode"
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
    editor.getSession().setValue textarea.val()
    wagn.configAceEditor(editor, mode)
    return


  initTinyMCE: (el_id) ->
    # verify_html: false -- note: this option needed for empty
    #                             paragraphs to add space.
    conf = {
      plugins: 'autoresize'
      autoresize_max_height: 500
    }
    user_conf = if wagn.tinyMCEConfig? then wagn.tinyMCEConfig else {}
    hard_conf = {
      mode: 'exact'
      elements: el_id
      # CSS could be made optional, but it may involve migrating old legacy
      # *tinyMCE settings to get rid of stale stuff.
      content_css: wagn.cssPath
      entity_encoding: 'raw'
    }
    $.extend conf, user_conf, hard_conf
    tinyMCE.init conf

pointerContent = (vals) ->
  list = $.map $.makeArray(vals), (v) -> if v then '[[' + v + ']]'
  $.makeArray(list).join "\n"

aceEditorContent = (element) ->
  ace_div = $(element).siblings(".ace_editor")
  editor = ace.edit(ace_div[0])
  editor.getSession().getValue()

prosemirrorContent = (id) ->
  content = getProseMirror(id).getContent('html')
  return '' if content == '<p></p>'
  content

permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').is(':checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))