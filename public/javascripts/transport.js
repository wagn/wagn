scriptTransport = Class.create();
//
//Written by Thierry Schellenbach
//http://www.mellowmorning.com/2007/10/25/introducing-a-cross-site-ajax-plugin-for-prototype/
//Version 0.8.0 for Prototype 1.5.0
//Developed for www.commenthub.com
//
//modeled after XmlHttpRequest http://en.wikipedia.org/wiki/XMLHttpRequest
//functions open, send (setRequestHeader) - variable readyState, status
//
//    * 0 = uninitialized - open() has not yet been called.
//    * 1 = open - send() has not yet been called.
//    * 2 = sent - send() has been called, headers and status are available.
//    * 3 = receiving - Downloading, responseText holds partial data.
//    * 4 = loaded - Finished.
//
//    for which prototype does this:
//    ['Uninitialized', 'Loading', 'Loaded', 'Interactive', 'Complete']
//    unfortunately the onreadystatechange only works for the last 3, because 
//    prototype 1.5.0 assigns it too late, for our usage and prevents status 1
//    Prototype uses a timer, which in tests lead onSuccess to occur before onLoading
//    We use respondToReadyState to make a direct instruction and bypass the filter
//

//TODO:
//Removal of <script> nodes?

//
//------------------------------ initialize, open and send ------------------------------------------------------
//

scriptTransport.prototype.initialize = function() {
    this.readyState = 0;
}

scriptTransport.prototype.open = function(method, url, asynchronous) {
    if (method != 'GET')
    alert('Method should be set to GET when using cross site ajax');
    this.readyState = 1;
    /* little hack to get around the late assignment of onreadystatechange */
    this.respondToReadyState(1);
    this.onreadystatechange();
    this.url = url;
    this.userAgent = navigator.userAgent.toLowerCase();
    this.setBrowser();
}

scriptTransport.prototype.send = function(body) {
    this.readyState = 2;
    this.onreadystatechange();
    this.getScriptXS(this.url);
}

//
//------------------------------ actually do the request: setBrowser, prepareGetScriptXS, callback, getScriptXS ----------
//

scriptTransport.prototype.setBrowser = function(body) {
    scriptTransport.prototype.browser = {
        version: (this.userAgent.match(/.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/) || [])[1],
        safari: /webkit/.test(this.userAgent),
        opera: /opera/.test(this.userAgent),
        msie: /msie/.test(this.userAgent) && !/opera/.test(this.userAgent),
        mozilla: /mozilla/.test(this.userAgent) && !/(compatible|webkit)/.test(this.userAgent),
        konqueror: this.userAgent.match(/konqueror/i)
        };
}

scriptTransport.prototype.callback = function() {
    try{
    this.status = _xsajax$transport_status;
    } catch(e) {
    return;
    //to prevent people from writing code, which is not cross browser compatible
    }
    this.readyState = 4;
    this.onreadystatechange();
    _xsajax$transport_status = null;
}

scriptTransport.prototype.getScriptXS = function() {

    /* determine arguments */
    var arg = {
    'url':      null
    }
    arg.url = arguments[0];

    /* generate <script> node */
    this.node = document.createElement('SCRIPT');
    this.node.type = 'text/javascript';
    this.node.src = arg.url;

    /* FF and Opera properly support onload. MSIE has its own implementation. Safari and Konqueror need some polling */

    if (this.browser.msie) {
        
        function mybind(obj) {
            temp = function() {
                if (this.readyState == "complete" || this.readyState == "loaded") {
                    return obj.callback.call(obj);
                }
            };
            return temp;
        }
        /* MSIE doesn't support the "onload" event on
           <script> nodes, but it at least supports an
           "onreadystatechange" event instead. But notice:
           according to the MSDN documentation we would have
           to look for the state "complete", but in practice
           for <script> the state transitions from "loading"
           to "loaded". So, we check for both here... */
        this.node.onreadystatechange = mybind(this);

    } else if (this.browser.safari || this.browser.konqueror) {
        this.timepassed = 0;
        /* Safari/WebKit and Konqueror/KHTML do not emit
           _any_ events at all, so we need to use some primitive polling */
        this.checkTimer = setInterval(function()
            {
			this.timepassed = this.timepassed+100;
            if(typeof(eval(_xsajax$transport_status)) != 'undefined' && eval(_xsajax$transport_status) != null)
            {
					this.callback();
					clearInterval(this.checkTimer);
            }
			if(this.timepassed > 20000)
				clearInterval(this.checkTimer);
        }.bind(this),100);
    } else {
        
        /* Firefox, Opera and other reasonable browsers can
           use the regular "onload" event... */
        this.node.onload = this.callback.bind(this);
    }

    /* inject <script> node into <head> of document */
    this.readyState = 3;
    this.onreadystatechange();
    var head = document.getElementsByTagName('HEAD')[0];
    head.appendChild(this.node);

}

//
//------------------------------ Don't complain when these are called: setRequestHeader and onreadystatechange ----------
//

scriptTransport.prototype.setRequestHeader = function() {
}
scriptTransport.prototype.onreadystatechange = function() {
}
scriptTransport.prototype.respondToReadyState = function() {
}

//
//------------------------------- Extend prototype a bit -----------------------
//    

/* hack to get it working in prototype 1.6.. should revisit this */
Ajax.Request.prototype = Object.extend(Ajax.Request.prototype, {
     initialize: function(url, options) {
         this.options = {
           method:       'post',
           asynchronous: true,
           contentType:  'application/x-www-form-urlencoded',
           encoding:     'UTF-8',
           parameters:   '',
           evalJSON:     true,
           evalJS:       true
         };
         Object.extend(this.options, options || { });
 
         this.options.method = this.options.method.toLowerCase();
 
         if (Object.isString(this.options.parameters))
           this.options.parameters = this.options.parameters.toQueryParams();
         else if (Object.isHash(this.options.parameters))
           this.options.parameters = this.options.parameters.toObject();
         
         this.transport = (!this.options.crossSite) ? Ajax.getTransport() : new scriptTransport;
         this.options.asynchronous = (!this.options.crossSite) ? this.options.asynchronous : false;
         //turns of the timed onLoad executer
         this.transport.respondToReadyState = this.respondToReadyState.bind(this);
         this.request(url);
         }
 });           
 /*
Ajax.Request.prototype = Object.extend(Ajax.Request.prototype,{
    initialize: function($super, url, options) {
        $super(options);

        //this.setOptions(options);
        this.transport = (!this.options.crossSite) ? Ajax.getTransport() : new scriptTransport;
        this.options.asynchronous = (!this.options.crossSite) ? this.options.asynchronous : false;
        //turns of the timed onLoad executer
        this.transport.respondToReadyState = this.respondToReadyState.bind(this);
        this.request(url);
        }    
});
*/