wagn.slotReady(function(slot) {
  slot.find('.modal.fade').on('loaded.bs.modal', function(e) {
    $(this).trigger('slotReady');
  });
  slot.find('[data-toggle=\'modal\']').off("click").on('click', function(e) {
    var $_this, href, modal_selector;
    e.preventDefault();
    e.stopPropagation();
    $_this = $(this);
    href = $_this.attr('href');
    modal_selector = $_this.data('target');
    $(modal_selector).modal('show');
    $.ajax({
      url: href,
      type: 'GET',
      success: function(html) {
        $(modal_selector + ' .modal-content').html(html);
        return $(modal_selector).trigger('loaded.bs.modal');
      },
      error: function(jqXHR, textStatus) {
        $(modal_selector + ' .modal-content').html(jqXHR.responseText);
        return $(modal_selector).trigger('loaded.bs.modal');
      }
    });
    return false;
  });
});