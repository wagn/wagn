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

// Like alert but uses confirm and throw in case you are looped
function XXX(msg) {
    if (! confirm(msg))
        throw("terminated...");
    return msg;
}

// A JSON dumper that uses XXX
function JJJ(obj) {
    XXX(JSON.stringify(obj));
    return obj;
}


// A few handy debugging functions
//(function() {

var klass = Debug = function() {};

klass.sort_object_keys = function(o) {
    var a = [];
    for (p in o) a.push(p);
    return a.sort();
}

klass.dump_keys = function(o) {
    var a = klass.sort_object_keys(o);
    var str='';
    for (p in a)
        str += a[p] + "\t";
    XXX(str);
}

klass.dump_object_into_screen = function(o) {
    var a = klass.sort_object_keys(o);
    var str='';
    for (p in a) {
        var i = a[p];
        try {
            str += a[p] + ': ' + o[i] + '\n';
        } catch(e) {
            // alert('Died on key "' + i + '":\n' + e.message);
        }
    }
    document.write('<xmp>' + str + '</xmp>');
}

//})();

