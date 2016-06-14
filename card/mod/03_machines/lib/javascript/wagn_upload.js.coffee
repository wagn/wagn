$.extend wagn,
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
      url: url,
      dataType: 'html',
      done: wagn.doneFile,
      add: wagn.chooseFile,
      progressall: wagn.progressallFile
    )#, forceIframeTransport: true )

  chooseFile: (e, data) ->
    data.form.find('button[type=submit]').attr('disabled',true)
    editor = $(this).closest '.card-editor'
    $('#progress').show()
    editor.append '<input type="hidden" class="extra_upload_param" ' +
                  'value="true" name="attachment_upload">'
    editor.append '<input type="hidden" class="extra_upload_param" ' +
                  'value="preview_editor" name="view">'
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

$(window).ready ->
  $('body').on 'click', '.cancel-upload', ->
    editor = $(this).closest '.card-editor'
    editor.find('.choose-file').show()
    editor.find('.chosen-file').empty()
    editor.find('.progress').show()
    editor.find('#progress .progress-bar').css('width', '0%')
    editor.find('#progress').hide()