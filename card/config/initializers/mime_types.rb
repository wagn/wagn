# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.
# Add new mime types for use in respond_to blocks:

# Mime::Type.register 'text/css', :css
# Mime::Type.register 'application/rss+xml', :rss
# Mime::Type.register_alias 'text/plain', :csv   # useful for testing csv in browser

Mime::Type.register_alias "text/plain", :txt
Mime::Type.register "application/vnd.google-earth.kml+xml", :kml

# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
