Wagn.Editor = Class.create();
Wagn.Editor.prototype = {
  initialize: function(card) {
    this.card = card;
    this.slot = card.slot;
    this.setup();
  },
  context: function() {
    return this.slot.chunk('editor_context').innerHTML;
  },
  setup: function() { /* nada */ },
  view: function() { alert( 'no setup function for this class')  },
  edit: function() { alert( 'no setup function for this class') },
  cancel: function () { this.view() },
  before_save: function() { 
    /* set chunk('raw').innerHTML if necessary--  wikiwyg does this by default.   */
  },
  save_new: function(form) {
    
  },
  refresh_on_cancel: function() { return false;  }
}



