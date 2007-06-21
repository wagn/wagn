Wagn.CardSlot = {
  init: function( element ) {
    return Object.extend($(element), Wagn.CardSlot.prototype);
  },
  find_all_by_class: function( klass ) {
    if (klass=='all') { klass='card-slot'; }
    return document.getElementsByClassName( klass ).collect( function(e) {
      return Wagn.CardSlot.init(e);  
    });
  }
};

Wagn.CardSlot.prototype = {
  chunk: function( name ) {
    return document.getElementsByClassName( name, this )[0];
  },
  card: function() {
    return Wagn.CardTable[ this.id ];
  }
};


Wagn.Card = Class.create();
Object.extend(Wagn.Card.prototype, {
  initialize: function( slot ) {
    this.slot = Wagn.CardSlot.init(slot);  
    this.workspace = this.slot.chunk('workspace');
    this.login_url = document.location.href.gsub('^(.*\/\/[^\/]+)\/.*$',"#{1}/account/login");
    this._in_wadget = arguments[1];
    this._editor_loaded = false;    
    this._viewmode = 'view';  
    if (!this._in_wadget) {
      this.setupDoubleClickToEdit(); 
      if (Element.hasClassName(this.slot, 'new-card')) {
        warn("setting up new card");
        this.setupEditor();
      } else if (Element.hasClassName(this.slot, 'full')) { 
        warn("about to load editor");
        this.loadEditor(); 
      }                              
    }
    Wagn.CardTable[ slot.id ] = this;
  },
  loadEditor: function() {  
    if (this._in_wadget) { 
      warn("bailing cuzof wadget");
      return true; 
    }
    force_reload = arguments[0];
    edit_on_load = arguments[1];
    warn("loading Editor");
    if (force_reload) { this._editor_loaded = false; }
    if (this._editor_loaded) { 
      if (edit_on_load) { this.edit(); }
      return true; 
    }
    var self = this;   
    
    on_complete = (edit_on_load = arguments[1]) ? 
      function(request) { self.slowEdit() } :
      function(request) { self.setupEditor() };
      
    url = this.id() ? '/card/editor/' + this.id() :'/card/new';
      
    new Ajax.Updater( 
      this.slot.id + "-editor",  url, {
        parameters: this._common_parameters(),
        onComplete: on_complete
      }         
    );
    this._editor_loaded = true;
  },   
  setupEditor: function() {
    if (this.is_edit_ok()) {
      var jscript = 'new Wagn.Editor.' + this.editor_type() +'(this)';
      warn( this.slot.id + ': ' + jscript );
      this.editor = eval(jscript);
    } else {
      if (this.slot.chunk('edit')) {
        this.slot.chunk('edit').onClick=function(){};
        if (! Wagn.user()) {
          this.slot.chunk('edit').href=this.login_url;
          this.slot.chunk('options').onclick=function(){};
          this.slot.chunk('options').href=this.login_url;
        } else {                                               
          this.slot.chunk('edit').href='#';
          this.slot.chunk('edit').innerHTML="<em>locked</em>"; 
        }
      }
    }
  },
  slowEdit: function() { 
    this.setupEditor();
    setTimeout('Wagn.CardTable["'+ this.slot.id +'"].edit()', 250); 
  },
  is_new:        function() { return this.slot.chunk('new'); },
  is_edit_ok:    function() { return this.slot.chunk('edit-ok'); },
  is_connection: function() { return this.slot.chunk('connection'); },  
  in_popup:      function() { return $('popup').innerHTML.match(/true/);  },
  id: function() {
    return this.slot.className.split(/\s+/).select(function(e) { return e.match(/^\d+$/); })[0];    
  },
  name: function() {
    if (this.is_new()) {
      return $('new-card-name-field').value;
    } else {
      return this.slot.chunk('name').innerHTML;
    }
  },
  content: function() {
    if (arguments[0]) {
      //this.slot.chunk('raw').innerHTML = arguments[0];
      this.raw(arguments[0]);
      this.slot.chunk('cooked').innerHTML = arguments[0];
      warn("Set " + this.name() + "content = " + arguments[0] );
    } else {
      //return this.slot.chunk('raw').childNodes[0].nodeValue;  //don't escape html..
      return this.raw(); //slot.chunk('raw').innerHTML;
    }
  },
  raw: function() {
    if (arguments[0]) {
      this.slot.chunk('raw').innerHTML = arguments[0];
    } else {
      return this.slot.chunk('raw').innerHTML;
    }
  },
  datatype:    function() { return this.slot.chunk('datatype').innerHTML;  },
  editor_type: function() { return this.slot.chunk('editor-type').innerHTML; },
  codename:    function() { return this.slot.chunk('codename').innerHTML; },  
  revision_id: function() { return this.slot.chunk('revision-id').innerHTML; },
  set_revision_id: function(revision_id) { this.slot.chunk('revision-id').innerHTML=revision_id; },
  highlighted: function() {
    return this.slot.getStyle('background-color') == "rgb(221, 221, 221)" || 
      this.slot.getStyle('background-color') == "#dddddd";
  },
  highlight: function() {
    this.slot.setStyle({ 'background-color': "#dddddd" });  
  },
  dehighlight: function() {
    if (this.highlighted()) {
      new Effect.Highlight( this.slot, { startcolor:"#dddddd",endcolor: "#ffffff",restorecolor: "#ffffff"} );
    }
  },
  swap_line_and_paragraph: function() {  
    if (this.swapping) { return; }
    this.swapping = true;
    if ( Element.hasClassName(this.slot, "line")) {
      this.to_paragraph();
    } else {
      this.to_line();
    }
    setTimeout("$('" + this.slot.id + "').card().swapping=false",600);
  },      
  to_line: function () {                                               
    if (this._viewmode == 'options' || this._viewmode == 'changes') {
      this.view();
    }
    if (this._viewmode == 'view') { Wagn.paragraph_to_line( this.slot ); }
  },
  to_paragraph: function() {
    this.loadEditor();
    Wagn.line_to_paragraph( this.slot );
  },
  set_blank_name_to: function(new_name) {
    name = $('new-card-name-field');
    if (name && $F(name) == '') {
      name.value = new_name;
    }      
  },
  setupDoubleClickToEdit: function() {
    var self = this;

    Element.getElementsByClassName( this.slot, "editOnDoubleClick" ).each(function(el){
      if (typeof(el.attributes['inPopup'])!='undefined' && el.attributes['inPopup'].value=='true') {
        el.ondblclick=function(event) {                   
          if (card_id = Wagn.Card.getTranscludingCardId(Event.element(event))) {
            Wagn.Card.editTransclusion(card_id); 
            Event.stop(event);
          }
        }
      } else {
        el.ondblclick=function(event) { 
          Event.stop(event);
          self.loadEditor(false,true);
        }
      }
    });
  },
  view: function() {
    this.highlight_tab('view');
    this._viewmode = 'view';
    if (this.is_edit_ok()) { 
      this.editor.view(); 
      this.slot.chunk('editor').hide();
    }
    this.slot.chunk('card-links').show();
    this.slot.chunk('cooked').style.display = ''; //show w/o overriding block vs. inline
    this.slot.removeClassName('editing');
    if (this.slot.oldClass == 'line') {
      this.slot.oldClass = null;
      Wagn.paragraph_to_line(this.slot);
    } 
  },
  edit: function() {            
    if (!Wikiwyg.browserIsSupported) {
      alert("Sorry, Wagn doesn't support editing in your browser yet." +
            "Currently we support Internet Explorer 6 or newer and recent releases of Mozilla based browsers such as Firefox, Mozilla, and Camino");
      return;
    }
    this.slot.viewHeight = this.slot.offsetHeight;
    this.highlight_tab('edit');
    this._viewmode = 'edit';
    //console.log('set viewHeight: '+this.slot.viewHeight);
    if (this.slot.hasClassName("line")) {
      this.slot.oldClass = 'line';
      this.slot.removeClassName('line');
      this.slot.addClassName('paragraph');    
    }
    if (this.is_edit_ok()) { 
      this.slot.chunk('editor').show();
      this.slot.addClassName('editing');
      this.editor.edit();   
    } else { 
      document.location.href=this.login_url;
    }
  },
  changes: function() {
    this.update_workspace('revision', {
      rev: arguments[0] || '',
      mode: arguments[1] || ''
    });                     
    this._viewmode='changes';
    this.highlight_tab('changes');
    this.workspace.show();
  },
  options: function() {              
    this._viewmode='options';
    this.update_workspace('options');
    this.highlight_tab('options');
    this.workspace.show();
  },
  cancel: function() {
    this.highlight();
    this.view();
    if (this.editor.refresh_on_cancel()) {  
      this.loadEditor(true);
    }
    this.dehighlight();
    Windows.close('popup');
    
  },
  save: function() {
    if (this.editor.before_save) { 
      if (this.editor.before_save()) {
        this.continueSave();
      }
    }
  }, 
  continueSave: function() {
    card_content = this.content();
    //alert("card content = " + card_content );
    if (this.is_new()) {
      $('new-card-content-field').value = card_content;
      //alert( $('new-card-content').value );
      url = this.is_connection() ? '/connection/create' : '/card/create';
      new Ajax.Request( url,  {
          method: 'post',
          asynchronous:true, evalScripts:true,
          parameters:Form.serialize($('new-card-form')) 
      });
    } else {
      this.highlight();
      Wagn.Messenger.log( "saving " + this.name() + "..." );
      new Ajax.Request('/card/edit/' + this.id(), { 
          method: 'post',
          parameters: 'card[old_revision_id]=' + this.revision_id() + 
            '&card[content]=' + encodeURIComponent(card_content)
      });
      Windows.close('popup');
    }
  },
  save_draft: function() {
    if (this.is_new()) { 
      return;  // can't save drafts of new cards yet 
    }
    original_content = this.content(); 
    new_content = this.editor.get_draft();
    if (new_content != original_content) {
      Wagn.Messenger.log( "saving draft of " + this.name() + "..." );
      new Ajax.Request('/card/save_draft/' + this.id(), {
          method: 'post',
          parameters: 'card[content]=' + encodeURIComponent(new_content)
      });
    }
  },
  after_edit: function( revision_id, content, raw) {
    this.set_revision_id(revision_id);
    this.setSlot('editor-message','');
    this.setSlot('cooked',content);   
    this.setSlot('raw',raw);  
    // FIXME: this is hacked
    var self = this;
    document.getElementsByClassName( "transcludedContent" ).each(function(el){ 
      
      if (el.attributes['cardId'].value == self.id()) {
        el.innerHTML = content;
        //new Effect.Highlight( el );
      }
    })
    getNewWindowLinks();   
    this.setupDoubleClickToEdit();
  },
  editConflict: function( revision_id, changes ) {
    this.setSlot('editor-message',changes);
    this.set_revision_id(revision_id);
  },    
  setSlot: function( slot_name, value ) {
    if (this.slot.chunk(slot_name)) {
      this.slot.chunk(slot_name).innerHTML=value;
    }
  }, 
  rename_form: function( name ) {
    this.update_workspace( 'rename_form', { 'card[name]': $(this.slot.id+'-name-field').value } );
  },
  update_workspace: function( action ) {
    params = this._ajax_parameters( arguments[1] )
    params['method'] = 'get';
    new Ajax.Updater( this.workspace, '/card/' + action + '/' + this.id(), params ); 
  },
  remove:        function()             { this.standard_update('remove', {});                 },
  rollback:      function( revision )   { this.standard_update('rollback', { rev: revision }) },
  update:        function( attributes ) { this.standard_update('update', attributes );        },
  update_writer: function( attributes ) { this.standard_update('update_writer',attributes);   },
  update_reader: function( attributes ) { this.standard_update('update_reader',attributes);   }, 
  standard_update: function( method, attributes ) {
    new Ajax.Request( '/card/' + method + '/' + this.id(), this._ajax_parameters(attributes));
  },
  update_attribute: function( attr_name, attr_value ) {  
    //Wagn.messenger().note("attempting update( " + attr_name + ", " + attr_value + ")");
    var self = this;
    var attr_name = attr_name;
    new Ajax.Request( $A(['/card/attribute', this.id(), attr_name]).join('/'), {
      parameters: this._common_parameters({ value: attr_value }),
      onSuccess: function(request) {
        Wagn.messenger().note(self.name() + " " + attr_name + " updated: " + request.responseText);
        if (attr_name=='datatype') { self.loadEditor(true); }
      },
      onFailure: function(request) {
        Wagn.messenger().alert(self.name() + " " + attr_name + " update failed:" + request.responseText);
      }
    });
  },
  update_private: function( value ) {
    if (value=='edit') {
       Element.addClassName( this.slot.chunk('private-edit'), 'current');
       Element.removeClassName(this.slot.chunk('private-view'), 'current');
       this.update({ 'card[private]': false });
    } else {  // value == 'read'
       Element.addClassName( this.slot.chunk('private-view'), 'current');
       Element.removeClassName(this.slot.chunk('private-edit'), 'current');
       this.update({ 'card[private]': true });
    }
  }, 
  _common_parameters: function() {
    param_hash = arguments[0] ? arguments[0] : {};
    param_list = $A([ 'element=' + encodeURIComponent(this.slot.id) ]);
    $H(param_hash).each( function(pair) {
      param_list.push( pair.key + '=' + encodeURIComponent( pair.value ) );  
    });
    return param_list.join('&');
  },
  _ajax_parameters: function() {
    return { 
      asynchronous:true, 
      evalScripts: true,
      parameters: this._common_parameters(arguments[0])
    };
  },
  hide_all: function() {
    if (this.editor) { this.editor.view(); }
    this.workspace.hide()
    this.slot.chunk('cooked').hide();
    this.slot.chunk('card-links').hide();
    if (this.is_edit_ok()) {
      this.slot.chunk('editor').hide();
    }
  },
  highlight_tab: function(tab) {
    if (Element.hasClassName( this.slot.chunk(tab), 'current' )) {
      return;
    }
    this.hide_all();
    Element.removeClassName( this.slot.chunk('view'   ), 'current');
    Element.removeClassName( this.slot.chunk('edit'   ), 'current');
    Element.removeClassName( this.slot.chunk('changes'), 'current');
    Element.removeClassName( this.slot.chunk('options'), 'current');
    Element.addClassName( this.slot.chunk(tab), 'current');
  }
});

