Wagn.Lister = Class.create();
Object.extend(Wagn.Lister.prototype, {
    initialize: function(div_id, args) {
    per_card = true;
    this._arguments = $H(args);
    this.user_id  = this.make_accessor('user_id');
    this.page     = this.make_accessor('page');
    this.cardtype = this.make_accessor('cardtype',{ reset_paging: true });
    this.keyword  = this.make_accessor('keyword', { reset_paging: true }); 
    this.sort_by  = this.make_accessor('sort_by', { reset_paging: true });
    this.sortdir  = this.make_accessor('sortdir', { reset_paging: true });
    this.hide_duplicates = this.make_cookie_accessor('hide_duplicates', '');    
    this.pagesize = this.make_cookie_accessor('pagesize', '25'); 
    this.div_id = div_id;
        
    // set defaults
    Object.extend( this._arguments , {
      query:    this.query(),
      pagesize: this.pagesize(),
      cardtype: this.cardtype(),
      keyword:  this.keyword(),
      sort_by:  this.sort_by(),
      sortdir:  this.sortdir()
    });

    // initialize highlighting and form
    Wagn.highlight('sortdir', this.sortdir());
    Wagn.highlight('sort_by', this.sort_by());    
    Wagn.highlight('pagesize', this.pagesize());
    Wagn.highlight('hide_duplicates', this.hide_duplicates());
    // Wagn.highlight('connection-menu', this.query());
                                            
    // load cards
  },   
  open_all: function() {
    $A(document.getElementsByClassName('open-link', $(this.div_id))).each(function(a) {
      a.onclick();
    })
  },
  close_all: function() {
    $A(document.getElementsByClassName('line-link', $(this.div_id))).each(function(a) {
      a.onclick();
    })
  },  
  cards_per_page: function() {
    if (arguments[0]) {
      Cookie.set('cards_per_page');
    }
    return Cookie.get('cards_per_page');
  },
  _cards: function() {
    return this._card_slots().collect(function(slot){ return slot.card() });
  },
  _card_slots: function() {
    return document.getElementsByClassName('card-slot', $(this.div_id));
  },
  card_id: function() {
    return (typeof(Wagn.main_card)=='undefined' ? '' : Wagn.main_card.id);
  },
  display_type: function() {
    if (arguments[0]!=null) {
      this._display_type = arguments[0];
    }
    return (this._display_type ? this._display_type : 'connection_list');
  },
  query: function() { 
    field = 'query';
    if (arguments[0]!=null) {
      this.page('1');  // reset paging when changing queries
      this._arguments[field] = arguments[0];
      return this;
    } else {
      if (this._arguments.keys().include(field)) {
        return this._arguments[field];
      } else {
        return null;
      }                 
    }
  },
  make_cookie_accessor: function( field, default_value ) {
    var self = this;  
    var per_card = arguments[1] ? this.card_id() : '';
    var default_value = default_value;
    return function() {
      if (arguments[0]!=null) {   
        Cookie.set(per_card + field, arguments[0]);
        self._arguments[field] = arguments[0];
        return self;
      } else {                        
        if (self._arguments.keys().include(field)) {
          return self._arguments[field];
        } else if (val = Cookie.get(per_card + field))  {
          return val
        } else {
          return default_value;
        }
      }
    }               
  },                      
  // FIXME: make_accessor should take an option like "persistent"
  // and then take care of cooke stuff instead of the separate 
  // accessor generator above
  make_accessor: function( field ) { 
    options = Object.extend( $H({
      reset_paging: false
    }), arguments[1]);

    var self = this; 
    var reset_paging = options['reset_paging'];
    return function() {
      if (arguments[0]!=null) {
        self._arguments[field] = arguments[0];
        if (reset_paging) { 
          self.page('1');
        }
        return self;
      } else {
        return self._arguments[field];
      }
    }
  },
  update: function() {
    //alert( Object.inspect( (this.card_id() == '')));
    $('paging-links-copy').innerHTML = '<img src="/images/wait.gif">';
    $(this.div_id).innerHTML = '';
    card_part = (this.card_id()=='') ? '' : "/" + this.card_id();
    new Ajax.Updater(this.div_id, 
      '/types/search/' + this.display_type() + card_part + ".html",
      $H(this._ajax_parameters( this._arguments )).merge( arguments[0] )
    );
    this.set_button();
    
//    if (this.div_id == 'related-list') this.set_title();
  },
//  set_title: function() {
//      $('query-title').innerHTML = $('connection-menu-' + this.query()).firstChild.title;     
//  },
  new_connection: function() {
    new Ajax.Updater('connections-workspace', '/connection/new/' + this.card_id() + "?query=plussed_cards");
  },
  set_button: function() {  // FIXME -- this could be done more elegantly
	  if (!($('related-button'))) return false;
	  button = '&nbsp;'; // not '' so paging links don't float under cards...
	  query = this.query();
	  if (($('button-permission')) && ($('button-permission').innerHTML == 'true')) {  
			if ((query == 'plus_cards') || (query == 'plussed_cards')) {
				button = '<input type="button" id="new-connection-button" value="join it to another card" onClick="Wagn.lister().new_connection ()">';	 
			} else if	(query == 'cardtype_cards') {
			  cardtype = Wagn.main_card.codename;
				button = '<input type="button" value="create new one" onClick="document.location.href=\'/card/new?card[type]=' + cardtype + '\'">';
			}
		}
	  $('related-button').innerHTML = button; 
  },
  after_update: function() {
    //Wagn.Card.setupAll();
    $('paging-links-copy').innerHTML = $('paging-links').innerHTML;
    setupDoubleClickToEdit();
  },                              
  _ajax_parameters: function() {
    param_hash = arguments[0] ? arguments[0] : {};
    param_list = $A([]);
    $H(param_hash).each( function(pair) { 
      if (pair.value && pair.value != '') {
        param_list.push( pair.key + '=' + encodeURIComponent( pair.value ) );  
      }
    });
    return { 
      asynchronous: false, 
      evalScripts: true,  
      method: 'get',
      onComplete: function(request){ Wagn.lister().after_update() },
      parameters: param_list.join('&') 
    };
  } 
});

