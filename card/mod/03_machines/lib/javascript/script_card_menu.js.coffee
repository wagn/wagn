wagn.slotReady (slot) ->
  menu = $(slot).find('.open-menu.dropdown-toggle')
  if menu?
    $(menu).dropdown('toggle')

$(window).ready ->
  $('body').on 'click', '.toolbar .nav-pills > li', ->
    $(this).tab('show')

  if wagn.isTouchDevice()
    $('.show-on-hover').removeClass('show-on-hover')

