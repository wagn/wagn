/* These are the necessary overrides for GM */

Wikiwyg.changeLinksMatching = function(attribute, pattern, func) {
    var links = document.getElementsByTagName('a');
    for (var i = 0; i < links.length; i++) {
        var link = links[i];
        var my_attribute = link.getAttribute(attribute);
        if (my_attribute && my_attribute.match(pattern)) {
            link.setAttribute('href', '#');
            link.addEventListener('click', function(event) { func(); }, true);
        }
    }
}

Wikiwyg.Mode.prototype.enable_keybindings = function() { // See IE
    if (!this.key_press_function) {
        this.key_press_function = this.get_key_press_function();
        this.get_keybinding_area().addEventListener(
            'keypress', this.key_press_function, true
        );
    }
}

Wikiwyg.Wikitext.prototype.clear_inner_text = function() {
    if ( Wikiwyg.is_safari ) return;
    var self = this;
    this.area.addEventListener('click', function(event) {
        var inner_text = self.area.value;
        var clear = self.config.clearRegex;
        if (clear && inner_text.match(clear))
            self.area.value = '';
    },true);
}

Wikiwyg.Toolbar.prototype.make_button = function(type, label) {
    var base = this.config.imagesLocation;
    var ext = this.config.imagesExtension;
    return Wikiwyg.createElementWithAttrs(
        'img', {
            'class': 'wikiwyg_button',
            alt: label,
            title: label,
            src: base + type + ext
        }
    );
}

Wikiwyg.Toolbar.prototype.add_button = function(type, label) {
    var img = this.make_button(type, label);
    var self = this;
    img.addEventListener('click',
                         function(event) {
                             self.wikiwyg.current_mode.process_command(type);
                         },true);
    this.div.appendChild(img);
}

Wikiwyg.Toolbar.prototype.addControlItem = function(text, method) {
    var span = Wikiwyg.createElementWithAttrs(
        'span', { 'class': 'wikiwyg_control_link' }
    );

    var link = Wikiwyg.createElementWithAttrs(
        'a', { href: '#' }
    );
    link.appendChild(document.createTextNode(text));
    span.appendChild(link);
    
    var self = this;
    link.addEventListener("click",
                          function(event) {
                              eval('self.wikiwyg.' + method + '()');
                              event.stopPropagation();
                              event.preventDefault();
                              return false;
                          },true );

    this.div.appendChild(span);
}

Wikiwyg.Toolbar.prototype.resetModeSelector = function() {
    if (this.firstModeRadio) {
        this.firstModeRadio.addEventListener('click',
                                             function(event){ },true);
        this.firstModeRadio.click();
        this.firstModeRadio.addEventListener('click',
                                             this.firstModeRadioOnClickHandler,
                                             true);
    }
}

Wikiwyg.Toolbar.prototype.addModeSelector = function() {
    var span = document.createElement('span');

    var radio_name = Wikiwyg.createUniqueId();
    for (var i = 0; i < this.wikiwyg.config.modeClasses.length; i++) {
        var class_name = this.wikiwyg.config.modeClasses[i];
        var mode_object = this.wikiwyg.mode_objects[class_name];
 
        var radio_id = Wikiwyg.createUniqueId();
 
        var checked = i == 0 ? 'checked' : '';
        var radio = Wikiwyg.createElementWithAttrs(
            'input', {
                type: 'radio',
                name: radio_name,
                id: radio_id,
                value: mode_object.classname,
                'checked': checked
            }
        );
        if (!this.firstModeRadio)
            this.firstModeRadio = radio;
 
        var self = this;
        this.firstModeRadioOnClickHandler = function(event) { 
	    self.wikiwyg.switchMode(this.value);
	};
        radio.addEventListener('click', this.firstModeRadioOnClickHandler ,true);
 
        var label = Wikiwyg.createElementWithAttrs(
            'label', { 'for': radio_id }
        );
        label.appendChild(document.createTextNode(mode_object.modeDescription));

        span.appendChild(radio);
        span.appendChild(label);
    }
    this.div.appendChild(span);
}
