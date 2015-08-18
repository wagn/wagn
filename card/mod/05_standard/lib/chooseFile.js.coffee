$.extend wagn,
  chooseFile: (e, data) ->
    data.form.find('button[type=submit]').attr('disabled',true)
    editor = $(this).closest '.card-editor'
    editor.find('.choose-file').hide()
    $('#progress').show()
    editor.append '<input type="hidden" class="extra_upload_param" value="true" name="attachment_upload">'
    editor.append '<input type="hidden" class="extra_upload_param" value="preview_editor" name="view">'
    data.submit()
    editor.find('.extra_upload_param').remove()

  progressallFile: (e, data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    $('#progress .progress-bar').css('width', progress + '%')

  doneFile: (e, data) ->
    editor = $(this).closest '.card-editor'
    editor.find('.chosen-file').replaceWith data.result
    data.form.find('button[type=submit]').attr('disabled',false)
