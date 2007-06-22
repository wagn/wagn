Wagn.Link = Class.create();  
Object.extend(Wagn.Link, {
  new_from_link: function(link){
    return Object.extend(link, {
      is_bound: function() {
        return this.attributes['bound'] && this.attributes['bound'].value=='true';
      },         
     links_to: function() {
       return this.attributes['href'].value;
       /*if (this.is_bound()) {
          return this.innerHTML
        } else {
        }
        */
      },
      reads_as: function() {
        return this.innerHTML;
      },
      update_bound: function() {
        if (this.is_bound()) {
          this.attributes['href'].value = this.reads_as().linkify();
        }
      }
    });
  },
  new_from_text: function(text){
    link = Builder.node('a', { bound:true, href:text.linkify() }, [ text ]);
    return this.new_from_link(link);
  }
});

Object.extend(String.prototype, {
  linkify: function() {
    return this.gsub(/\s/,'_').gsub(/\%20/,'_');
  },
  unlinkify: function() {
    return this.gsub(/_/,' ').gsub(/\/wiki\//,'');
  }
});


Wagn.LinkEditor = Class.create();
Object.extend(Wagn.LinkEditor, {   
  before_edit: function( editor ){
    card = editor.card;
    generate_anchor = function(match) {
      reads_as = match[1];
      links_to = (match[2] ? match[2] : reads_as).linkify();
      bound = reads_as.linkify() == links_to ? true : false;    
      t = '<a bound="#{bound}" href="#{links_to}">#{reads_as}</a>';
      return new Template(t).evaluate({ 
        bound: bound, reads_as: reads_as, links_to: links_to 
      });
    };
    card.raw( card.raw().gsub(/\[\[([^\]]+)\]\]/, generate_anchor));    
    card.raw( card.raw().gsub(/\[([^\]]+)\]\[([^\]]+)\]/,generate_anchor));
  },    
  before_save: function( editor ){
    $A(editor.card.slot.chunk('raw').getElementsByTagName('a')).each(function(e) {   
      if (e.attributes['href']) {
        Wagn.Link.new_from_link(e).update_bound();
        Element.replace(e, '[' + e.innerHTML + '][' + e.attributes['href'].value + ']');
      }
    });
    return false; 
  }
});

Object.extend(Wagn.LinkEditor.prototype, {
  initialize: function( wysiwyg ) {  
    this.wysiwyg = wysiwyg;           
    this.selection = this.get_selection();

    // for now, only one can be active at a time
    Wagn.linkEditor=this;
  },                
  get_selection: function() {
    if (Wikiwyg.is_ie) {
      return this.wysiwyg.get_edit_document().selection;
    } else {
      return this.wysiwyg.get_edit_window().getSelection();
    }
  },    
  get_selection_text: function() {
    return this.get_selection().toString();
  }, 
  get_selection_ancestor: function() {
    return this.get_selection().getRangeAt(0).commonAncestorContainer;
  },     
  edit: function() {    
    // FIXME: This probably busts IE.
    node = this.get_selection_ancestor();
    if (link = this.inside_link_node(node)) { 
      this.link = Wagn.Link.new_from_link( link ); 
      this.new_link = false;
    } else if (this.node_contains_link(node)) {
      alert("Oops, can't link this text because there's a link inside it");
      return false;
    } else {
      this.link = Wagn.Link.new_from_text( this.get_selection_text() );
      this.new_link = true;
    }
    this.open_popup();
  },   
  inside_link_node: function(node) {
    if (node && node.tagName=='A') {
      return node;
    } else if (node.parentNode) {
      return this.inside_link_node(node.parentNode);
    } else {
      return false;
    }
  },
  node_contains_link: function(node) {
    if (node.getElementsByTagName && $A(node.getElementsByTagName('a')).length > 0 ) {
      return true;
    } else {
      return false;
    }
  },  
  replace_selection_with: function( node ) {
    r = this.get_selection().getRangeAt(0);
    r.deleteContents();
    r.insertNode( node );
  },
  save: function (reads_as, links_to) {        
    // set bound
    if (reads_as.linkify() == links_to.linkify()) {
      this.link.setAttribute('bound',true);
    } else {
      this.link.setAttribute('bound',false);
    }
    this.link.attributes['href'].value = links_to.linkify();
    this.link.innerHTML = reads_as;
    
    if (this.new_link) {
      this.replace_selection_with(link);
    } 
    Windows.close('linkwin');
  },
  unlink: function(reads_as) {
    if (!this.new_link) {
      Element.replace(this.link, reads_as);
    }
    Windows.close('linkwin');
  },
  cancel: function() {
    Windows.close('linkwin');
  }, 
  update_bounded: function() {
    if (this.link.is_bound()) {
      
    }
  },
  open_popup: function() {
    if (Wagn.linkwin) { 
      Wagn.linkwin.setLocation(30+window.scrollY, 30);
    } else {
      Wagn.linkwin = new Window('linkwin', {
         className: "mac_os_x", title: "Link Editor",
         top:30+window.scrollY, left:30, width:550, height:108,
         showEffectOptions: { duration: 0.2 },
         hideEffectOptions: { duration: 0.2 }
      });
    }
    $('linkwin_content').innerHTML = '<div id="link-editor">' +
      '<div><label>reads&nbsp;as:&nbsp;</label><input type="text" size="30" id="reads_as" /></div>' +
      '<div><label>links&nbsp;to:&nbsp;</label><input type="text" size="45" id="links_to" /></div>' +
      '<div class="buttons">' +
      '<input type="button" onclick="Wagn.linkEditor.save($F(\'reads_as\'), $F(\'links_to\'))" value="Save"/>' + 
      '<input type="button" onclick="Wagn.linkEditor.unlink($F(\'reads_as\'))" value="Delete Link"/>' + 
      '<input type="button" onclick="Wagn.linkEditor.cancel()" value="Cancel"/>' +
      '</div></div>';
    Wagn.Link.new_from_link(this.link).update_bound();
    $('reads_as').value = this.link.reads_as();
    $('links_to').value = this.link.links_to().unlinkify();
    Wagn.linkwin.show();
  }
  
});

