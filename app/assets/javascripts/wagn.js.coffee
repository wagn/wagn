Wagn = new Object()
window.Wagn = Wagn

wagnOnload = ->
  Wagn.Messenger.flash()
  Wagn.runQueue(Wagn.onLoadQueue)
#  setupLinksAndDoubleClicks()


warn = (stuff) -> console.log stuff if console?

Wagn.Messenger = {  
  element: -> $('#alerts'),
  alert: (message) ->
    return if !@element()
    @element().innerHTML = '<span style="color:red; font-weight: bold">' + message + '</span>';
    #new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  note: (message) ->
    return if !@element()
    @element().innerHTML = message
    #new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  log: (message) ->
    return if !@element()
    @element().innerHTML = message; 
    #new Effect.Highlight( this.element(), {startcolor:"#eeeebb", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  flash: ->
    if $('#notice') && $('#error')
      flash = $('#notice').innerHTML + $('#error').innerHTML
      @alert(flash) if flash != ''
}

Wagn.runQueue = (queue) ->
  result = true
  if queue? then $.each queue, ->
    result = false if !@call()
  result

Wagn.onLoadQueue   = []
Wagn.onSaveQueue   = {}
Wagn.onCancelQueue = {}

Wagn.EditorContent = {
  '.tinymce-textarea': -> tinyMCE.getInstanceById( @id ).getContent()
}

$('.card-form').live 'submit.wagn', ->
#  $.each Wagn.EditorContent, () ->
  $.each $(this).find('.tinymce-textarea'), ->
    $(this).closest('.editor').find('#card_content')[0].value = tinyMCE.getInstanceById( @id ).getContent()

  

#Wagn.runQueue(Wagn.onSaveQueue['#{context}']


#t = tinyMCE.getInstanceById( '#{eid}-tinymce' ); $('#{eid}-hidden-content').value = t.getContent(); return true;}

jQuery([document, window]).bind('load', wagnOnload)
