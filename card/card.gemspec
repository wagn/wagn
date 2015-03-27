# -*- encoding : utf-8 -*-

#require File.expand_path( '../lib/card/version', __FILE__ )
#version =    Card::Version.release
version = File.open(File.expand_path( '../VERSION', __FILE__ )).read.chomp

Gem::Specification.new do |s|
  s.name          = 'card'
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason", "Philipp Kühl"]
  s.email         = ['info@wagn.org']
                  
#  s.date          = '2013-12-20'
  s.summary       = "an atomic, set-driven content engine"
  s.description   = "Cards are data atoms that are grouped into Sets to which Rules can apply. Cards can formatted with Views and transformed with Events."
  s.homepage      = 'http://wagn.org'
  s.license       = 'GPL'

  s.files         = `git ls-files`.split($/)
  
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.8.7'

  [
    
    [ 'smartname',    '0.2.3'   ],

    [ 'uuid',         '~> 2.3'  ],
    [ 'paperclip',    '~> 2.8'  ],
    [ 'htmlentities', '~> 4.3'  ],
    [ 'rmagick',      '~> 2.13' ],
    [ 'recaptcha',    '~> 0.3'  ],                                  
    [ 'coderay',      '~> 1.0'  ],
    [ 'sass',         '~> 3.2'  ],
    [ 'coffee-script','~> 2.2'  ],
    [ 'uglifier',     '~> 2.5'  ],
    
    [ 'haml',         '~> 4.0'  ],
    [ 'kaminari',     '~> 0.16' ],
    [ 'bootstrap-kaminari-views', '~> 0.0.5'],
    [ 'diffy',        '~> 3.0'  ],
    [ 'diff-lcs',     '~> 1.2'  ],
    # should not depend!
    [ 'airbrake',     '~> 4.1'  ] 

    
  ].each do |dep|
    s.add_runtime_dependency *dep
  end
  
end
