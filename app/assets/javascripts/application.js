// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require tinymce

//= !require jquery.mobile    
    /* jquery.mobile must be after wagn to avoid mobileinit nastiness */
//= require jquery.ui.all
    /* jquery.ui.all must be after jquery.mobile to override dialog weirdness */
//= require jquery.ui.autocomplete.html.js
    /* this autocomplete must be after jquery.ui stuff */
//= require jquery.autosize
//= require jquery.fileupload.js
//= require jquery.iframe-transport.js
//= require jquery_ujs

/*
Note: I attempted to get tinymce up with tinymce-jquery,
but it overrode val() in ways that broke our filed updating / autosave
*/

