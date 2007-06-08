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
  // Change this to the text you want to use to alert the user that a new window will be opened
  ///* var strNewWindowAlert = " (opens in a new window)";
  // // Find all links
  // var objWarningText;
  // var strWarningText;*/
    var link;
    var links = document.getElementsByTagName('a');
    for (var i = 0; i < links.length; i++) {
      link = links[i];
      // Find all links with a class name of "non-html"
      //if (/\bnon\-html\b/.exec(link.className)) {
      if (/\bexternal\b/.exec(link.className)) {
        // Create an em element containing the new window warning text and insert it after the link text
       // /*objWarningText = document.createElement("em");
       // strWarningText = document.createTextNode(strNewWindowAlert);
       // objWarningText.appendChild(strWarningText);
       // link.appendChild(objWarningText);*/
        link.onclick = openInNewWindow;
      }
    }
    objWarningText = null;
  }
}

