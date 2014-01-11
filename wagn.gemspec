#lib = File.expand_path('../lib', __FILE__)
#$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
#require 'wagn/version'

Gem::Specification.new do |s|
  s.name          = 'wagn'
  s.version       = '1.12.5'
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason"]
  s.email         = ['info@wagn.org']
                  
#  s.date          = '2013-12-20'
  s.summary       = "Wagn: team-driven websites"
  s.description   = "Create dynamic web systems with wiki-inspired building blocks."
  s.homepage      = 'http://wagn.org'
  s.license       = 'GPL'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  [
    
    [ 'rails',        '~> 3.2.16' ],
    [ 'smartname',    '0.2.3'     ],  #, :path=>'~/dev/smartname/main'
    
    [ 'htmlentities', '~> 4.3'    ],
    [ 'uuid',         '~> 2.3'    ],
    [ 'paperclip',    '~> 2.8'    ],
    [ 'rmagick',      '~> 2.13'   ],
    [ 'recaptcha',    '~> 0.3'    ],
                                  
    [ 'xmlscan',      '~> 0.3'    ],
    [ 'rubyzip',      '~> 1.0'    ], # only required in module.  should be separated out.
    [ 'airbrake',     '~> 3.1'    ],
    [ 'coderay',      '~> 1.0'    ],
    [ 'sass',         '~> 3.2'    ]
    
  ].each do |dep|
    s.add_runtime_dependency *dep
  end
  
  
end