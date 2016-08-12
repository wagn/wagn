wagn.addEditor(
  '.tinymce-textarea',
  ->
    wagn.initTinyMCE @[0].id
  ->
    tinyMCE.get(@[0].id).getContent()
)

$.extend wagn,
  setTinyMCEConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    wagn.tinyMCEConfig = setter()

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
