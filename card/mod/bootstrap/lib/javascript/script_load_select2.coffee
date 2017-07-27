wagn.slotReady (slot) ->
  slot.find('select:not(._no-select2)').each (i) ->
    $(this).select2()

#  slot.find('.pointer-multiselect').each (i) ->
#    load_select2($(this))
#
#  slot.find('.pointer-select').each (i) ->
#    load_select2($(this))
