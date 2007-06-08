/*==============================================================================
This Wikiwyg mode supports a textarea editor with toolbar buttons.

COPYRIGHT:

    Copyright (c) 2005 Socialtext Corporation 
    655 High Street
    Palo Alto, CA 94301 U.S.A.
    All rights reserved.

Wikiwyg is free software. 

This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or (at
your option) any later version.

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
General Public License for more details.

    http://www.gnu.org/copyleft/lesser.txt

 =============================================================================*/

proto = new Subclass('Wikiwyg.Wikitext', 'Wikiwyg.Mode');
klass = Wikiwyg.Wikitext;

proto.classtype = 'wikitext';
proto.modeDescription = 'Wikitext';

proto.config = {
    textareaId: null,
    supportCamelCaseLinks: false,
    javascriptLocation: null,
    clearRegex: null,
    editHeightMinimum: 10,
    editHeightAdjustment: 1.3,
    markupRules: {
        link: ['bound_phrase', '[', ']'],
        bold: ['bound_phrase', '*', '*'],
        code: ['bound_phrase', '`', '`'],
        italic: ['bound_phrase', '/', '/'],
        underline: ['bound_phrase', '_', '_'],
        strike: ['bound_phrase', '-', '-'],
        p: ['start_lines', ''],
        pre: ['start_lines', '    '],
        h1: ['start_line', '= '],
        h2: ['start_line', '== '],
        h3: ['start_line', '=== '],
        h4: ['start_line', '==== '],
        h5: ['start_line', '===== '],
        h6: ['start_line', '====== '],
        ordered: ['start_lines', '#'],
        unordered: ['start_lines', '*'],
        indent: ['start_lines', '>'],
        hr: ['line_alone', '----'],
        table: ['line_alone', '| A | B | C |\n|   |   |   |\n|   |   |   |'],
        www: ['bound_phrase', '[', ']']
    }
}

proto.initializeObject = function() { // See IE
    this.initialize_object();
}

proto.initialize_object = function() {
    this.div = document.createElement('div');
    if (this.config.textareaId)
        this.textarea = document.getElementById(this.config.textareaId);
    else
        this.textarea = document.createElement('textarea');
    this.textarea.setAttribute('id', 'wikiwyg_wikitext_textarea');
    this.div.appendChild(this.textarea);
    this.area = this.textarea;
    this.clear_inner_text();
}

proto.clear_inner_text = function() {
    if ( Wikiwyg.is_safari ) return;
    var self = this;
    this.area.onclick = function() {
        var inner_text = self.area.value;
        var clear = self.config.clearRegex;
        if (clear && inner_text.match(clear))
            self.area.value = '';
    }
}

proto.enableThis = function() {
    Wikiwyg.Mode.prototype.enableThis.call(this);
    this.textarea.style.width = '100%';
    this.setHeightOfEditor();
    this.enable_keybindings();
}

proto.setHeightOfEditor = function() {
    var config = this.config;
    var adjust = config.editHeightAdjustment;
    var area   = this.textarea;

    if ( Wikiwyg.is_safari) return area.setAttribute('rows', 25);

    var text   = this.getTextArea() ;
    var rows   = text.split(/\n/).length;

    var height = parseInt(rows * adjust);
    if (height < config.editHeightMinimum)
        height = config.editHeightMinimum;

    area.setAttribute('rows', height);
}

proto.toWikitext = function() {
    return this.getTextArea();
}

proto.toHtml = function(func) {
    var wikitext = this.canonicalText();
    this.convertWikitextToHtml(wikitext, func);
}

proto.canonicalText = function() {
    var wikitext = this.getTextArea();
    if (wikitext[wikitext.length - 1] != '\n')
        wikitext += '\n';
    return wikitext;
}

proto.fromHtml = function(html) {
    this.setTextArea('Loading...');
    var self = this;
    this.convertHtmlToWikitext(
        html, 
        function(value) { self.setTextArea(value) }
    );
}

proto.getTextArea = function() {
    return this.textarea.value;
}

proto.setTextArea = function(text) {
    this.textarea.value = text;
}

proto.convertWikitextToHtml = function(wikitext, func) {
    alert('Wikitext changes cannot be converted to HTML\nWikiwyg.Wikitext.convertWikitextToHtml is not implemented here');
    func(this.copyhtml);
}

proto.convertHtmlToWikitext = function(html, func) {
    func(this.convert_html_to_wikitext(html));
}

proto.get_keybinding_area = function() {
    return this.textarea;
}

/*==============================================================================
Code to markup wikitext
 =============================================================================*/
Wikiwyg.Wikitext.phrase_end_re = /[\s\.\:\;\,\!\?\(\)]/;

proto.find_left = function(t, selection_start, matcher) {
    var substring = t.substr(selection_start - 1, 1);
    var nextstring = t.substr(selection_start - 2, 1);
    if (selection_start == 0) 
        return selection_start;
    if (substring.match(matcher)) {
        // special case for word.word
        if ((substring != '.') || (nextstring.match(/\s/))) 
            return selection_start;
    }
    return this.find_left(t, selection_start - 1, matcher);
}  

proto.find_right = function(t, selection_end, matcher) {
    var substring = t.substr(selection_end, 1);
    var nextstring = t.substr(selection_end + 1, 1);
    if (selection_end >= t.length)
        return selection_end;
    if (substring.match(matcher)) {
        // special case for word.word
        if ((substring != '.') || (nextstring.match(/\s/)))
            return selection_end;
    }
    return this.find_right(t, selection_end + 1, matcher);
}

