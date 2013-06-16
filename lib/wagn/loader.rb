# -*- encoding : utf-8 -*-

module Wagn

  include Wagn::Exceptions

  module Loader
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"
    SETS      = "#{Rails.root}/wagn-app/sets"
    # load order for specific libs (from Cardlib) to make sure the load first
    CARDLIBS  = %w{ attach attribute_tracking collection fetch pattern permissions references rules
                    templating tracked_attributes utils }

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

      Card.set_patterns.reverse.map(&:key).each do |set_pattern|

        next if set_pattern =~ /^\./
        dirname = "#{SETS}/#{set_pattern}"
        next unless File.exists?( dirname )
        set_pattern_const = get_set_pattern_constant set_pattern

        if set_pattern == 'all'
          Dir.entries( dirname ).sort.inject(CARDLIBS) do |libs, anchor|
            anchor.gsub!( /\.rb$/, '' )
            libs << anchor unless anchor =~ /^\./ or libs.member?( anchor )
            libs
          end
        else
          Dir.entries( dirname ).sort.map do |anchor| anchor.gsub( /\.rb$/, '' ) end
        end.each do |anchor|
          next if anchor =~ /^\./
          set_module = set_pattern_const.const_set anchor.camelize, Module.new
          Wagn::Set.current_set_opts = { set_pattern.to_sym => anchor.to_sym }
          Wagn::Set.current_set_module = set_module.name

          filename = "#{dirname}/#{anchor}.rb"
          set_module.extend Wagn::Set
          set_module.class_eval File.read( filename ), filename, 1

          args = Card::RUBY18 ? [ :Model ] : [ :Model, false ]
          if set_pattern == 'all' and set_module.const_defined? *args
            include_all_model set_module.const_get( *args )
          end

          args = Card::RUBY18 ? [ :Renderer ] : [ :Renderer, false ]
          if set_module.const_defined? *args
            Wagn::Renderer.send :include, set_module.const_get( *args )
          end
        end



      end
    ensure
      Wagn::Set.current_set_opts = Wagn::Set.current_set_module = nil
    end

    private

    def include_all_model set_model
      Card.send :include, set_model
      args = Card::RUBY18 ? [ :ClassMethods ] : [ :ClassMethods, false ]
      Card.send( :extend, set_model.const_get( *args ) ) if set_model.const_defined?( *args )
    end

    def get_set_pattern_constant set_pattern
      set_pattern_mod_name = set_pattern.camelize

      args = Card::RUBY18 ? [ set_pattern_mod_name ] : [ set_pattern_mod_name, false ]
      if Wagn::Set.const_defined? *args
        Wagn::Set.const_get *args
      else
        Wagn::Set.const_set set_pattern_mod_name, Module.new
      end
    end

    def load_dir dir
      Dir[dir].sort.each do |file|
        begin
          require_dependency file
        rescue Exception=>e
          Rails.logger.debug "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
          raise e
        end
      end
    end

  end
end
