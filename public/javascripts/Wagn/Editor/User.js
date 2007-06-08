Wagn.Editor.User = Class.create();
Object.extend(Wagn.Editor.User.prototype,Wagn.Editor.RichText.prototype);
Object.extend(Wagn.Editor.User.prototype, {
  edit: function() {
    if (!Wikiwyg.is_ie) { Wagn.LinkEditor.before_edit( this ); } 
    if (this.context()!='invitation') {
      this.wikiwyg.editMode();
      this.start_timer();
    }
  },     
  before_save: function() {    
    if (this.context() != 'invitation') {
      this.wikiwyg.innerSave();
      if (!Wikiwyg.is_ie) { Wagn.LinkEditor.before_save( this ); }    
    }  
    
    if (this.context() == 'new' || this.context() == 'invitation') { 
      $('user-card-name-field').value = $('new-card-name-field').value;
      warn("user card name: " + $('user-card-name-field').value);
      //$('user-card-content-field').value = this.card.content();      
      //warn("user card content: " + $('user-card-content-field').value);
    }
    $(this.slot.id + '-user-update-form').onsubmit();
    return false;
  }
});