proto.get_lines = function() {
    t = this.area; // XXX needs "var"?
    var selection_start = t.selectionStart;
    var selection_end = t.selectionEnd;

    if (selection_start == null) {
        selection_start = selection_end;
        if (selection_start == null) {
            return false
        }
        selection_start = selection_end =
            t.value.substr(0, selection_start).replace(/\r/g, '').length;
    }

    var our_text = t.value.replace(/\r/g, '');
    selection = our_text.substr(selection_start,
        selection_end - selection_start);

    selection_start = this.find_right(our_text, selection_start, /[^\r\n]/);
    selection_end = this.find_left(our_text, selection_end, /[^\r\n]/);

    this.selection_start = this.find_left(our_text, selection_start, /[\r\n]/);
    this.selection_end = this.find_right(our_text, selection_end, /[\r\n]/);
    t.setSelectionRange(selection_start, selection_end);
    t.focus();

    this.start = our_text.substr(0,this.selection_start);
    this.sel = our_text.substr(this.selection_start, this.selection_end -
        this.selection_start);
    this.finish = our_text.substr(this.selection_end, our_text.length);

    return true;
}

proto.alarm_on = function() {
    var area = this.area;
    var background = area.style.background;
    area.style.background = '#f88';

    function alarm_off() {
        area.style.background = background;
    }

    window.setTimeout(alarm_off, 250);
    area.focus()
}

