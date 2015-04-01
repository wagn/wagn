# -*- encoding : utf-8 -*-

version = File.open(File.expand_path( '../../card/VERSION', __FILE__ )).read.chomp

Gem::Specification.new do |s|
  s.name          = 'wagn'
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason", "Philipp Kühl"]
  s.email         = ['info@wagn.org']
                  
#  s.date          = '2013-12-20'
  s.summary       = "structured wiki web platform"
  s.description   = "a wiki approach to stuctured data, dynamic interaction, and web design"
  s.homepage      = 'http://wagn.org'
  s.license       = 'GPL'

  s.files         = `git ls-files`.split($/)
  
  s.bindir        = 'bin'
  s.executables   = [ 'wagn' ]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.8.7'

  [
    [ 'rails', '3.2.16'  ],
    [ 'card',   version  ]
  ].each do |dep|
    s.add_runtime_dependency *dep
  end
  
end
