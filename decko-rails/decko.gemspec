#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version = File.open(File.expand_path( '../VERSION', __FILE__ )).read.chomp

Gem::Specification.new do |s|
  s.name          = 'decko-rails'
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason"]
  s.email         = ['info@wagn.org']
                  
#  s.date          = '2013-12-20'
  s.summary       = "rails engine for card: a structured wiki web platform"
  s.description   = "Provides the glue to make the card model available as a Rails::Engine.  Cards are data atoms that are grouped into Sets to which Rules can apply. Cards can formatted with Views and transformed with Events."
  
  s.homepage      = 'http://wagn.org'
  s.license       = 'GPL'

  s.files         = `git ls-files`.split($/)
  
  s.bindir        = 'bin'
  s.executables   = [ 'decko' ]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.8.7'

  [
    [ 'rails',        '3.2.16'  ],
    [ 'card',     version  ]
  ].each do |dep|
    s.add_runtime_dependency *dep
  end
  
end