proto.get_words = function() {
    function is_insane(selection) {
        return selection.match(/\r?\n(\r?\n|\*+ |\#+ |\=+ )/);
    }   

    t = this.area; // XXX needs "var"?
    var selection_start = t.selectionStart;
    var selection_end = t.selectionEnd;

    if (selection_start == null) {
        selection_start = selection_end;
        if (selection_start == null) {
            return false
        }
        selection_start = selection_end =
            t.value.substr(0, selection_start).replace(/\r/g, '').length;
    }

    var our_text = t.value.replace(/\r/g, '');
    selection = our_text.substr(selection_start,
        selection_end - selection_start);

    selection_start = this.find_right(our_text, selection_start, /(\S|\r?\n)/);
    if (selection_start > selection_end)
        selection_start = selection_end;
    selection_end = this.find_left(our_text, selection_end, /(\S|\r?\n)/);
    if (selection_end < selection_start)
        selection_end = selection_start;

    if (is_insane(selection)) {
        this.alarm_on();
        return false;
    }

    this.selection_start =
        this.find_left(our_text, selection_start, Wikiwyg.Wikitext.phrase_end_re);
    this.selection_end =
        this.find_right(our_text, selection_end, Wikiwyg.Wikitext.phrase_end_re);

    t.setSelectionRange(this.selection_start, this.selection_end);
    t.focus();

    this.start = our_text.substr(0,this.selection_start);
    this.sel = our_text.substr(this.selection_start, this.selection_end -
        this.selection_start);
    this.finish = our_text.substr(this.selection_end, our_text.length);

    return true;
}

proto.markup_is_on = function(start, finish) {
    return (this.sel.match(start) && this.sel.match(finish));
}

proto.clean_selection = function(start, finish) {
    this.sel = this.sel.replace(start, '');
    this.sel = this.sel.replace(finish, '');
}

proto.toggle_same_format = function(start, finish) {
    start = this.clean_regexp(start);
    finish = this.clean_regexp(finish);
    var start_re = new RegExp('^' + start);
    var finish_re = new RegExp(finish + '$');
    if (this.markup_is_on(start_re, finish_re)) {
        this.clean_selection(start_re, finish_re);
        return true;
    }
    return false;
}

proto.clean_regexp = function(string) {
    string = string.replace(/([\^\$\*\+\.\?\[\]\{\}])/g, '\\$1');
    return string;
}

proto.insert_text_at_cursor = function(text) {
    var t = this.area;

    var selection_start = t.selectionStart;
    var selection_end = t.selectionEnd;

    if (selection_start == null) {
        selection_start = selection_end;
        if (selection_start == null) {
            return false
        }
    }

    var before = t.value.substr(0, selection_start);
    var after = t.value.substr(selection_end, t.value.length);
    t.value = before + text + after;
}

proto.set_text_and_selection = function(text, start, end) {
    this.area.value = text;
    this.area.setSelectionRange(start, end);
}

proto.add_markup_words = function(markup_start, markup_finish, example) {
    if (this.toggle_same_format(markup_start, markup_finish)) {
        this.selection_end = this.selection_end -
            (markup_start.length + markup_finish.length);
        markup_start = '';
        markup_finish = '';
    }
    if (this.sel.length == 0) {
        if (example)
            this.sel = example;
        var text = this.start + markup_start + this.sel +
            markup_finish + this.finish;
        var start = this.selection_start + markup_start.length;
        var end = this.selection_end + markup_start.length + this.sel.length;
        this.set_text_and_selection(text, start, end);
    } else {
        var text = this.start + markup_start + this.sel +
            markup_finish + this.finish;
        var start = this.selection_start;
        var end = this.selection_end + markup_start.length +
            markup_finish.length;
        this.set_text_and_selection(text, start, end);
    }
    this.area.focus();
}

// XXX - A lot of this is hardcoded.
proto.add_markup_lines = function(markup_start) {
    var already_set_re = new RegExp( '^' + this.clean_regexp(markup_start), 'gm');
    var other_markup_re = /^(\^+|\=+|\*+|#+|>+|    )/gm;

    var match;
    // if paragraph, reduce everything.
    if (! markup_start.length) {
        this.sel = this.sel.replace(other_markup_re, '');
        this.sel = this.sel.replace(/^\ +/gm, '');
    }
    // if pre and not all indented, indent
    else if ((markup_start == '    ') && this.sel.match(/^\S/m))
        this.sel = this.sel.replace(/^/gm, markup_start);
    // if not requesting heading and already this style, kill this style
    else if (
        (! markup_start.match(/[\=\^]/)) &&
        this.sel.match(already_set_re)
    ) {
        this.sel = this.sel.replace(already_set_re, '');
        if (markup_start != '    ')
            this.sel = this.sel.replace(/^ */gm, '');
    }
    // if some other style, switch to new style
    else if (match = this.sel.match(other_markup_re))
        // if pre, just indent
        if (markup_start == '    ')
            this.sel = this.sel.replace(/^/gm, markup_start);
        // if heading, just change it
        else if (markup_start.match(/[\=\^]/))
            this.sel = this.sel.replace(other_markup_re, markup_start);
        // else try to change based on level
        else
            this.sel = this.sel.replace(
                other_markup_re,
                function(match) {
                    return markup_start.times(match.length);
                }
            );
    // if something selected, use this style
    else if (this.sel.length > 0)
        this.sel = this.sel.replace(/^(.*\S+)/gm, markup_start + ' $1');
    // just add the markup
    else
        this.sel = markup_start + ' ';

    var text = this.start + this.sel + this.finish;
    var start = this.selection_start;
    var end = this.selection_start + this.sel.length;
    this.set_text_and_selection(text, start, end);
    this.area.focus();
}

// XXX - A lot of this is hardcoded.
proto.bound_markup_lines = function(markup_array) {
    var markup_start = markup_array[1];
    var markup_finish = markup_array[2];
    var already_start = new RegExp('^' + this.clean_regexp(markup_start), 'gm');
    var already_finish = new RegExp(this.clean_regexp(markup_finish) + '$', 'gm');
    var other_start = /^(\^+|\=+|\*+|#+|>+) */gm;
    var other_finish = /( +(\^+|\=+))?$/gm;

    var match;
    if (this.sel.match(already_start)) {
        this.sel = this.sel.replace(already_start, '');
        this.sel = this.sel.replace(already_finish, '');
    }
    else if (match = this.sel.match(other_start)) {
        this.sel = this.sel.replace(other_start, markup_start);
        this.sel = this.sel.replace(other_finish, markup_finish);
    }
    // if something selected, use this style
    else if (this.sel.length > 0) {
        this.sel = this.sel.replace(
            /^(.*\S+)/gm,
            markup_start + '$1' + markup_finish
        );
    }
    // just add the markup
    else
        this.sel = markup_start + markup_finish;

    var text = this.start + this.sel + this.finish;
    var start = this.selection_start;
    var end = this.selection_start + this.sel.length;
    this.set_text_and_selection(text, start, end);
    this.area.focus();
}

proto.markup_bound_line = function(markup_array) {
    var scroll_top = this.area.scrollTop;
    if (this.get_lines())
        this.bound_markup_lines(markup_array);
    this.area.scrollTop = scroll_top;
}

proto.markup_start_line = function(markup_array) {
    var markup_start = markup_array[1];
    markup_start = markup_start.replace(/ +/, '');
    var scroll_top = this.area.scrollTop;
    if (this.get_lines())
        this.add_markup_lines(markup_start);
    this.area.scrollTop = scroll_top;
}

proto.markup_start_lines = function(markup_array) {
    var markup_start = markup_array[1];
    var scroll_top = this.area.scrollTop;
    if (this.get_lines())
        this.add_markup_lines(markup_start);
    this.area.scrollTop = scroll_top;
}

proto.markup_bound_phrase = function(markup_array) {
    var markup_start = markup_array[1];
    var markup_finish = markup_array[2];
    var scroll_top = this.area.scrollTop;
    if (markup_finish == 'undefined')
        markup_finish = markup_start;
    if (this.get_words())
        this.add_markup_words(markup_start, markup_finish, null);
    this.area.scrollTop = scroll_top;
}

klass.make_do = function(style) {
    return function() {
        var markup = this.config.markupRules[style];
        var handler = markup[0];
        if (! this['markup_' + handler])
            die('No handler for markup: "' + handler + '"');
        this['markup_' + handler](markup);
    }
}

proto.do_link = klass.make_do('link');
proto.do_bold = klass.make_do('bold');
proto.do_code = klass.make_do('code');
proto.do_italic = klass.make_do('italic');
proto.do_underline = klass.make_do('underline');
proto.do_strike = klass.make_do('strike');
proto.do_p = klass.make_do('p');
proto.do_pre = klass.make_do('pre');
proto.do_h1 = klass.make_do('h1');
proto.do_h2 = klass.make_do('h2');
proto.do_h3 = klass.make_do('h3');
proto.do_h4 = klass.make_do('h4');
proto.do_h5 = klass.make_do('h5');
proto.do_h6 = klass.make_do('h6');
proto.do_ordered = klass.make_do('ordered');
proto.do_unordered = klass.make_do('unordered');
proto.do_hr = klass.make_do('hr');
proto.do_table = klass.make_do('table');

proto.do_www = function() {
    var  url =  prompt("Please enter a link", "Type in your link here");
	var old = this.config.markupRules.www[1];
	this.config.markupRules.www[1] += url + " ";
  
	// do the transformation 
	var markup = this.config.markupRules['www'];
    var handler = markup[0];
     if (! this['markup_' + handler])
    	die('No handler for markup: "' + handler + '"');
    this['markup_' + handler](markup);

	// reset
	this.config.markupRules.www[1] = old;	
}

proto.selection_mangle = function(method) {
    var scroll_top = this.area.scrollTop;
    if (! this.get_lines()) {
        this.area.scrollTop = scroll_top;
        return;
    }

    if (method(this)) {
        var text = this.start + this.sel + this.finish;
        var start = this.selection_start;
        var end = this.selection_start + this.sel.length;
        this.set_text_and_selection(text, start, end);
    }
    this.area.focus();
}

proto.do_indent = function() {
    this.selection_mangle(
        function(that) {
            if (that.sel == '') return false;
            that.sel = that.sel.replace(/^(([\*\-\#])+(?=\s))/gm, '$2$1');
            that.sel = that.sel.replace(/^([\>\=])/gm, '$1$1');
            that.sel = that.sel.replace(/^([^\>\*\-\#\=\r\n])/gm, '> $1');
            that.sel = that.sel.replace(/^\={7,}/gm, '======');
            return true;
        }
    )
}

proto.do_outdent = function() {
    this.selection_mangle(
        function(that) {
            if (that.sel == '') return false;
            that.sel = that.sel.replace(/^([\>\*\-\#\=] ?)/gm, '');
            return true;
        }
    )
}

proto.do_unlink = function() {
    this.selection_mangle(
        function(that) {
            that.sel = that.kill_linkedness(that.sel);
            return true;
        }
    );
}

// TODO - generalize this to allow Wikitext dialects that don't use "[foo]"
proto.kill_linkedness = function(str) {
    while (str.match(/\[.*\]/))
        str = str.replace(/\[(.*?)\]/, '$1');
    str = str.replace(/^(.*)\]/, '] $1');
    str = str.replace(/\[(.*)$/, '$1 [');
    return str;
}

proto.markup_line_alone = function(markup_array) {
    var t = this.area;
    var scroll_top = t.scrollTop;
    var selection_start = t.selectionStart;
    var selection_end = t.selectionEnd;
    if (selection_start == null) {
        selection_start = selection_end;
    }
    
    var text = t.value;
    this.selection_start = this.find_right(text, selection_start, /\r?\n/);
    this.selection_end = this.selection_start;
    t.setSelectionRange(this.selection_start, this.selection_start);
    t.focus();

    var markup = markup_array[1];
    this.start = t.value.substr(0, this.selection_start);
    this.finish = t.value.substr(this.selection_end, t.value.length);
    var text = this.start + '\n' + markup + this.finish;
    var start = this.selection_start + markup.length + 1;
    var end = this.selection_end + markup.length + 1;
    this.set_text_and_selection(text, start, end);
    t.scrollTop = scroll_top;
}


/*==============================================================================
Code to convert from html to wikitext.
 =============================================================================*/
proto.convert_html_to_wikitext = function(html) {
    this.copyhtml = html;
    var dom = document.createElement('div');
    dom.innerHTML = html;
    this.output = [];
    this.list_type = [];
    this.indent_level = 0;
    this.no_collapse_text = false;

    this.normalizeDomWhitespace(dom);
    this.normalizeDomStructure(dom);

    this.walk(dom);

    // add final whitespace
    this.assert_new_line();

    return this.join_output(this.output);
}

proto.normalizeDomStructure = function(dom) {
    this.normalize_styled_blocks(dom, 'p');
    this.normalize_styled_lists(dom, 'ol');
    this.normalize_styled_lists(dom, 'ul');
    this.normalize_styled_blocks(dom, 'li');
    this.normalize_span_whitespace(dom, 'span');
}

proto.normalize_span_whitespace = function(dom,tag ) {
    var grep = function(element) {
       return Boolean(element.getAttribute('style'));
    }
        
    var elements = this.array_elements_by_tag_name(dom, tag, grep);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var node = element.firstChild;
        while (node) {
            if (node.nodeType == 3) {
                node.nodeValue = node.nodeValue.replace(/^\n+/,"");
                break;
            }
            node = node.nextSibling;
        }
        var node = element.lastChild;
        while (node) {
            if (node.nodeType == 3) {
                node.nodeValue = node.nodeValue.replace(/\n+$/,"");
                break;
            }
            node = node.previousSibling;
        }
    }
}

proto.normalize_styled_blocks = function(dom, tag) {
    var elements = this.array_elements_by_tag_name(dom, tag);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var style = element.getAttribute('style');
        if (!style) continue;
        element.removeAttribute('style');
        element.innerHTML =
            '<span style="' + style + '">' + element.innerHTML + '</span>';
    }
}

proto.normalize_styled_lists = function(dom, tag) {
    var elements = this.array_elements_by_tag_name(dom, tag);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var style = element.getAttribute('style');
        if (!style) continue;
        element.removeAttribute('style');

        var items = element.getElementsByTagName('li');
        for (var j = 0; j < items.length; j++) {
            items[j].innerHTML = 
                '<span style="' + style + '">' + items[j].innerHTML + '</span>';
        }
    }
}

proto.array_elements_by_tag_name = function(dom, tag, grep) {
    var result = dom.getElementsByTagName(tag);
    var elements = [];
    for (var i = 0; i < result.length; i++) {
        if (grep && ! grep(result[i]))
            continue;
        elements.push(result[i]);
    }
    return elements;
}

proto.normalizeDomWhitespace = function(dom) {
    var tags = ['span', 'strong', 'em', 'strike', 'del', 'tt'];
    for (var ii = 0; ii < tags.length; ii++) {
        var elements = dom.getElementsByTagName(tags[ii]);
        for (var i = 0; i < elements.length; i++) {
            this.normalizePhraseWhitespace(elements[i]);
        }
    }
    this.normalizeNewlines(dom, ['br', 'blockquote'], 'nextSibling');
    this.normalizeNewlines(dom, ['p', 'div', 'blockquote'], 'firstChild');
}

proto.normalizeNewlines = function(dom, tags, relation) {
    for (var ii = 0; ii < tags.length; ii++) {
        var nodes = dom.getElementsByTagName(tags[ii]);
        for (var jj = 0; jj < nodes.length; jj++) {
            var next_node = nodes[jj][relation];
            if (next_node && next_node.nodeType == '3') {
                next_node.nodeValue = next_node.nodeValue.replace(/^\n/, '');
            }
        }
    }
}

proto.normalizePhraseWhitespace = function(element) {
    if (this.elementHasComment(element)) return;

    var first_node = this.getFirstTextNode(element);
    var prev_node = this.getPreviousTextNode(element);
    var last_node = this.getLastTextNode(element);
    var next_node = this.getNextTextNode(element);

    if (this.destroyPhraseMarkup(element)) return;

    if (first_node && first_node.nodeValue.match(/^ /)) {
        first_node.nodeValue = first_node.nodeValue.replace(/^ +/, '');
        if (prev_node && ! prev_node.nodeValue.match(/ $/)) 
            prev_node.nodeValue = prev_node.nodeValue + ' ';
    }

    if (last_node && last_node.nodeValue.match(/ $/)) {
        last_node.nodeValue = last_node.nodeValue.replace(/ $/, '');
        if (next_node && ! next_node.nodeValue.match(/^ /)) 
            next_node.nodeValue = ' ' + next_node.nodeValue;
    }
}

proto.elementHasComment = function(element) {
    var node = element.lastChild;
    return node && (node.nodeType == 8);
}

proto.destroyPhraseMarkup = function(element) {
    if (this.start_is_no_good(element) || this.end_is_no_good(element))
        return this.destroyElement(element);
    return false;
}

proto.start_is_no_good = function(element) {
    var first_node = this.getFirstTextNode(element);
    var prev_node = this.getPreviousTextNode(element);

    if (! first_node) return true;
    if (first_node.nodeValue.match(/^ /)) return false;
    if (! prev_node || prev_node.nodeValue == '\n') return false;
    return ! prev_node.nodeValue.match(/[ "]$/);
}

proto.end_is_no_good = function(element) {
    var last_node = this.getLastTextNode(element);
    var next_node = this.getNextTextNode(element);

    for (var n = element; n && n.nodeType != 3; n = n.lastChild) {
        if (n.nodeType == 8) return false;
    }

    if (! last_node) return true;
    if (last_node.nodeValue.match(/ $/)) return false;
    if (! next_node || next_node.nodeValue == '\n') return false;
    return ! next_node.nodeValue.match(/^[ ."\n]/);
}

proto.destroyElement = function(element) {
    var span = document.createElement('font');
    span.innerHTML = element.innerHTML;
    element.parentNode.replaceChild(span, element);
    return true;
}

proto.getFirstTextNode = function(element) {
    for (node = element; node && node.nodeType != 3; node = node.firstChild) {
    }
    return node;
}

proto.getLastTextNode = function(element) {
    for (node = element; node && node.nodeType != 3; node = node.lastChild) {
    }
    return node;
}

proto.getPreviousTextNode = function(element) {
    var node = element.previousSibling;
    if (node && node.nodeType != 3)
        node = null;
    return node;
}

proto.getNextTextNode = function(element) {
    var node = element.nextSibling;
    if (node && node.nodeType != 3)
        node = null;
    return node;
}

proto.appendOutput = function(string) {
    this.output.push(string);
}

proto.join_output = function(output) {
    var list = this.remove_stops(output);
    list = this.cleanup_output(list);
    return list.join('');
}

// This is a noop, but can be subclassed.
proto.cleanup_output = function(list) {
    return list;
}

proto.remove_stops = function(list) {
    var clean = [];
    for (var i = 0 ; i < list.length ; i++) {
        if (typeof(list[i]) != 'string') continue;
        clean.push(list[i]);
    }
    return clean;
}

proto.walk = function(element) {
    if (!element) return;
    for (var part = element.firstChild; part; part = part.nextSibling) {
        if (part.nodeType == 1) {
            this.dispatch_formatter(part);
        }
        else if (part.nodeType == 3) {
            if (part.nodeValue.match(/[^\n]/) &&
                ! part.nodeValue.match(/^\n[\ \t]*$/)
               ) {
                if (this.no_collapse_text) { 
                    this.appendOutput(part.nodeValue);
                }
                else {
                    this.appendOutput(this.collapse(part.nodeValue));
                }
            }
        }
    }
    this.no_collapse_text = false;
}

proto.dispatch_formatter = function(element) {
    var dispatch = 'format_' + element.nodeName.toLowerCase();
    if (! this[dispatch])
        dispatch = 'handle_undefined';
    this[dispatch](element);
}

proto.skip = function() { }
proto.pass = function(element) {
    this.walk(element);
}
proto.handle_undefined = function(element) {
    this.appendOutput('<' + element.nodeName + '>');
    this.walk(element);
    this.appendOutput('</' + element.nodeName + '>');
}
proto.handle_undefined = proto.skip;

proto.format_abbr = proto.pass;
proto.format_acronym = proto.pass;
proto.format_address = proto.pass;
proto.format_applet = proto.skip;
proto.format_area = proto.skip;
proto.format_basefont = proto.skip;
proto.format_base = proto.skip;
proto.format_bgsound = proto.skip;
proto.format_big = proto.pass;
proto.format_blink = proto.pass;
proto.format_body = proto.pass;
proto.format_br = proto.skip;
proto.format_button = proto.skip;
proto.format_caption = proto.pass;
proto.format_center = proto.pass;
proto.format_cite = proto.pass;
proto.format_col = proto.pass;
proto.format_colgroup = proto.pass;
proto.format_dd = proto.pass;
proto.format_dfn = proto.pass;
proto.format_dl = proto.pass;
proto.format_dt = proto.pass;
proto.format_embed = proto.skip;
proto.format_field = proto.skip;
proto.format_fieldset = proto.skip;
proto.format_font = proto.pass;
proto.format_form = proto.skip;
proto.format_frame = proto.skip;
proto.format_frameset = proto.skip;
proto.format_head = proto.skip;
proto.format_html = proto.pass;
proto.format_iframe = proto.pass;
proto.format_input = proto.skip;
proto.format_ins = proto.pass;
proto.format_isindex = proto.skip;
proto.format_label = proto.skip;
proto.format_legend = proto.skip;
proto.format_link = proto.skip;
proto.format_map = proto.skip;
proto.format_marquee = proto.skip;
proto.format_meta = proto.skip;
proto.format_multicol = proto.pass;
proto.format_nobr = proto.skip;
proto.format_noembed = proto.skip;
proto.format_noframes = proto.skip;
proto.format_nolayer = proto.skip;
proto.format_noscript = proto.skip;
proto.format_nowrap = proto.skip;
proto.format_object = proto.skip;
proto.format_optgroup = proto.skip;
proto.format_option = proto.skip;
proto.format_param = proto.skip;
proto.format_select = proto.skip;
proto.format_small = proto.pass;
proto.format_spacer = proto.skip;
proto.format_style = proto.skip;
proto.format_sub = proto.pass;
proto.format_submit = proto.skip;
proto.format_sup = proto.pass;
proto.format_tbody = proto.pass;
proto.format_textarea = proto.skip;
proto.format_tfoot = proto.pass;
proto.format_thead = proto.pass;
proto.format_wiki = proto.pass;
proto.format_www = proto.skip;

proto.format_img = function(element) {
    var uri = element.getAttribute('src');
    if (uri) {
        this.assert_space_or_newline();
        this.appendOutput(uri);
    }
}

// XXX This little dance relies on knowning lots of little details about where
// indentation fangs are added and deleted by the various insert/assert calls.
proto.format_blockquote = function(element) {
    var margin  = parseInt(element.style.marginLeft);
    var indents = 0;
    if (margin)
        indents += parseInt(margin / 40);
    if (element.tagName.toLowerCase() == 'blockquote')
        indents += 1;

    if (!this.indent_level)
        this.first_indent_line = true;
    this.indent_level += indents;

    this.output = defang_last_string(this.output);
    this.assert_new_line();
    this.walk(element);
    this.indent_level -= indents;

    if (! this.indent_level)
        this.assert_blank_line();
    else
        this.assert_new_line();

    function defang_last_string(output) {
        function non_string(a) { return typeof(a) != 'string' }

        // Strategy: reverse the output list, take any non-strings off the
        // head (tail of the original output list), do the substitution on the
        // first item of the reversed head (this is the last string in the
        // original list), then join and reverse the result.
        //
        // Suppose the output list looks like this, where a digit is a string,
        // a letter is an object, and * is the substituted string: 01q234op.

        var rev = output.slice().reverse();                     // po432q10
        var rev_tail = takeWhile(non_string, rev);              // po
        var rev_head = dropWhile(non_string, rev);              // 432q10

        if (rev_head.length)
            rev_head[0].replace(/^>+/, '');                     // *32q10

        // po*3210 -> 0123*op
        return rev_tail.concat(rev_head).reverse();             // 01q23*op
    }
}

proto.format_div = function(element) {
    if (this.is_opaque(element)) {
        this.handle_opaque_block(element);
        return;
    }
    if (this.is_indented(element)) {
        this.format_blockquote(element);
        return;
    }
    this.walk(element);
}

proto.format_span = function(element) {
    if (this.is_opaque(element)) {
        this.handle_opaque_phrase(element);
        return;
    }

    var style = element.getAttribute('style');
    if (!style) {
        this.pass(element);
        return;
    }

    if (   ! this.element_has_text_content(element)
        && ! this.element_has_only_image_content(element)) return;
    var attributes = [ 'line-through', 'bold', 'italic', 'underline' ];
    for (var i = 0; i < attributes.length; i++)
        this.check_style_and_maybe_mark_up(style, attributes[i], 1);
    this.no_following_whitespace();
    this.walk(element);
    for (var i = attributes.length; i >= 0; i--)
        this.check_style_and_maybe_mark_up(style, attributes[i], 2);
}

proto.element_has_text_content = function(element) {
    return element.innerHTML.replace(/<.*?>/g, '')
                            .replace(/&nbsp;/g, '').match(/\S/);
}

proto.element_has_only_image_content = function(element) {
    return    element.childNodes.length == 1
           && element.firstChild.nodeType == 1
           && element.firstChild.tagName.toLowerCase() == 'img';
}

proto.check_style_and_maybe_mark_up = function(style, attribute, open_close) {
    var markup_rule = attribute;
    if (markup_rule == 'line-through')
        markup_rule = 'strike';
    if (this.check_style_for_attribute(style, attribute))
        this.appendOutput(this.config.markupRules[markup_rule][open_close]);
}

proto.check_style_for_attribute = function(style, attribute) {
    var string = this.squish_style_object_into_string(style);
    return string.match("\\b" + attribute + "\\b");
}

proto.squish_style_object_into_string = function(style) {
    if ((style.constructor+'').match('String'))
        return style;
    var interesting_attributes = [
        [ 'font', 'weight' ],
        [ 'font', 'style' ],
        [ 'text', 'decoration' ]
    ];
    var string = '';
    for (var i = 0; i < interesting_attributes.length; i++) {
        var pair = interesting_attributes[i];
        var css = pair[0] + '-' + pair[1];
        var js = pair[0] + pair[1].ucFirst();
        string += css + ': ' + style[js] + '; ';
    }
    return string;
}

proto.basic_formatter = function(element, style) {
    var markup = this.config.markupRules[style];
    var handler = markup[0];
    this['handle_' + handler](element, markup);
}

klass.make_empty_formatter = function(style) {
    return function(element) {
        this.basic_formatter(element, style);
    }
}

klass.make_formatter = function(style) {
    return function(element) {
        if (this.element_has_text_content(element))
            this.basic_formatter(element, style);
    }
}

proto.format_b = klass.make_formatter('bold');
proto.format_strong = proto.format_b;
proto.format_code = klass.make_formatter('code');
proto.format_kbd = proto.format_code;
proto.format_samp = proto.format_code;
proto.format_tt = proto.format_code;
proto.format_var = proto.format_code;
proto.format_i = klass.make_formatter('italic');
proto.format_em = proto.format_i;
proto.format_u = klass.make_formatter('underline');
proto.format_strike = klass.make_formatter('strike');
proto.format_del = proto.format_strike;
proto.format_s = proto.format_strike;
proto.format_hr = klass.make_empty_formatter('hr');
proto.format_h1 = klass.make_formatter('h1');
proto.format_h2 = klass.make_formatter('h2');
proto.format_h3 = klass.make_formatter('h3');
proto.format_h4 = klass.make_formatter('h4');
proto.format_h5 = klass.make_formatter('h5');
proto.format_h6 = klass.make_formatter('h6');
proto.format_pre = klass.make_formatter('pre');

proto.format_p = function(element) {
    if (this.is_indented(element)) {
        this.format_blockquote(element);
        return;
    }
    this.assert_blank_line();
    this.walk(element);
    this.assert_blank_line();
}

proto.format_a = function(element) {
    var label = Wikiwyg.htmlUnescape(element.innerHTML);
    label = label.replace(/<[^>]*?>/g, ' ');
    label = label.replace(/\s+/g, ' ');
    label = label.replace(/^\s+/, '');
    label = label.replace(/\s+$/, '');
    var href = element.getAttribute('href');
    if (! href) href = ''; // Necessary for <a name="xyz"></a>'s
    this.make_wikitext_link(label, href, element);
}

proto.format_table = function(element) {
    this.assert_blank_line();
    this.walk(element);
    this.assert_blank_line();
}

proto.format_tr = function(element) {
    this.walk(element);
    this.appendOutput('|');
    this.insert_new_line();
}

proto.format_td = function(element) {
    this.appendOutput('| ');
    this.no_following_whitespace();
    this.walk(element);
    this.chomp();
    this.appendOutput(' ');
}
proto.format_th = proto.format_td;

// Generic functions on lists taken from the Haskell Prelude.
// See http://xrl.us/jbko
//
// These sorts of thing should probably be moved to some general-purpose
// Javascript library.

function takeWhile(f, a) {
    for (var i = 0; i < a.length; ++i)
        if (! f(a[i])) break;

    return a.slice(0, i);
}

function dropWhile(f, a) {
    for (var i = 0; i < a.length; ++i)
        if (! f(a[i])) break;

    return a.slice(i);
}

proto.previous_line = function() {
    function newline(s) { return s['match'] && s.match(/\n/) }
    function non_newline(s) { return ! newline(s) }

    return this.join_output(
        takeWhile(non_newline,
            dropWhile(newline,
                this.output.slice().reverse()
            )
        ).reverse()
    );
}

proto.make_list = function(element, list_type) { 
    if (! this.previous_was_newline_or_start())
        this.insert_new_line();

    this.list_type.push(list_type);
    this.walk(element);
    this.list_type.pop();
    if (this.list_type.length == 0)
        this.assert_blank_line();
}

proto.format_ol = function(element) {
    this.make_list(element, 'ordered');
}

proto.format_ul = function(element) {
    this.make_list(element, 'unordered');
}

proto.format_li = function(element) {
    var level = this.list_type.length;
    if (!level) die("Wikiwyg list error");
    var type = this.list_type[level - 1];
    var markup = this.config.markupRules[type];
    this.appendOutput(markup[1].times(level) + ' ');

    // Nasty ie hack which I don't want to talk about.
    // But I will...
    // *Sometimes* when pulling html out of the designmode iframe it has
    // <LI> elements with no matching </LI> even though the </LI>s existed
    // going in. This needs to be delved into, and we need to see if
    // quirksmode and friends can/should be set somehow on the iframe
    // document for wikiwyg. Also research whether we need an iframe at all on
    // IE. Could we just use a div with contenteditable=true?
    if (Wikiwyg.is_ie &&
        element.firstChild &&
        element.firstChild.nextSibling &&
        element.firstChild.nextSibling.nodeName.match(/^[uo]l$/i))
    {
        try {
            element.firstChild.nodeValue =
              element.firstChild.nodeValue.replace(/ $/, '');
        }
        catch(e) { }
    }

    this.walk(element);

    this.chomp();
    this.insert_new_line();
}

proto.chomp = function() {
    var string;
    while (this.output.length) {
        string = this.output.pop();
        if (typeof(string) != 'string') {
            this.appendOutput(string);
            return;
        }
        if (! string.match(/^\n+>+ $/) && string.match(/\S/))
            break;
    }
    if (string) {
        string = string.replace(/[\r\n\s]+$/, '');
        this.appendOutput(string);
    }
}

proto.collapse = function(string) {
    return string.replace(/[ \u00a0\r\n]+/g, ' ');
}

proto.trim = function(string) {
    return string.replace(/^\s+/, '');
}

proto.insert_new_line = function() {
    var fang = '';
    var indentChar = this.config.markupRules.indent[1];
    var newline = '\n';
    if (this.indent_level > 0) {
        fang = indentChar.times(this.indent_level);
        if (fang.length)
            fang += ' ';
    }
    // XXX - ('\n' + fang) MUST be in the same element in this.output so that
    // it can be properly matched by chomp above.
    if (fang.length && this.first_indent_line) {
        this.first_indent_line = false;
        newline = newline + newline;
    }
    if (this.output.length)
        this.appendOutput(newline + fang);
    else if (fang.length)
        this.appendOutput(fang);
}

proto.previous_was_newline_or_start = function() {
    for (var ii = this.output.length - 1; ii >= 0; ii--) {
        var string = this.output[ii];
        if (typeof(string) != 'string')
            continue;
        return string.match(/\n$/);
    }
    return true;
}

proto.assert_new_line = function() {
    this.chomp();
    this.insert_new_line();
}

proto.assert_blank_line = function() {
    if (! this.should_whitespace()) return
    this.chomp();
    this.insert_new_line();
    this.insert_new_line();
}

proto.assert_space_or_newline = function() {
    if (! this.output.length || ! this.should_whitespace()) return;
    if (! this.previous_output().match(/(\s+|[\(])$/))
        this.appendOutput(' ');
}

proto.no_following_whitespace = function() {
    this.appendOutput({whitespace: 'stop'});
}

proto.should_whitespace = function() {
    return ! this.previous_output().whitespace;
}

// how_far_back defaults to 1
proto.previous_output = function(how_far_back) {
    if (! how_far_back)
        how_far_back = 1;
    var length = this.output.length;
    return length && how_far_back <= length ? this.output[length - how_far_back] : '';
}

proto.handle_bound_phrase = function(element, markup) {
    if (! this.element_has_text_content(element)) return;

    /* If an italics/bold/etc element starts with a
       <br> tag we want to make sure the newline comes _before_ the
       wiki markup we are adding, or we end up with this:

       _
       foo_
    */
    if (element.innerHTML.match(/^\s*<br\s*\/?\s*>/)) {
        this.appendOutput("\n");
        element.innerHTML = element.innerHTML.replace(/^\s*<br\s*\/?\s*>/, '');
    }
    this.appendOutput(markup[1]);
    this.no_following_whitespace();
    this.walk(element);
    // assume that walk leaves no trailing whitespace.
    this.appendOutput(markup[2]);
}

// XXX - A very promising refactoring is that we don't need the trailing
// assert_blank_line in block formatters.
proto.handle_bound_line = function(element,markup) {
    this.assert_blank_line();
    this.appendOutput(markup[1]);
    this.walk(element);
    this.appendOutput(markup[2]);
    this.assert_blank_line();
}

proto.handle_start_line = function (element, markup) {
    this.assert_blank_line();
    this.appendOutput(markup[1]);
    this.walk(element);
    this.assert_blank_line();
}

proto.handle_start_lines = function (element, markup) {
    var text = element.firstChild.nodeValue;
    if (!text) return;
    this.assert_blank_line();
    text = text.replace(/^/mg, markup[1]);
    this.appendOutput(text);
    this.assert_blank_line();
}

proto.handle_line_alone = function (element, markup) {
    this.assert_blank_line();
    this.appendOutput(markup[1]);
    this.assert_blank_line();
}

proto.COMMENT_NODE_TYPE = 8;
proto.get_wiki_comment = function(element) {
    for (var node = element.firstChild; node; node = node.nextSibling) {
        if (node.nodeType == this.COMMENT_NODE_TYPE
            && node.data.match(/^\s*wiki/))
            return node;
    }
    return null;
}

proto.is_indented = function (element) {
    var margin = parseInt(element.style.marginLeft);
    return margin > 0;
}

proto.is_opaque = function(element) {
    var comment = this.get_wiki_comment(element);
    if (!comment) return false;

    var text = comment.data;
    if (text.match(/^\s*wiki:/)) return true;
    return false;
}

proto.handle_opaque_phrase = function(element) {
    var comment = this.get_wiki_comment(element);
    if (comment) {
        var text = comment.data;
        text = text.replace(/^ wiki:\s+/, '')
                   .replace(/-=/g, '-')
                   .replace(/==/g, '=') 
                   .replace(/\s$/, '')
                   .replace(/\{(\w+):\s*\}/, '{$1}');
        this.appendOutput(Wikiwyg.htmlUnescape(text))
        this.smart_trailing_space(element);
    }
}

proto.smart_trailing_space = function(element) {
    var next = element.nextSibling;
    if (! next) {
        // do nothing
    }
    else if (next.nodeType == 1) {
        if (next.nodeName == 'BR') {
            var nn = next.nextSibling;
            if (! (nn && nn.nodeType == 1 && nn.nodeName == 'SPAN'))
                this.appendOutput('\n');
        }
        else {
            this.appendOutput(' ');
        }
    }
    else if (next.nodeType == 3) {
        if (! next.nodeValue.match(/^\s/))
            this.no_following_whitespace();
    }
}

proto.handle_opaque_block = function(element) {
    var comment = this.get_wiki_comment(element);
    if (!comment) return;

    var text = comment.data;
    text = text.replace(/^\s*wiki:\s+/, '');
    this.appendOutput(text);
}

proto.make_wikitext_link = function(label, href, element) {
    var before = this.config.markupRules.link[1];
    var after  = this.config.markupRules.link[2];

	// handle external links
	if (this.looks_like_a_url(href)) {
		before = this.config.markupRules.www[1];
		after = this.config.markupRules.www[2];
	}
	
    this.assert_space_or_newline();
    if (! href) {
        this.appendOutput(label);
    }
    else if (href == label) {
        this.appendOutput(href);
    }
    else if (this.href_is_wiki_link(href)) {
        if (this.camel_case_link(label))
            this.appendOutput(label);
        else
            this.appendOutput(before + label + after);
    }
    else {
        this.appendOutput(before + href + ' ' + label + after);
    }
}

proto.camel_case_link = function(label) {
    if (! this.config.supportCamelCaseLinks)
        return false;
    return label.match(/[a-z][A-Z]/);
}

proto.href_is_wiki_link = function(href) {
    if (! this.looks_like_a_url(href))
        return true;
    if (! href.match(/\?/))
        return false;
    if (href.match(/\/static\/\d+\.\d+\.\d+\.\d+\//))
        href = location.href;
    var no_arg_input   = href.split('?')[0];
    var no_arg_current = location.href.split('?')[0];
    if (no_arg_current == location.href)
        no_arg_current =
          location.href.replace(new RegExp(location.hash), '');
    return no_arg_input == no_arg_current;
}

proto.looks_like_a_url = function(string) {
    return string.match(/^(http|https|ftp|irc|mailto|file):/);
}

/*==============================================================================
Support for Internet Explorer in Wikiwyg.Wikitext
 =============================================================================*/
if (Wikiwyg.is_ie) {

proto.setHeightOf = function() {
    // XXX hardcode this until we can keep window from jumping after button
    // events.
    this.textarea.style.height = '200px';
}

proto.initializeObject = function() {
    this.initialize_object();
    this.area.addBehavior(this.config.javascriptLocation + "Selection.htc");
}

} // end of global if

