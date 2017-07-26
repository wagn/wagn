wagn.slotReady (slot) ->
  slot.find('select').each (i) ->
    load_select2($(this))
#  slot.find('.pointer-multiselect').each (i) ->
#    load_select2($(this))
#
#  slot.find('.pointer-select').each (i) ->
#    load_select2($(this))

load_select2 = ($select) ->
  # $(this).attr 'data-placeholder', '　'
  unless $select.hasClass("_no-select2")
    $select.select2()
