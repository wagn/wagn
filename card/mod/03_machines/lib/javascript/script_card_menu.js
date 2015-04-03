wagn.slotReady (slot) ->
  menu = $(slot).find('.open-menu.dropdown-toggle')
  if menu?
    $(menu).dropdown('toggle')

$(window).ready ->
  $('body').on 'click', '.toolbar .nav-pills > li', ->
    $(this).tab('show')

  $(document).on 'tap', '.card-header', (event) ->
    link = $(this).find('.card-menu > a')
    unless !link[0] or                                             # no gear
        event.pageX - $(this).offset().left < $(this).width() / 2  # left half of header

      link.click()
      event.preventDefault()

  $(document).on 'tap', 'body', (event) ->
    unless $(event.target).closest('.card-header')[0] or $(event.target).closest('.card-menu-link')[0]
      $('.card-menu .dropdown-toggle').dropdown('toggle')
