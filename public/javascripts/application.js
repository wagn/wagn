// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


Wagn = new Object();

var warn = function(stuff) {
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
    if ($('notice') && $('error')) {
      flash = $('notice').innerHTML + $('error').innerHTML;
      if (flash != '') {
        this.alert(flash);
      }
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
    $$( '.'+targetClass ).each(function(elem) {
      Element.addClassName( elem, 'card-highlight');
      Element.removeClassName( elem, 'card');
    })
  },

  title_mouseout: function( targetClass ) {
    $$( '.'+targetClass ).each(function(elem) {
      Element.removeClassName( elem, 'card-highlight');
      Element.addClassName( elem, 'card');
    })
  },
  line_to_paragraph: function(element) {
    Element.removeClassName(element,'line');
    Element.addClassName(element,'paragraph');
  },
  paragraph_to_line: function(element) {
    Element.removeClassName(element, 'paragraph');
    Element.addClassName(element, 'line');
  }
});



Wagn.highlight = function( group, id )  {  
  $$( '.'+group ).each(function(elem) { 
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
  $$( ".createOnClick" ).each(function(el){
    el.onclick=function(event) { 
      if (Prototype.Browser.IE) { event = window.event } // shouldn't prototype take card of this?              
      element = Event.element(event);
      slot_span = getSlotSpan(element);
      card_name = slot_span.getAttributeNode('cardname').value;  
      card_type = slot_span.getAttributeNode('type').value;
      //console.log("create  " +card_name);
      ie = (Prototype.Browser.IE ? '&ie=true' : '');
      new Ajax.Updater(slot_span, '/card/new?add_slot=true&context='+getSlotContext(element), {
        asynchronous: true, evalScripts: true,     
        parameters: "card[type]=" + encodeURIComponent(card_type) + "&card[name]="+encodeURIComponent(card_name)+"&requested_view="+slot_span.getAttributeNode('view').value+ie
      });
      Event.stop(event);
    }
  });
}                  

setupDoubleClickToEdit=function(container) {                               
  $$( ".editOnDoubleClick" ).each(function(el){
    el.ondblclick=function(event) {   
      if (Prototype.Browser.IE) { event = window.event } // shouldn't prototype take card of this?              
      element = Event.element(event);   
      editTransclusion(element);
      Event.stop(event);
    }
  });
}        
   
editTransclusion=function(element){
   span = getSlotSpan(element);   
   card_id = span.getAttributeNode('cardid').value;       
   url =  '/card/edit/'+card_id+'?context='+getSlotContext(element) + '&' + getSlotOptions(element);
   new Ajax.Updater(span, url, {
     asynchronous: true, evalScripts: true, 
     onSuccess: function(){  Wagn.line_to_paragraph(span) }
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
    element =  $A(Element.select(element, '.card-slot').concat(
                    Element.select(element, '.transcluded').concat(
                      Element.select(element, '.nude-slot').concat( 
                        Element.select(element, '.createOnClick')
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
  return Element.select(span, '.'+name).reject(function(x){
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
    if (e = Element.select(span, '.'+name)[0]) {
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
//    return parentContext + '_' + position + '&view=' + span.getAttributeNode('view').value;
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

getSlotOptions=function(element){
  var span=null;
  if (span=getSlotSpan(element)) {   
    var n=null; var item=''; var view='';
    options = $A([]);
    if (n=span.getAttributeNode('view')) {  if (n.value != '') { options.push("view="+n.value) }};
    if (n=span.getAttributeNode('item')) {  if (n.value != '') { options.push("item="+n.value) }};
    return options.join("&");
  }
  return '';
}
  
urlForAddField=function(card_id, eid) {
  //return 'foo'
  //index = getSlotElements(getSlotFromContext(eid), 'pointer-li').length;
  index = Element.select($(eid+'-ul'), ".pointer-text").length;
  return ('/card/add_field/' + card_id + '?index=' + index + '&eid=' + eid);
}


navboxOnSubmit=function(form){   
  document.location.href= form.action + '/'+ encodeURIComponent($F('navbox_field').gsub(' ','_')); 
  return false;
}

navboxAfterUpdate=function(text,li){
  if (!li.hasClassName('search')) {
    $('navbox_form').action = '/wagn';
  }
}

Event.KEY_SHIFT = 16;


// override Autocompleter key handling
Ajax.Autocompleter.prototype.onKeyPress = function(event){
  //alert( 'key=' + event.keyCode );
  if(this.active) 
    switch(event.keyCode) {
     case Event.KEY_TAB:
       this.markNext();
       this.element.value = '';
       this.selectEntry();   
       this.active = true;
       this.render();
       Event.stop(event);
       return;
     case Event.KEY_RETURN:
       this.selectEntry();
       return;                          
     case Event.KEY_ESC:
       this.hide();
       this.active = false;
       Event.stop(event);
       return;
     case Event.KEY_LEFT:
     case Event.KEY_RIGHT:
       return;
     case Event.KEY_UP:
       this.markPrevious();
       this.render();
       Event.stop(event);
       return;
     case Event.KEY_DOWN:
       this.markNext();
       this.render();
       Event.stop(event);
       return;
     case Event.KEY_SHIFT:
       //awesome if we could make shift-tab do KEY_UP
       return;
    }
   else 
     if(event.keyCode==Event.KEY_TAB || event.keyCode==Event.KEY_RETURN || 
       (Prototype.Browser.WebKit > 0 && event.keyCode == 0)) return;

  this.changed = true;
  this.hasFocus = true;

  if(this.observer) clearTimeout(this.observer);
    this.observer = 
      setTimeout(this.onObserverEvent.bind(this), this.options.frequency*1000);
}

var loadScript = function(name) {
  var d=document;
  var s;
  try{
    s=d.standardCreateElement('script');
  } catch(e){}

  if(typeof(s)!='object') {
    s=d.createElement('script');
	}
  try{
    s.type='text/javascript';
    s.src=name;
    s.id='c_'+name+'_js';
    h=d.getElementsByTagName('head')[0];
    h.appendChild(s);
  } catch(e){
	   alert('js load ' + name + ' failed');
  } 
}   

