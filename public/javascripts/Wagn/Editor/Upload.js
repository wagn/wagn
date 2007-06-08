Wagn.Editor.Upload = Class.create();
Object.extend(Wagn.Editor.Upload.prototype,Wagn.Editor.prototype)
Object.extend(Wagn.Editor.Upload.prototype, {
  setup: function() { /* nada  */ },
  view: function() {  /* nil   */ },
  edit: function() {  /* zip   */ },
  before_save: function() {
    $(this.slot.id + '-card-name').value = this.card.name();
    $(this.slot.id + '-upload-form').submit();
    return false;
  }
});

