Wagn.Editor.PlainText = Class.create();
Object.extend(Wagn.Editor.PlainText.prototype,Wagn.Editor.prototype)
Object.extend(Wagn.Editor.PlainText.prototype, {
  setup: function() { /* nada  */ },
  view: function() {  /* nil   */ },
  edit: function() { 
    $(this.slot.id + '-content-field').value = this.card.content(); 
  },
  before_save: function() {  
    this.card.content( $(this.slot.id + '-content-field').value );
    return true;
  }
});

