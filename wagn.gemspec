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

end