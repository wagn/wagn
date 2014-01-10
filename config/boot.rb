# -*- encoding : utf-8 -*-
require 'yaml'

module Wagn
  class Conf
    class << self
      WAGN_CONFIG_FILE = ENV['WAGN_CONFIG_FILE'] || File.expand_path('config/wagn.yml')
      
      def [] key
        @@config[key.to_sym]
      end
      
      def []= key, value
        @@config[key.to_sym] = value
      end     

      @@config = h = {}
      f = WAGN_CONFIG_FILE
      if File.exists?( f ) and y = YAML.load_file( f ) and Hash === y
        h.merge! y
      else
        abort "Wagn Config File (wagn.yml) not found: #{ WAGN_CONFIG_FILE }"
      end
      h.keys.each do |key|
        h[(key.to_sym rescue key) || key] = h.delete(key)
      end
    end
  end
end

ENV['RAILS_ENV'] ||= Wagn::Conf[:rails_env] || 'production'

require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path("Gemfile")


require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
