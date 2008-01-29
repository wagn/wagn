require RAILS_ROOT + '/lib/wagn/version'
require RAILS_ROOT + '/lib/wagn/exceptions'
require RAILS_ROOT + '/lib/ruby_ext'
require RAILS_ROOT + '/lib/rails_ext'
require RAILS_ROOT + '/lib/cardname'
   

CRAZY_FILES = %{
  
  
  Wagn/Card.js
  Wagn/Editor.js
}

js_dir = "#{RAILS_ROOT}/public/javascripts"
Dir["#{js_dir}/Wagn/*/*.js"].collect do |file|
  #JAVASCRIPT_FILES << 'Wagn/Editor/' + Pathname.new(file).basename.to_s
end

class System

end         