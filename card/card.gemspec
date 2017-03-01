# -*- encoding : utf-8 -*-

Gem::Specification.new do |s|
  s.name = "card"
  s.version = File.open(File.expand_path("../VERSION", __FILE__)).read.chomp
  s.authors =
    ["Ethan McCutchen", "Lewis Hoffman", "Gerry Gleason", "Philipp Kühl"]
  s.email = ["info@wagn.org"]

  s.summary       = "a surprisingly simple content nesting engine"
  s.description   =
    "Cards are wiki-inspired data atoms." \
    '"Cardists" use links, nests, types, patterned names, queries, views, ' \
    "events, and rules to create rich structures."
  s.homepage      = "http://wagn.org"
  s.licenses      = ["GPL-2.0", "GPL-3.0"]

  s.files         = `git ls-files`.split $INPUT_RECORD_SEPARATOR

  # add submodule files (seed data)
  morepaths = `git submodule --quiet foreach pwd`.split $OUTPUT_RECORD_SEPARATOR
  morepaths.each do |submod_path|
    gem_root = File.expand_path File.dirname(__FILE__)
    relative_submod_path = submod_path.gsub "#{gem_root}/", ""
    Dir.chdir(submod_path) do
      morefiles = `git ls-files`.split $OUTPUT_RECORD_SEPARATOR
      s.files += morefiles.map do |filename|
        "#{relative_submod_path}/#{filename}"
      end
    end
  end

  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.0"

  [
    ["smartname",                  "0.5.1"],
    ["uuid",                       "~> 2.3"],
    ["carrierwave",                "1.0.0"],
    ["htmlentities",               "~> 4.3"],
    ["mini_magick",                "~> 4.2"],
    # recaptcha 0.4.0 is last version that doesn't require ruby 2.0
    ["recaptcha",                  "~> 0.4.0"],
    ["coderay",                    "~> 1.0"],
    ["sass",                       "~> 3.2"],
    ["coffee-script",              "~> 2.2"],
    ["uglifier",                   "~> 3.0"],
    ["nokogiri",                   "~> 1.6.8"], # 1.7 needs ruby 2.1
    ["haml",                       "~> 4.0"],
    ["kaminari",                   "~> 0.16"],
    ["bootstrap-kaminari-views",   "~> 0"],
    ["diff-lcs",                   "~> 1.2"],
    # mime-types can be removed if we drop support for ruby 1.9.3
    # mime-types 3.0 uses mime-types-data which isn't compatible with 1.9.3
    ["mime-types",                 "2.99.1"]
  ].each do |dep|
    s.add_runtime_dependency(*dep)
  end
end
