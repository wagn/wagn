wagn.editorContentFunctionMap['.prosemirror-editor'] = ->
  prosemirrorContent @[0].id
wagn.editorInitFunctionMap['.prosemirror-editor'] = ->
  wagn.initProseMirror @[0].id

  setProseMirrorConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    wagn.proseMirrorConfig = setter()

  initProseMirror: (el_id) ->
    conf = {
      menuBar: true,
      tooltipMenu: false
    }
    hard_conf = { docFormat: "html" }
    user_conf = if wagn.proseMirrorConfig? then wagn.proseMirrorConfig else {}
    $.extend conf, user_conf, hard_conf
    createProseMirror(el_id, conf)

prosemirrorContent = (id) ->
  content = getProseMirror(id).getContent('html')
  return '' if content == '<p></p>'
  content
