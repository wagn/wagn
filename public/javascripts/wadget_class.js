Wadget = Class.create();
Object.extend(Wadget.prototype, {
  initialize: function(element) { 
    this._element = $(element);    
  },
  show: function( url ) {
    this.url = url;
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
  },
  onFailure: function() {
    err_msg = "Sorry, " + this.url + " didn't return valid wadget data";
    Element.replace( this._element, err_msg);
  },
  onLoadCard: function( data ) {
    //console.log("data:" + data);             
    Element.replace( this._element, data );
    Wagn.Card.setupAll('widget');
  }
});
