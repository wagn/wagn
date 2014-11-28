#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path( '../lib/card/version', __FILE__ )

Gem::Specification.new do |s|
  s.name          = 'card'
  s.version       = Card::Version.release
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason"]
  s.email         = ['info@wagn.org']
                  
#  s.date          = '2013-12-20'
  s.summary       = "content engine for a structured wiki web platform"
  s.description   = "A Card is a unit of web-deployed, wiki-linked content. It is the core data model for to stuctured wiki data, dynamic interaction, and web design"
  s.homepage      = 'http://wagn.org'
  s.license       = 'GPL'

  s.files         = `git ls-files`.split($/)
  
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.8.7'

  [
    
    [ 'rails',        '3.2.16'  ],
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
    [ 'diffy',        '~> 3.0'  ],
    [ 'diff-lcs',     '~> 1.2'  ],
    # should not depend!
    [ 'airbrake',     '~> 4.1'  ] 

    
  ].each do |dep|
    s.add_runtime_dependency *dep
  end
  
end
