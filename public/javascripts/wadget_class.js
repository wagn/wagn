Wadget = Class.create();  
Object.extend(Wadget.prototype, {
  initialize: function(element) { 
    this._element = $(element);
    this._element.appendChild( document.createTextNode(""));   
    this.absolute_url_pattern = '^(http://[^\/]+)/.*$'; 
  },    
  show: function( url ) {
    this.url = url;  
    this.base_href = this.url.match(this.absolute_url_pattern)[1]; 
    warn('seeting base_href=' + this.base_href);
    var self = this;
    if (url.match('html')) {
      url = url.gsub('.html','.json' );
    } else {
      url += '.json';
    }
    this._dojo_args = {
			url: url,
			transport: "ScriptSrcTransport",
			jsonParamName: "callback", 
			load: function( type, data, evt, kwArgs) { self.onLoadCard( data ) },
			mimetype: "text/json",
      timeout: function() { self.onFailure() },
      timeoutSeconds: 3
		};
		dojo.io.bind( this._dojo_args ); 
		return this;
  },
  onFailure: function() {
    err_msg = "Sorry, " + this.url + " didn't return valid wadget data";
    Element.replace( this._element.firstChild, err_msg);
  },
  onLoadCard: function( data ) {
    //console.log("data:" + data);             
    Element.replace( this._element.firstChild, data );
    //Wagn.Card.setupAll('widget');  
    warn('base_href: ' + this.base_href); 
    var self = this;                            
    // Convert images and links to absolute urls    
    $A(this._element.getElementsByTagName('a')).each(function(e) {
      e.href = self.absolutize_url( e.getAttribute('href') );
    });
    $A(this._element.getElementsByTagName('img')).each(function(e) {
      e.src = self.absolutize_url( e.getAttribute('src') );
    });
  },
  is_relative: function( url ) {
    return !url.match('^(http|ftp|https)://[^\/]+');
  },
  absolutize_url: function(url) {
    if (this.is_relative(url)) {
      return this.base_href + (url.match('^\/') ? '' : '/') + url;
    } else {
      return url;
    }
  }
});
