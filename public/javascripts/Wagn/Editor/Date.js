Wagn.Editor.Date = Class.create();
Object.extend(Wagn.Editor.Date.prototype,Wagn.Editor.prototype)
Object.extend(Wagn.Editor.Date.prototype, {
  setup: function() { /* nada  */ },
  view: function() {  /* nil   */ },
  edit: function() { 
    element = $(this.slot.id + '-content-field');
    //info( "Editing Date " + element.id );
    element.innerHTML = this.card.content() || Form.Element.getValue( this.slot.id + '-date-default' );
    setTimeout( 'scwShow(scwID("'+element.id+'"),scwID("'+element.id+'"))', 100); 
  },
  before_save: function() {  
    this.card.content( $(this.slot.id + '-content-field').innerHTML );
    return true;
  }
});

