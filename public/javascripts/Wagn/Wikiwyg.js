// WagN extensions to Wikiwyg

proto = new Subclass('Wagn.Wikiwyg', 'Wikiwyg');


Object.extend(Wagn.Wikiwyg.prototype, {
  setup: function(slot_id, card_id, card_name) {
    var conf = this.initial_config(); 
    /* if (!slot.chunk('nosave')) {
      conf.controlLayout = $A(['save', 'cancel', conf.controlLayout]).flatten();
    }
    */
    this._slot_id = slot_id; 
    this._card_name = card_name;
    this._raw_id = this._slot_id+'-raw-content';
    this._card_id = card_id;
    if (!conf.wysiwyg) { conf.wysiwyg = {} }
    conf.wysiwyg.iframeId = slot_id + '-iframe'; // need this?
    conf.iframeId = slot_id + '-iframe'; // need this?
    //this.iframeID = slot_id + '-iframe';
    this.createWikiwygArea( $(this._raw_id), conf );
    Wagn.Wikiwyg.wikiwyg_divs.push( this );
    this._autosave_interval = 20 * 1000; // 20 seconds
    return this;
  },
  getContent: function() {
    var self = this; 
    this.clean_spans();
    this.current_mode.toHtml( function(html) {
      self.fromHtml(html) 
    });
    return this.div.innerHTML;
  },
  start_timer :function() {
    this._interval = 0;
    this._timer_running = true;
    var self = this;
    setTimeout("Wagn.wikiwygs['"+this._slot_id+"'].run_timer();", this._autosave_interval);
  },
  stop_timer: function() {
    this._timer_running = false;
  },
  run_timer: function() {
    if (this._timer_running) {
      this.on_interval();
      setTimeout("Wagn.wikiwygs['"+this._slot_id+"'].run_timer();", this._autosave_interval);
    }
  },
  on_interval: function() {
    if (!this._timer_running) { return }
    this._interval += 1;    
    original_content = $(this._raw_id).innerHTML;
    new_content = Wagn.LinkEditor.editable_to_raw(this.getContent(), $(this._raw_id));
    if (this._card_id && new_content != original_content) {
      Wagn.Messenger.log( "saving draft of " + this._card_name + "..." );
      new Ajax.Request('/card/save_draft/' + this._card_id, {
          method: 'post',
          parameters: 'card[content]=' + encodeURIComponent(new_content)
      });
    }
  },
  get_draft: function() {
    return this.wikiwyg.innerSave('draft');
  },
  clean_spans: function () {
    // transform <span style="bold"> to <strong>, style:italice to <em>
    dom = this.current_mode.get_edit_document();
    //info("running tranfrom on " + dom);
    //info("BEFORE" + dom.body.innerHTML);
    $A(dom.getElementsByTagName("span")).reverse().each(function(elem) {
      warn("  SPAN " + elem);
      var strong = (elem.style["fontWeight"]=="bold") ;
      var em = (elem.style["fontStyle"]=="italic");
      if (em || strong) {
        var new_el='';
        if (em && strong) {
          new_el = Wikiwyg.createElementWithAttrs("strong", {}); 
          new_el.innerHTML="<em>" + elem.innerHTML + "</em>";
        } else {
          new_el = Wikiwyg.createElementWithAttrs( (em ? "em" : "strong"), {});
          new_el.innerHTML=elem.innerHTML;
        }
        elem.parentNode.replaceChild(new_el,elem);
      }
    });
    //info("AFTER" + dom.body.innerHTML);
  },
  

  initial_config: function() {
    var conf = {
      imagesLocation: '../../images/wikiwyg/',
      doubleClickToEdit: false,
      modeClasses: [
         'Wikiwyg.Wysiwyg'
      ],
      controlLayout: [
       'selector', 'bold', 'italic', 
       'ordered', 'unordered','indent','outdent'
      ],
      styleSelector: [ 'label','h1','h2','p' ],
      controlLabels: Object.extend(Wikiwyg.Toolbar.prototype.config, {
        spotlight: 'Spotlight',
        highlight: 'Highlight',
        h1: 'Header',
        h2: 'Subheader'
      })
    }
    if (!Wikiwyg.is_ie) {
      conf.controlLayout.push('link');
    }
    if ($('edit_html').innerHTML.match(/true/)) {
      conf.modeClasses.push(  "Wikiwyg.HTML");
      conf.controlLayout.push('mode_selector');
    }    
    return conf;
  }
});


