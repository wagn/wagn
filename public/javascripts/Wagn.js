// browser stuff shameless copy from wz tooltip
var tt_db = (document.compatMode && document.compatMode != "BackCompat")? document.documentElement : document.body? document.body : null,
tt_n = navigator.userAgent.toLowerCase();
var tt_op = !!(window.opera && document.getElementById),
tt_op6 = tt_op && !document.defaultView,
tt_ie = tt_n.indexOf("msie") != -1 && document.all && tt_db && !tt_op,
tt_n4 = (document.layers && typeof document.classes != "undefined"),
tt_n6 = (!tt_op && document.defaultView && typeof document.defaultView.getComputedStyle != "undefined"),
tt_w3c = !tt_ie && !tt_n6 && !tt_op && document.getElementById;
tt_n = "";

var DEBUGGING = false;

function copy_with_classes(element) {
  copy = document.createElement('span');
  copy.innerHTML = element.innerHTML;
  Element.classNames( element ).each(function(className) {
    Element.addClassName( copy, className );  
  });
  copy.hide();
  element.parentNode.insertBefore( copy, element );
  return copy;  
}

Object.extend(Wagn, {
  user: function() { return $('user'); },
  card: function(){ return Wagn.Card },
  lister: function() { return Wagn._lister },
  messenger: function(){ return Wagn.Messenger },
  cardTable: function() { return Wagn.CardTable },
  
  title_mouseover: function( targetClass ) {
    document.getElementsByClassName( targetClass ).each(function(elem) {
      Element.addClassName( elem, 'card-highlight');
      Element.removeClassName( elem, 'card');
    })
  },

  title_mouseout: function( targetClass ) {
    document.getElementsByClassName( targetClass ).each(function(elem) {
      Element.removeClassName( elem, 'card-highlight');
      Element.addClassName( elem, 'card');
    })
  },
  
  grow_line: function(element) {
    var elementDimensions = element.getDimensions();
    new Effect.BlindDown( element, {
      duration: 0.5,
      scaleFrom: 100,
      scaleMode: {originalHeight: elementDimensions.height*2, originalWidth: elementDimensions.width}
    });
//      afterSetup: function(effect) {
//        effect.element.makeClipping();
//        effect.element.setStyle({height: '0px'});
//      }

    
  },
  
  line_to_paragraph: function(element) {
//    if (tt_n6) {
      var oldElementDimensions = element.getDimensions();
      copy = copy_with_classes( element );
      copy.removeClassName('line');
      copy.addClassName('paragraph');
      var newElementDimensions = copy.getDimensions();
      copy.viewHeight = newElementDimensions.height;
      copy.remove();
      
      var percent = 100 * oldElementDimensions.height / newElementDimensions.height;
      var elementDimensions = newElementDimensions;
      new Effect.BlindDown( element, {
        duration: 0.5,
        scaleFrom: percent,
        scaleMode: {originalHeight: elementDimensions.height, originalWidth: elementDimensions.width},
        afterSetup: function(effect) {
          effect.element.makeClipping();
          effect.element.setStyle({height: '0px'});
          effect.element.show(); 
          effect.element.removeClassName('line');
          effect.element.addClassName('paragraph');     
        }
      });
/*    } else {
      Element.removeClassName(element,'line');
      Element.addClassName(element,'paragraph');
    }    
*/
  },
  paragraph_to_line: function(element) {
//    if (tt_n6) {
      var oldElementDimensions = element.getDimensions();
      copy = copy_with_classes( element );
      copy.removeClassName('paragraph');
      copy.addClassName('line');
      var newElementDimensions = copy.getDimensions();
      copy.remove();  
      
      var percent = 100 * newElementDimensions.height / oldElementDimensions.height;
      
      return new Effect.Scale(element, percent, 
        { 
          duration: 0.5,
          scaleContent: false, 
          scaleX: false,
          scaleFrom: 100,
          scaleMode: {originalHeight: oldElementDimensions.height, originalWidth: oldElementDimensions.width},
          restoreAfterFinish: true,
          afterSetup: function(effect) {
            effect.element.makeClipping();
            effect.element.setStyle({height: '0px'});
            effect.element.show(); 
          },  
          afterFinishInternal: function(effect) {
            effect.element.undoClipping();
            effect.element.removeClassName('paragraph');
            effect.element.addClassName('line');
          }
        }); 
/*    } else {
      Element.removeClassName(element, 'paragraph');
      Element.addClassName(element, 'line');
    }    
*/
  }

});



Wagn.highlight = function( group, id )  {  
  document.getElementsByClassName( group ).each(function(elem) { 
    Element.removeClassName( elem.id, 'current' );
  });
  Element.addClassName( group + '-' + id, 'current' );
}

/*
Wagn.Highlighter = Class.create();
Object.extend(Wagn.Highlighter.prototype, {
  initialize: function( element_class, current_class ) {
    this.element_class = element_class;
    this.current_class = current_class;
  },
  highlight: function( id ) {
    var self = this;
    document.getElementsByClassName( this.element_class ).each(function(elem) { 
      Element.removeClassName( elem.id, self.current_class );
    });
    Element.addClassName( this.element_class + '-' + id, this.current_class );
  }
});

          

//Wagn.highlighters = {};
//Wagn.highlighters['connection-menu'] = new Wagn.Highlighter( 'connection-menu', 'current' );
*/

/* ------------------ OnLoad --------------------*/

Wagn.runQueue = function(queue) {
  if (typeof(queue)=='undefined') { return }
  while (fn = queue.shift()) {
    fn.call();
  }
};
Wagn.onLoadQueue = $A([]);
Wagn.onSaveQueue = $H({});
Wagn.onCancelQueue = $H({});
Wagn.editors = $H({});

onload = function() {
  Wagn.Messenger.flash();
  Wagn.runQueue(Wagn.onLoadQueue);
  getNewWindowLinks();
  if (typeof(init_lister) != 'undefined') {
    Wagn._lister = init_lister();
    Wagn._lister.update();
  }
}

















/* ----------------THE REST IS JUNKYARD----------- */

/* premature generalization??
Wagn.Section = {
  init: function( element ) {
    return Object.extend($(element), Wagn.Section.prototype);
  }
};


Wagn.Section.prototype = {
  name: function() {
    return this.id;
  },
  body: function() {
    return $( this.name() + '-' + 'body' );
  },
  
};


Wagn.Connections = Class.create();

Wagn.Connections.prototype = {
  initialize: function() {
  },
  refresh: function() {
  }
}
*/


/*  this was in use with fckeditor I thinkg

function wagn_htmlize_node( parent ) {
  parent.innerHTML = wagn_htmlize_string( parent.innerHTML );
}

function wagn_htmlize_string( html ) {
  return html.replace( /\[\[(.*)\]\]/gi, '<a href="$1" class="__wagn_link" id="$1">$1</a>' );
}

function wagn_unhtmlize_node( parent ) {
  wiki_links = document.getElementsByClassName('__wagn_link', parent); 
  wiki_links.each( function( w ) {
    page_name = w.getAttribute('href');  
    Element.replace( w, "[[" + page_name + "]]" );
  });
  return parent;
}


*/


/*  doesn't appear to be in use..>

var section_loaded={};

function toggle_ajax_section( targetId, url ) {
  if (section_loaded[targetId]) {
    Element.toggle( targetId )
  } else {
    section_loaded[targetId] = true
    new Ajax.Updater( targetId, url,
     {asynchronous:true, evalScripts:true});
  } 
}
*/

