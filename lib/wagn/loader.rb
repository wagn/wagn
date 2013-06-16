# -*- encoding : utf-8 -*-

module Wagn

  include Wagn::Exceptions

  module Loader
    CARDLIB   = "#{Rails.root}/lib/cardlib/*.rb"
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"
    SETS      = "#{Rails.root}/wagn-app/sets"

    def load_cardlib
      load_dir File.expand_path( CARDLIB, __FILE__ )
    end

    def load_renderers
      load_dir File.expand_path( RENDERERS, __FILE__ )
    end

    def load_sets
      load_standard_sets

      Wagn::Conf[:pack_dirs].split( /,\s*/ ).each do |dirname|
        load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
      end
    end


    def load_standard_sets
      # load additional sets (and keys) first
      Dir.glob( "#{SETS}/*_pattern.rb" ).sort.each do |file| load_file file end

      Card.set_patterns.reverse.map(&:key).each do |set_pattern|

        dirname = "#{SETS}/#{set_pattern}"
        next unless File.directory?( dirname )

        set_pattern_const = get_set_pattern_constant set_pattern

        Dir.entries( dirname ).sort.each do |anchor|

          next if anchor =~ /^\./
          filename = dirname + '/' + anchor
          anchor.gsub! /\.rb$/, ''
          Wagn::Set.current_set_opts = { set_pattern.to_sym => anchor.to_sym }
          Wagn::Set.current_set_module = "#{set_pattern_const.name}::#{anchor.camelize}"

          set_module = set_pattern_const.const_set anchor.camelize, ( Module.new do
            extend Wagn::Set
            class_eval File.read( filename ), filename, 1
          end )

          if set_pattern == 'all' and set_module.const_defined? :Model
            Card.send :include, set_module.const_get( :Model )
          end

          if set_module.const_defined? :Renderer
            Wagn::Renderer.send :include, set_module.const_get( :Renderer )
          end
        end

      end
    ensure
      Wagn::Set.current_set_opts = Wagn::Set.current_set_module = nil
    end

    private

    def get_set_pattern_constant set_pattern
      set_pattern_mod_name = set_pattern.camelize

      if Wagn::Set.const_defined? set_pattern_mod_name
        Wagn::Set.const_get set_pattern.camelize
      else
        Wagn::Set.const_set set_pattern.camelize, Module.new
      end
    end

    def load_file file
      #Rails.logger.debug "load_file #{file}"
      begin
        require_dependency file
      rescue Exception=>e
        Rails.logger.debug "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
        raise e
      end
    end

    def load_dir dir
      Dir[dir].sort.each do |file| load_file file end
    end

  end
end
