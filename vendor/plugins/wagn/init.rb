require RAILS_ROOT + '/lib/wagn/version'
require RAILS_ROOT + '/lib/wagn/exceptions'
require RAILS_ROOT + '/lib/ruby_ext'
require RAILS_ROOT + '/lib/rails_ext'
require RAILS_ROOT + '/lib/cardname'


COMPRESSED_JS = 'wagn_cmp.js'
JAVASCRIPT_FILES = %w{
  prototype.js
  effects.js 
  controls.js
  application.js
  Wagn.js

  Wikiwyg.js
  Wikiwyg/Toolbar.js
  Wikiwyg/Wysiwyg.js
  Wikiwyg/Wikitext.js
  Wikiwyg/Preview.js
  Wikiwyg/Util.js
  Wikiwyg/HTML.js
  Wikiwyg/Debug.js
  Wagn/Wikiwyg.js
  Wagn/Lister.js

  calendar.js

  Wagn/LinkEditor.js
  builder.js
  window.js   
}  
#  inline-console.js
#}


CRAZY_FILES = %{
  
  
  Wagn/Card.js
  Wagn/Editor.js
}

js_dir = "#{RAILS_ROOT}/public/javascripts"
Dir["#{js_dir}/Wagn/*/*.js"].collect do |file|
  #JAVASCRIPT_FILES << 'Wagn/Editor/' + Pathname.new(file).basename.to_s
end

module Wagn
  mattr_accessor :javascript_files, :compressed_js
  self.javascript_files = JAVASCRIPT_FILES
  self.compressed_js = COMPRESSED_JS
end         