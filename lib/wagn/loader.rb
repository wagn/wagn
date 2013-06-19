# -*- encoding : utf-8 -*-

module Wagn

  include Wagn::Exceptions

  module Loader
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"
    CORESETS  = "#{Rails.root}/wagn-app/core-sets"
    SETS      = "#{Rails.root}/wagn-app/sets"

    def load_renderers
      load_dir File.expand_path( RENDERERS, __FILE__ )
    end

    def load_sets
      load_standard_sets "#{CORESETS}"
      load_standard_sets "#{SETS}"

      Wagn::Conf[:pack_dirs].split( /,\s*/ ).each do |dirname|
        load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
      end
    end


    def load_standard_sets basedir

      Card.set_patterns.reverse.map(&:key).each do |set_pattern|

        next if set_pattern =~ /^\./
        dirname = [basedir, set_pattern] * '/'
        next unless File.exists?( dirname )
        set_pattern_const = get_set_pattern_constant set_pattern

        Dir.entries( dirname ).sort.each do |anchor_filename|
          next if anchor_filename =~ /^\./
          anchor = anchor_filename.gsub /\.rb$/, ''
          #FIXME: this doesn't support re-openning of the module from multiple calls to load_standard_sets
          acamel = anchor.camelize
          args = Card::RUBY18 ? [ acamel ] : [ acamel, false ]
          if set_pattern_const.const_defined?( *args )
            set_module = set_pattern_const.const_get( *args )
          else
            set_module = set_pattern_const.const_set( acamel, Module.new )
            set_module.extend Card::Set
          end
          
          Card::Set.current_set_opts = { set_pattern.to_sym => anchor.to_sym }
          Card::Set.current_set_module = set_module.name
          
          filename = [dirname, anchor_filename] * '/'
          set_module.class_eval File.read( filename ), filename, 1

          if set_pattern == 'all'
            include_all_model set_module
          end
        end    
      end
    ensure
      Card::Set.current_set_opts = Card::Set.current_set_module = nil
    end

    private

    def include_all_model set_module
      Card.send :include, set_module if set_module.instance_methods.any?

      args = Card::RUBY18 ? [ :ClassMethods ] : [ :ClassMethods, false ]
      Card.send( :extend, set_module.const_get( *args ) ) if set_module.const_defined?( *args )
    end

    def get_set_pattern_constant set_pattern
      set_pattern_mod_name = set_pattern.camelize

      args = Card::RUBY18 ? [ set_pattern_mod_name ] : [ set_pattern_mod_name, false ]
      if Card::Set.const_defined? *args
        Card::Set.const_get *args
      else
        Card::Set.const_set set_pattern_mod_name, Module.new
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
