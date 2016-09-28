
module Wagn
  WAGN_GEM_ROOT = File.expand_path("../..", __FILE__)

  class << self
    def root
      Rails.root
    end

    def application
      Rails.application
    end

    def config
      application.config
    end

    def paths
      application.paths
    end

    def gem_root
      WAGN_GEM_ROOT
    end

    def card_gem_root
      @card_gem_root ||= locate_gem "card"
    end

    private

    def locate_gem name
      spec = Bundler.load.specs.find { |s| s.name == name }
      unless spec
        raise GemNotFound, "Could not find gem '#{name}' in the current bundle."
      end
      return File.expand_path("../../../", __FILE__) if spec.name == "bundler"
      spec.full_gem_path
    end
  end
end