Object.extend(Wagn.Wikiwyg, {
  wikiwyg_divs: [],

  addEventToWindow: function(window, name, func) {
    if (window.addEventListener) {
      name = name.replace(/^on/, '');
      window.addEventListener(name, func, false);
    }
    else if (window.attachEvent) {
      window.attachEvent(name, func);
    }
  },    
  getClipboardHTML: function() {
    var pframe = document.getElementById( '___WWHiddenFrame' ) ;
    if ( !pframe ) {
      pframe = document.createElement( 'iframe' ) ;
      pframe.id = '___WWHiddenFrame' ;
      /*
      pframe.style.visibility	= 'hidden' ;
      pframe.style.overflow		= 'hidden' ;
      pframe.style.position		= 'absolute' ;
      pframe.style.width		= 1 ;
      pframe.style.height		= 1 ;
      */
      document.body.appendChild( pframe ) ;
      pframe.contentDocument.designMode = 'on';
    }
    pdoc = pframe.contentDocument;
    pdoc.innerHTML = '';
    pdoc.execCommand( 'paste', false, null ) ;
    var sData = pdoc.innerHTML ;
    pdoc.innerHTML = '' ;
    
    return sData ;    
  }
})


Object.extend(Wikiwyg.Wysiwyg.prototype, {
  get_selection: function() {
    return this.edit_iframe.contentWindow.getSelection();
  },
  superEnableThis: Wikiwyg.Wysiwyg.prototype.enableThis,
  enableThis: function() {
    this.superEnableThis();
    //this.exec_command('styleWithCSS',false);
    //Wagn.Wikiwyg.addEventToWindow(this.edit_iframe.contentWindow, 'keypress',this.createKeyPressHandler());
  },
  do_link: function() {  
    l = new Wagn.LinkEditor( this );
    l.edit();
    return;
  },  
  do_bold: function() {
    this.exec_command('bold');
  },
  do_italic: function() {
    this.exec_command('italic');
  },
  do_spotlight: function() {
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',false); }
    this.exec_command('bold');
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',true); }
  },
  do_highlight: function() {
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',false); }
    this.exec_command('italic');
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',true); }
  },
  do_indent: function() {
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',false); }
    this.exec_command('indent');
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',true); }
  },
  do_outdent: function() {
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',false); }
    this.exec_command('outdent');
    if (!Wikiwyg.is_ie) { this.exec_command('styleWithCSS',true); }
  },
  do_norm: function() {
    this.exec_command('removeformat');
  },
  fromHtml: function(html) {
    var dom = document.createElement('div');
    dom.innerHTML = html; //Wagn.HtmlFilter.clean( html );
    this.sanitize_dom(dom);
    this.set_inner_html(dom.innerHTML);
  },
  pasteWithFilter: function() {
    // jesus what a hack
    html = Wagn.Wikiwyg.getClipboardHTML();
    //warn('html='+html);
  },
  createKeyPressHandler: function() {
    var self = this;
    return function(e) {
      var captureEvent = false;
      if ( e.ctrlKey && !e.shiftKey && !e.altKey )
      {
        switch ( e.which ) 
        {
          case 86 :	// V
          case 118 :	// v
            captureEvent = true;
            self.pasteWithFilter();
            break ;
        }
      }      
      if (captureEvent) {
        e.preventDefault();
        e.stopPropagation();
      }
    };
  }
});

Wikiwyg.Wysiwyg.prototype.config['editHeightAdjustment'] = 1.1;
  
Object.extend(Wikiwyg.Mode.prototype, {
  get_edit_height: function() {
    var base_height = this.wikiwyg.divHeight;
    if (base_height == '0') {
      base_height = this.wikiwyg.div.parentNode.parentNode.viewHeight - 40;
    }
    var height = parseInt( base_height * this.config.editHeightAdjustment );
    var min = this.config.editHeightMinimum;
    h =  height < min ? min : height;
    max = window.innerHeight - 100;
    h = h>max ? max : h;
    return h;    
  }
});

