DECKO_RAILS_GEM_ROOT = File.expand_path('../../..', __FILE__)

module Decko
  module Rails
    class << self
      def root
        ::Rails.root
      end

      def gem_root
        DECKO_RAILS_GEM_ROOT
      end
    end
  end
end