$(window).ready ->
#navbox mod
  $('._navbox').autocomplete {
    html: 'html',
    source: navbox_results,
    select: navbox_select
# autoFocus: true,
# this makes it so the first option ("search") is pre-selected.
# sadly, it also causes odd navbox behavior, resetting the search term
  }

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
    error: ->
      response [] if this.wagReq == reqIndex
  }

navboxize = (term, results) ->
  items = []

  $.each ['search', 'add', 'new'], (index, key) ->
    if val = results[key]
      i = {
        value: term,
        prefix: key,
        icon: 'add',
        label: '<strong class="highlight">' + term + '</strong>'
      }
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
    items.push {
      icon: 'arrow_forward', prefix: 'go to', value: val[0], label: val[1],
      href: '/' + val[2]
    }

  $.each items, (index, i) ->
    i.label =
      '<i class="material-icons">' + i.icon + '</i>' +
      '<span class="navbox-item-label">' + i.prefix + ':</span> ' +
      '<span class="navbox-item-value">' + i.label + '</span>'

  items

navbox_select = (event, ui) ->
  if ui.item.term
    $(this).closest('form').submit()
  else
    window.location = wagn.rootPath + ui.item.href

  $(this).attr('disabled', 'disabled')