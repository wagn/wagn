// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


Wagn = new Object();

var warn = function(stuff) {
  if (typeof(console) != 'undefined')
    console.log( stuff );
}

Wagn.Messenger = {  
  element: function() { return $('alerts') },
  alert: function( message ) {
    if (!this.element()) return;
    this.element().innerHTML = '<span style="color:red; font-weight: bold">' + message + '</span>';
    new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  note: function(message) {
    if (!this.element()) return;
    this.element().innerHTML = message;
    new Effect.Highlight( this.element(), {startcolor:"#ffff00", endcolor:"#ffffaa", restorecolor:"#ffffaa", duration:1});
  },
  log: function( message ) {
    if (!this.element()) return;
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
  messenger: function(){ return Wagn.Messenger },
  
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
                                                           
/* ------------ Autosave -----------------------*/

Wagn.auto_save_interval = 20; //seconds
Wagn.draftSavers = $H({});
          
Wagn.setupAutosave=function(card_id, slot_id) {
  var parameters = "";
  save_draft_fn = function() {                                
    form = $(slot_id + "-form") ;
    if (!form) { return }

    // run each item in the save queue to save data to form elements
    Wagn.runQueue(Wagn.onSaveQueue[slot_id]);

    new_parameters = Form.serialize( form );  
    if (new_parameters != parameters) {
      parameters = new_parameters;
    
      // serialize form and submit to CardController#save_draft       
      new Ajax.Request('/card/save_draft/' + card_id, {
        asynchronous:true, evalScripts:true, method: 'post',
        parameters: parameters
      });
    }
  }
  Wagn.draftSavers[slot_id] = new PeriodicalExecuter(save_draft_fn, Wagn.auto_save_interval);
}



/* ------------------ OnLoad --------------------*/

Wagn.runQueue = function(queue) {
  result = true;
  if (typeof(queue)!='undefined') {
    queue.each(function(fn){
      if (!fn.call()) { result=false }
    });
  }
  return result;
};
Wagn.onLoadQueue   = [];
Wagn.onSaveQueue   = {};
Wagn.onCancelQueue = {};

wagnOnload = function() {
  Wagn.Messenger.flash();
  Wagn.runQueue(Wagn.onLoadQueue);
  setupLinksAndDoubleClicks();  
}                                                           
       

handleGlobalShortcuts=function(event){
  if (event.keyCode == 76 && event.ctrlKey) {
    $('navbox_field').focus();
  }
}

setupLinksAndDoubleClicks = function() {
  getNewWindowLinks();
  setupCreateOnClick();
  
  jQuery(".editOnDoubleClick").dblclick(function(event){
    editTransclusion(this);
    event.stopPropagation();
  });

  // make sure these nested elements don't bubble up their double click
  // to a containing double-click handler.
  jQuery(".comment-box, .TYPE-pointer", ".editOnDoubleClick").dblclick(function(event){
    event.stopPropagation();
  });
}


setupCreateOnClick=function(container) {
//  console.log("setting up creates");
  $$( ".createOnClick" ).each(function(el){
    el.onclick=function(event) { 
      if (Prototype.Browser.IE) { event = window.event } // shouldn't prototype take card of this?              
      element = Event.element(event);
      slot_span = getSlotSpan(element);
      card_name = slot_span.getAttributeNode('cardname').value;  
      card_type = slot_span.getAttributeNode('type').value;
      //console.log("create  " +card_name);
      ie = (Prototype.Browser.IE ? '&ie=true' : '');
      new Ajax.Request('/card/new?add_slot=true&context='+getSlotContext(element), {
        asynchronous: true, evalScripts: true,     
        parameters: "card[type]=" + encodeURIComponent(card_type) + "&card[name]="+encodeURIComponent(card_name)+"&home_view="+slot_span.getAttributeNode('home_view').value+ie,
        onSuccess: function(request){ slot_span.replace(request.responseText) },
        onFailure: function(request){ slot_span.replace(request.responseText) }
      });
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
  while(a.size() > 0) {
    pos = a.shift();      
    // FIXME: this probably a better way to get 
    candidate_elements = $A(Element.select(element, '.card-slot'  ).concat(
                            Element.select(element, '.transcluded').concat(
                            Element.select(element, '.nude-slot'  ).concat( 
                            Element.select(element, '.createOnClick')))));
    element = candidate_elements.find(function(x){
      ss = getSlotSpan(x.parentNode);
      return (!ss || ss==element) && ((n = x.getAttributeNode('position')) && n.value==pos);
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
    if (n=span.getAttributeNode('home_view')) {  if (n.value != '') { options.push("home_view="+n.value) }};
    if (n=span.getAttributeNode('item')) {  if (n.value != '') { options.push("item="+n.value) }};
    return options.join("&");
  }
  return '';
}
  
urlForAddField=function(card_id, eid) {
  //return 'foo'
  //index = getSlotElements(getSlotFromContext(eid), 'pointer-li').length;
  $(eid+'-add').remove();
  index = Element.select($(eid+'-ul'), ".pointer-text").length;
  return ('/card/add_field/' + card_id + '?index=' + index + '&eid=' + eid);
}


navboxOnSubmit=function(form){
  if($F('navbox_field') != '') {
    document.location.href= form.action + '/'+ encodeURIComponent($F('navbox_field').gsub(' ','_')); 
  }
  return false;
}

navboxAfterUpdate=function(text,li){
  $('navbox_form').action = (li.hasClassName('search') ? '/search' : '/wagn');
}

Event.KEY_SHIFT = 16;
                                            
// fixme better name?
Ajax.Autocompleter.prototype.updateSelection = function() {
  this.element.value = '';
  this.updateElement(this.getCurrentEntry());
  this.render();
}

Ajax.Autocompleter.prototype.onClick = function(event){
  var element = Event.findElement(event, 'LI');
  this.index = element.autocompleteIndex;
  this.selectEntry();
  this.hide();
  if (this.element.id == 'navbox_field') {
    navboxOnSubmit($('navbox_form'));
  }
}

// override Autocompleter key handling
Ajax.Autocompleter.prototype.onKeyPress = function(event){
  if(this.active) 
    switch(event.keyCode) {
     case Event.KEY_TAB:
       if (event.shiftKey){
         this.markPrevious();
       } else {
         this.markNext();  
       }   
       this.updateSelection();
       Event.stop(event);
       return;
     case Event.KEY_UP:
       this.markPrevious();
       this.updateSelection();
       Event.stop(event);
       return;
     case Event.KEY_DOWN:
       this.markNext();
       this.updateSelection();
       Event.stop(event);
       return;
     case Event.KEY_RETURN: 
       if (!this.changed) {
         this.element.value = '';   
         this.selectEntry();
         this.hide();
       }
       return;                          
     case Event.KEY_ESC:
       this.hide();
       this.active = false;
       Event.stop(event);
       return;
     case Event.KEY_LEFT:
     case Event.KEY_RIGHT:
     case Event.KEY_SHIFT:
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
                                           
//  changed scrollIntoView(true) to scrollIntoView(false) -- it was 
//  causing lots of jerking around.
Ajax.Autocompleter.prototype.markPrevious = function() {
  if(this.index > 0) this.index--
    else this.index = this.entryCount-1;
  this.getEntry(this.index).scrollIntoView(false);
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

       
Event.observe(window, 'load', wagnOnload);
Event.observe(window, 'keydown', handleGlobalShortcuts );      


/* helpers for image setup */
var deactivateSubmit = function(form_element_or_id) {  
  button = findSubmit(form_element_or_id);
  button.setStyle({ color: "#ccc", border: "1px solid #ccc" }); 
  button.onclick = (function(){});
}

var activateSubmit = function(form_element_or_id) {
  button = findSubmit(form_element_or_id);
  button.setStyle({ color: "#444", border: "1px solid #666" });
  /* FIXME */
  /* "this.form.onsubmit()" is duplicated in this function on purpose.  */
  /* when it was there once I had to click the button twice for it to work. */
  /* totally lazy of me not to dig into it.  also, wtf? */
  button.onclick = (function(){this.form.onsubmit(); this.form.onsubmit();});
}
    
var findSubmit = function(form_element_or_id) {
  form = $(form_element_or_id).up('form');
  return form.down('.save-card-button') || form.down('#create-button');
}  
  
var attachmentOnChangeUpdateParent = function(attachment_uuid, filename) {
  preview_slot = document.getElementById(attachment_uuid + '-preview');
  // TODO: report prototype bug: preview_slot.update should work but fails in IE
  Element.update(preview_slot, '<img src="/images/wait_lg.gif">  Uploading...');   
  
  // Set the card name from filename if we can find the name field and it's blank.
	if (name_field = preview_slot.up('form').down('.card-name-field')) {
  	if (!name_field.value || name_field.value.blank()) { 
      filename = unescape(filename);
      // chop off directories etc.
    	if (match_bits = filename.match(/([^\/\\]+)\.\w+$/)) {
    	  filename = match_bits[1];
      }
      name_field.value = filename; 
    }
  }                               
  
  // for now, don't let users submit while the image is in process of uploading.
	deactivateSubmit(attachment_uuid);  
}


setPointerContent=function(eid, items) {
  content_field = $(eid + '-hidden-content');
  list = (items instanceof Array) ? items : [items]; 
  content_field.value = list.map(
    function(x){
      if ((x==null) || (x.strip()=='')) {
        return '';
      } else {
        return '[[' + x + ']]';
      }
    }
  ).join("\n");
  //alert('value = ' + content_field.value);
}



// Event: Nimbb Player has been initialized and is ready.
function Nimbb_initCompleted(idPlayer)
{
  warn("Nimbb initCompleted");
}

// Event: the video was saved.
function Nimbb_videoSaved(idPlayer)
{
  warn("Nimbb videoSaved");
  recorder = jQuery("#"+idPlayer);
  recorder.prevAll("input").val( recorder[0].getGuid() );
  if ( !recorder.parents(".in-multi")[0] ) {
    recorder.parents("form")[0].onsubmit();
  }
}



