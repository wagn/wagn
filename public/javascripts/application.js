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
    new Effect.Highlight( this.element(), {startcolor:"#eeeebb", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  flash: function() {
    flash = $('notice').innerHTML + $('error').innerHTML;
    if (flash != '') {
      this.alert(flash);
    }
  }
};

Ajax.Responders.register({
  createMessage: function() { return 'connecting to server...'},
  onCreate: function(){
    Wagn.Messenger.log( this.createMessage());
  }, 
  onComplete: function(){
    if (Wagn.Messenger.element().innerHTML == this.createMessage()) {
      Wagn.Messenger.log('done');
    }
  }
});


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
    var elementDimensions = Element.getDimensions(element);
    new Effect.BlindDown( element, {
      duration: 0.5,
      scaleFrom: 100,
      scaleMode: {originalHeight: elementDimensions.height*2, originalWidth: elementDimensions.width}
    });
  },
  
  line_to_paragraph: function(element) {
    Element.removeClassName(element,'line');
    Element.addClassName(element,'paragraph');

   /*
   //  alert('line to paragraph');
   // if (!Prototype.Browser.WebKit) {
      //var oldElementDimensions = Element.getDimensions(element);
      copy = copy_with_classes( element );
      copy.removeClassName('line');
      copy.addClassName('paragraph');
      
      var newElementDimensions = Element.getDimensions(copy);
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
   //} else {
   //}
   */
   
  },
  paragraph_to_line: function(element) {
    Element.removeClassName(element, 'paragraph');
    Element.addClassName(element, 'line');
    // Fixme: Safari chokes on getStyle() in prototype: this is bullshit: prototype should work in safari.
    /*
    //if (!Prototype.Browser.WebKit) {
      var oldElementDimensions = Element.getDimensions(element);
      copy = copy_with_classes( element );
      copy.removeClassName('paragraph');
      copy.addClassName('line');
      var newElementDimensions = Element.getDimensions(copy);
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
     //} else {
     //}
     */     
     //warn(element)
     //warn("paragraph --> line");
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
  setupLinksAndDoubleClicks();
}

setupLinksAndDoubleClicks = function() {
  getNewWindowLinks();
  setupDoubleClickToEdit();  
  setupCreateOnClick();
}                  


setupCreateOnClick=function(container) {
  Element.getElementsByClassName( document, "createOnClick" ).each(function(el){
    el.onclick=function(event) { 
      if (Prototype.Browser.IE) { event = window.event } // shouldn't prototype take card of this?              
      element = Event.element(event);
      slot_span = getSlotSpan(element);
      card_name = slot_span.getAttributeNode('cardname').value;  
      //console.log("create  " +card_name);
      new Ajax.Request('/transclusion/create?context='+getSlotContext(element), {
        asynchronous: true, evalScripts: true,
        parameters: "card[name]="+encodeURIComponent(card_name)+"&requested_view="+slot_span.getAttributeNode('view').value
      });
      Event.stop(event);
    }
  });
}                  

setupDoubleClickToEdit=function(container) {                               
  Element.getElementsByClassName( document, "editOnDoubleClick" ).each(function(el){
    el.ondblclick=function(event) {   
      if (Prototype.Browser.IE) { event = window.event } // shouldn't prototype take card of this?              
      element = Event.element(event);
      span = getSlotSpan(element);   
      card_id = span.getAttributeNode('cardid').value;
      if (Element.hasClassName(span,'line')) {
        new Ajax.Request('/card/to_edit/'+card_id+'?context='+getSlotContext(element),
           {asynchronous: true, evalScripts: true});
      } else if (Element.hasClassName(span,'paragraph')) {
        new Ajax.Updater({success:span, failure:span}, '/card/edit/'+card_id+'?context='+getSlotContext(element),
           {asynchronous: true, evalScripts: true});
      } else {
        new Ajax.Updater({success:span, failure:getNextElement(span,'notice')}, '/transclusion/edit/'+card_id+'?context='+getSlotContext(element),
           { asynchronous: true, evalScripts: true});
     }
     Event.stop(event);
    }
  });
}        
                                    

getOuterSlot=function(element){
  var span = getSlotSpan(element);
  if (span) {
    outer = getOuterSlot(span.parentNode);
    if (outer){
      return outer;
    } else {
      return span;
    }
  } else {
    return null;
  }
}
 

getSlotFromContext=function(context){
  a = context.split('_');
  outer_context=a.shift();
  element = $(outer_context);
   element = $(outer_context);
  while(a.size() > 0) {
    pos = a.shift();      
    // FIXME: this is crazy.  must do better.
    element =  $A(document.getElementsByClassName('card-slot', element).concat(
                    document.getElementsByClassName('transcluded', element).concat(
                      document.getElementsByClassName('nude-slot', element).concat(
                        document.getElementsByClassName('createOnClick',element)
                 )))).find(function(x){
      ss = getSlotSpan(x.parentNode);
      return (!ss || ss==element) && x.getAttributeNode('position').value==pos;
    });
  }
  return element;
}
 
// FIXME: should be tested to not return content from nested slots.
getSlotElements=function(element,name){
  var span = getSlotSpan(element);
  return $A(document.getElementsByClassName(name, span)).reject(function(x){
    return getSlotSpan(x)!=span;
  });
}

getSlotElement=function(element,name){
  return getSlotElements(element,name)[0];
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
  //alert('getting slot context');
  var span=null;
  if (span = getSlotSpan(element)) {
    var position = span.getAttributeNode('position').value;
    parentContext = getSlotContext(span.parentNode);
    return parentContext + '_' + position;
  } else {
    return getOuterContext(element);
  }
}

getOuterContext=function(element) {
   //warn("Element: " + element);
  if (typeof(element.getAttributeNode)!='undefined' && element.getAttributeNode("context")!=null) {
    return element.getAttributeNode('context').value;
  } else if (element.parentNode){
    return getOuterContext(element.parentNode);
  } else {
    warn("Failed to get Outer Context");
    return 'page';
  }
}

getSlotSpan=function(element) {
  //warn("Element: " + element);
  if (typeof(element.getAttributeNode)!='undefined' && element.getAttributeNode("position")!=null) {
    return element;
  } else if (element.parentNode) {
    return getSlotSpan( element.parentNode );
  } else {   
    return false;
  }
}


urlForAddField=function(card_id, eid) {
  //return 'foo'
  //index = getSlotElements(getSlotFromContext(eid), 'pointer-li').length;
  index = document.getElementsByClassName("pointer-text", $(eid+'-ul')).length;
  return ('/card/add_field/' + card_id + '?index=' + index + '&eid=' + eid);
}

