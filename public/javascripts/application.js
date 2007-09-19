// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
Wagn = new Object();

function warn(stuff) {
  if (typeof(console) != 'undefined')
    console.log( stuff );
}

Wagn.CardTable = $H({});
Object.extend(Wagn.CardTable, {
  get: function(key) {
    return this[key]; 
  }
})


Wagn.Dummy = Class.create();

Wagn.Dummy.prototype = {
  initialize: function( num ) {
    this.number = num; 
  }
}
    
var Cookie = {
  set: function(name, value, daysToExpire) {
    var expire = '';
    if (daysToExpire != undefined) {
      var d = new Date();
      d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));
      expire = '; expires=' + d.toGMTString();
    }
    return (document.cookie = escape(name) + '=' + escape(value || '') + expire);
  },
  get: function(name) {
    var cookie = document.cookie.match(new RegExp('(^|;)\\s*' + escape(name) + '=([^;\\s]*)'));
    return (cookie ? unescape(cookie[2]) : null);
  },
  erase: function(name) {
    var cookie = Cookie.get(name) || true;
    Cookie.set(name, '', -1);
    return cookie;
  },
  accept: function() {
    if (typeof navigator.cookieEnabled == 'boolean') {
      return navigator.cookieEnabled;
    }
    Cookie.set('_test', '1');
    return (Cookie.erase('_test') === '1');
  }
};

Wagn.Messenger = {  
  element: function() { return $('alerts') },
  alert: function( message ) {
    this.element().innerHTML = '<span style="color:red; font-weight: bold">' + message + '</span>';
    new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  note: function(message) {
    this.element().innerHTML = message;
    new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  log: function( message ) {
    this.element().innerHTML = message; 
    new Effect.Highlight( this.element(), {startcolor:"#dddddd", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  flash: function() {
    flash = $('notice').innerHTML + $('error').innerHTML;
    if (flash != '') {
      this.alert(flash);
    }
  }
};


/*
Create the new window
*/
function openInNewWindow() {
  // Change "_blank" to something like "newWindow" to load all links in the same new window
  var newWindow = window.open(this.getAttribute('href'), '_blank');
  newWindow.focus();
return false;
}

/*
Add the openInNewWindow function to the onclick event of links with a class name of "non-html"
*/
function getNewWindowLinks() {
  // Check that the browser is DOM compliant
  if (document.getElementById && document.createElement && document.appendChild) {
    var link;
    var links = document.getElementsByTagName('a');
    for (var i = 0; i < links.length; i++) {
      link = links[i];
      // Find all links with a class name of "non-html"
      //if (/\bnon\-html\b/.exec(link.className)) {
      if (/\bexternal\b/.exec(link.className)) {
        link.onclick = openInNewWindow;
      }
    }
    objWarningText = null;
  }
}

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
  },
  
  line_to_paragraph: function(element) {
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
      duration: 0.3,
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
  },
  paragraph_to_line: function(element) {
    var oldElementDimensions = element.getDimensions();
    copy = copy_with_classes( element );
    copy.removeClassName('paragraph');
    copy.addClassName('line');
    var newElementDimensions = copy.getDimensions();
    copy.remove();  
    
    var percent = 100 * newElementDimensions.height / oldElementDimensions.height;
    
    return new Effect.Scale(element, percent, 
      { 
        duration: 0.3,
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
  }

});



Wagn.highlight = function( group, id )  {  
  document.getElementsByClassName( group ).each(function(elem) { 
    Element.removeClassName( elem.id, 'current' );
  });
  Element.addClassName( group + '-' + id, 'current' );
}

/* ------------------ OnLoad --------------------*/

Wagn.runQueue = function(queue) {
  if (typeof(queue)=='undefined') { return true; }
  result = true;
  while (fn = queue.shift()) {
    if (!fn.call()) {
      result = false;
    }
  }
  return result;
};
Wagn.onLoadQueue = $A([]);
Wagn.onSaveQueue = $H({});
Wagn.onCancelQueue = $H({});
Wagn.editors = $H({});

onload = function() {
  Wagn.Messenger.flash();
  Wagn.runQueue(Wagn.onLoadQueue);
  setupCardViewStuff();
  getNewWindowLinks();
  setupDoubleClickToEdit();
  if (typeof(init_lister) != 'undefined') {
    Wagn._lister = init_lister();
    Wagn._lister.update();
  }
}

setupCardViewStuff = function() {
  getNewWindowLinks();
  setupDoubleClickToEdit();
}                  


setupDoubleClickToEdit=function(container) {
  Element.getElementsByClassName( document, "createOnClick" ).each(function(el){
    el.onclick=function(event) {                   
      element = Event.element(event);
      card_name = getSlotSpan(element).attributes['cardname'].value;
      console.log("create  " +card_name);
      new Ajax.Request('/transclusion/create?context='+getSlotContext(element), {
        asynchronous: true, evalScripts: true,
        parameters: "card[name]="+encodeURIComponent(card_name)
      });
      Event.stop(event);
    }
  });
                               
  Element.getElementsByClassName( document, "editOnDoubleClick" ).each(function(el){
    el.ondblclick=function(event) {                   
      element = Event.element(event);
      span = getSlotSpan(element);   
      card_id = span.attributes['cardid'].value;
      if (span.hasClassName('line')) {
        new Ajax.Request('/card/to_edit/'+card_id+'?context='+getSlotContext(element),
           {asynchronous: true, evalScripts: true});
      } else if (span.hasClassName('paragraph')) {
        new Ajax.Updater(span, '/card/edit/'+card_id+'?context='+getSlotContext(element),
           {asynchronous: true, evalScripts: true});
      } else {
        new Ajax.Updater(span, '/transclusion/edit/'+card_id+'?context='+getSlotContext(element),
           {asynchronous: true, evalScripts: true});
     }
     Event.stop(event);
    }
  });
}
 
// FIXME: should be tested to not return content from nested slots.
getSlotElement=function(element,name){
  var span = getSlotSpan(element);
  return $A(document.getElementsByClassName(name, span)).reject(function(x){
    return getSlotSpan(x)!=span;
  })[0];
}

// crawls up nested slots looking for one with a <span class="name"..
getNextElement=function(element, name){
  var span=null;
  if (span = getSlotSpan(element)) {
    if (e = $A(document.getElementsByClassName(name, span))[0]) {
      return e;
    } else {
      return getNextElement(span.parentNode,name);
    }
  } else {
    return null;
  }
}
 
getSlotContext=function(element) {
  var span=null;
  if (span = getSlotSpan(element)) {
    var position = span.attributes['position'].value;
    parentContext = getSlotContext(span.parentNode);
    return parentContext + ':' + position;
  } else {
    return getOuterContext(element);
  }
}

getOuterContext=function(element) {
  if (typeof(element.hasAttribute)!='undefined' && element.hasAttribute('context')) {
    return element.attributes['context'].value;
  } else if (element.parentNode){
    return getOuterContext(element.parentNode);
  } else {
    warn("Failed to get Outer Context");
    return 'page';
  }
}

getSlotSpan=function(element) {
  if (typeof(element.hasAttribute)!='undefined' && element.hasAttribute('position')) {
    return element;
  } else if (element.parentNode) {
    return getSlotSpan( element.parentNode );
  } else {   
    return false;
  }
}








