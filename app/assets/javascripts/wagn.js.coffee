Wagn = new Object()
window.Wagn = Wagn

wagnOnload = ->
  Wagn.Messenger.flash()
  Wagn.runQueue(Wagn.onLoadQueue)
#  setupLinksAndDoubleClicks()


window.wagnOnload = wagnOnload

warn = -> console.log stuff if typeof console != 'undefined'

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
  if typeof queue != 'undefined'
    jQuery.each queue, (index, fn) ->
      result=false if !fn.call()
  result

Wagn.onLoadQueue   = []
Wagn.onSaveQueue   = {}
Wagn.onCancelQueue = {}


jQuery([document, window]).bind('load', wagnOnload)
