Wagn.Editor.RichText = Class.create();
Object.extend(Wagn.Editor.RichText.prototype,Wagn.Editor.prototype);
Object.extend(Wagn.Editor.RichText.prototype, {
  setup: function() {
    warn("setting up Wikiwyg");
    this.wikiwyg = new Wagn.RichTextWikiwyg().setup(this.slot);
    warn("wikiwyg:" + this.wikiwyg);
    this.wikiwyg._card = this.card;
    this._autosave_interval = 20 * 1000; // 20 seconds
  },
  view: function() {
    this.wikiwyg.displayMode();
    this.stop_timer();
  },
  edit: function() {  
    if (!Wikiwyg.is_ie) { Wagn.LinkEditor.before_edit( this ); } 
    this.wikiwyg.editMode();
    this.start_timer();
  },
  get_draft: function() {
    return this.wikiwyg.innerSave('draft');
  },
  before_save: function() {
    this.wikiwyg.innerSave();  
    if (!Wikiwyg.is_ie) { Wagn.LinkEditor.before_save( this ); }    
    warn("content: " + this.card.content());
    return true;
  },
  start_timer: function() {
    this._interval = 0;
    this._timer_running = true;
    setTimeout("$('" + this.slot.id + "').card().editor.run_timer();", this._autosave_interval);
  },
  stop_timer: function() {
    this._timer_running = false;
  },
  run_timer: function() {
    if (this._timer_running) {
      this.on_interval();
      setTimeout("$('" + this.slot.id + "').card().editor.run_timer();", this._autosave_interval);
    }
  },
  on_interval: function() {
    this._interval += 1;
    this.card.save_draft();
  }
});

