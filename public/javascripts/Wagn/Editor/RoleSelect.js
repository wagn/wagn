Wagn.Editor.RoleSelect = Class.create();
Object.extend(Wagn.Editor.RoleSelect.prototype,Wagn.Editor.prototype)
Object.extend(Wagn.Editor.RoleSelect.prototype, {
  setup: function() { /* nada  */ },
  view: function() {  /* nil   */ },
  edit: function() {  
    this.set_values( this.card.content() );
  },
  before_save: function() {  
    this.card.content( Form.Element.getValue( this.select_box() ).join(',') );
    return true;
  },
  select_box: function() {
    return $(this.slot.id + '-role-select');
  },
  set_values: function( string ) {
    values = string.split(',');
    element = this.select_box();
    for (var i = 0; i < element.length; i++) {
      var opt = element.options[i];
      if (values.include(opt.value)) {
        opt.selected=true;
      } else {
        opt.selected = false;
      }
    }
  }
});