Object.extend(Wagn.Card, {
  table: function() { return Wagn.CardTable; },
  find: function( element ) {
    return $(element).card();  // assume it's already set up
  },
  findFirstById: function( card_id ) {
    return Wagn.Card.find_all_by_class( card_id ).first();
  },
  findByElement: function( element ) {
    return $(element).card();  // assume it's already set up
  },
  find_all_by_class: function() {
    card_id = arguments[0] ? arguments[0] : 'card-slot';
    return Wagn.CardSlot.find_all_by_class( card_id ).collect( function(s) { return s.card() })
  },
  init: function(element) {
    if ( Wagn.CardTable[element] ) {
      card = Wagn.CardTable[element];
      //card.setupEditor();
      return card;
    } else {
      slot = Wagn.CardSlot.init(element);
      return new Wagn.Card( slot );
    }
  },
  update: function( card_id, revision_id, content, raw ) {
    Wagn.Card.find_all_by_class( card_id ).each( function( card ) {
      card.after_edit( revision_id, content, raw );
    }); 
  },
  dehighlightAll: function( card_id ) {
    Wagn.Card.find_all_by_class( card_id ).each( function( card ) {
      card.dehighlight();   
    });
  },
  view: function( card_id ) {
    Wagn.Card.find_all_by_class( card_id ).each( function( card ) {
      card.view();   
    });
  },
  editConflict: function( card_id, revision_id, changes) {
    Wagn.Card.find_all_by_class( card_id ).each( function( card ) {
      card.editConflict(revision_id, changes);   
    });     
  },
  openPopup: function() {
    if (!Wagn.win) {
      Wagn.win = new Window('popup', {
         className: "mac_os_x", title: "Transclusion Editor",
         top:30, left:30, width:550, height:400,
         showEffectOptions: { duration: 0.2 },
         hideEffectOptions: { duration: 0.2 }
      });
    }    
    $('popup_content').innerHTML = '<div id="popup_target"></div>';
    if (arguments[0]) {
      $('popup_target').innerHTML = arguments[0];
    }
    Wagn.win.show();
  },
  editTransclusion: function( card_id ) {
    Wagn.Card.openPopup("loading...");
    new Ajax.Updater( 'popup_target', '/card/edit_transclusion/' + card_id );    
  },
  editInPopup: function( card_id ) {
    new Ajax.Updater( 'popup_target', '/card/edit_form/' + card_id, {
      asynchronous:true, evalScripts:true, onComplete:function(request){
        c = new Wagn.Card( Wagn.CardSlot.init('popup_cardslot') );
        setTimeout("Wagn.Card.find( 'popup_cardslot' ).edit()", 100);
      } 
    });
  },
  setupAll: function() {
    var in_wadget = arguments[0];
    Wagn.CardSlot.find_all_by_class('all').each( function( s ) {
      if (!s.chunk('wikiwyg_toolbar')) {
        //FIXME --need generic editor test 
        c = new Wagn.Card( s, in_wadget );
      }
    });
  },
  getTranscludingCardId: function(element) {
    if (element.hasAttribute('cardId')) {
      return element.attributes['cardId'].value;
    } else if (element.parentNode) {
      return this.getTranscludingCardId( element.parentNode );
    } else {
      return false;
    }
  }
});

