wagn.addEditor(
  '.ace-editor-textarea',
  ->
    wagn.initAce $(this),
  ->
    aceEditorContent this[0]
)

$.extend wagn,
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

aceEditorContent = (element) ->
  ace_div = $(element).siblings(".ace_editor")
  editor = ace.edit(ace_div[0])
  editor.getSession().getValue()