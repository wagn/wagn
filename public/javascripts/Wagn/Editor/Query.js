Wagn.Editor.Query = Class.create();
Object.extend(Wagn.Editor.Query.prototype,Wagn.Editor.prototype)
Object.extend(Wagn.Editor.Query.prototype, {
  setup: function() { /* nada  */ },
  view: function() {  /* nil   */ },
  edit: function() { 
    //$(this.slot.id + '-content-field').value = this.card.content();
    return true;
  },
  before_save: function() {  
    this.card.content( Form.serialize($(this.slot.id + '-query-form')));
    return true;
  },
  refresh_on_cancel: function() { return true;  }

});

