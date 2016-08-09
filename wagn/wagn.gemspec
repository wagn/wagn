# -*- encoding : utf-8 -*-

version = File.open(File.expand_path("../../card/VERSION", __FILE__)).read.chomp

Gem::Specification.new do |s|
  s.name          = "wagn"
  s.version       = version
  s.authors       = ["Ethan McCutchen", "Lewis Hoffman",
                     "Gerry Gleason", "Philipp Kühl"]
  s.email         = ["info@wagn.org"]

  #  s.date          = '2013-12-20'
  s.summary       = "structured wiki web platform"
  s.description   = "a wiki approach to stuctured data, dynamic interaction, "\
                    " and web design"
  s.homepage      = "http://wagn.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)

  s.bindir        = "bin"
  s.executables   = ["wagn"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.9.3"

  [
    ["rails", "~> 4.2"],
    ["card",   version]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
