# -*- encoding : utf-8 -*-

module Wagn

  include Wagn::Exceptions

  module Loader
    MODS = begin
      builtins = [ 'core', 'standard' ].map { |mod| "#{Wagn.gem_root}/mods/#{mod}" }
      addons = Wagn::Conf[:mod_dirs].split( /,\s*/ ).map do |dirname|
        if Dir.exists? dirname
          Dir.entries( dirname ).sort.map do |filename|
            if filename !~ /^\./
              "#{dirname}/#{filename}"
            end
          end
        end
      end.flatten.compact
      builtins + addons
    end

    def load_set_patterns
      MODS.each do |mod|
        dirname = "#{mod}/set_patterns"
        if Dir.exists? dirname
          Dir.entries( dirname ).sort.each do |filename|
            if m = filename.match( /^(\d+_)?([^\.]*).rb/) and key = m[2]
              mod = Module.new
              filename = [ dirname, filename ] * '/'
              mod.class_eval { mattr_accessor :options }
              mod.class_eval File.read( filename ), filename, 1

              klass = Card::SetPattern.const_set "#{key.camelize}Pattern", Class.new( Card::SetPattern )
              klass.extend mod
              klass.register key, (mod.options || {})

            end
          end
        end
      end
    end

    def load_formats
      #cheating on load issues now by putting all inherited-from formats in core mod.
      MODS.each do |mod|
        load_dir File.expand_path( "#{mod}/formats/*.rb", __FILE__ )
      end
    end

    def load_chunks      
      MODS.each do |mod|
        load_dir File.expand_path( "#{mod}/chunks/*.rb", __FILE__ )
      end
    end

    def load_sets
      MODS.each do |mod|
        if File.directory? mod
          load_implicit_sets "#{mod}/sets"
        else
          next unless mod =~ /\.rb$/
          require_dependency mod
        end
        Card::Set.process_base_modules #must do this here because core sets must be processed into Card class before loading standard sets
      end
      
      Card::Set.process_base_modules
      Card::Set.clean_empty_modules
            
      Card::Set.register_set Card # reset so events in card.rb will be defined on card itself  (temporary?)
    end


    def load_implicit_sets basedir

      Card.set_patterns.reverse.map(&:key).each do |set_pattern|

        next if set_pattern =~ /^\./
        dirname = [basedir, set_pattern] * '/'
        next unless File.exists?( dirname )

        #FIXME support multiple anchors!
        Dir.entries( dirname ).sort.each do |anchor_filename|
          next if anchor_filename =~ /^\./
          anchor = anchor_filename.gsub /\.rb$/, ''

          set_module = Card::Set.set_module_from_name( set_pattern, anchor )
          filename = [dirname, anchor_filename] * '/'
          
          set_module.extend Card::Set
          set_module.class_eval File.read( filename ), filename, 1
        end    
      end
    end


    def self.load_layouts
      hash = {}
      MODS.each do |mod|
        dirname = "#{mod}/layouts"
        next unless File.exists? dirname
        Dir.foreach( dirname ) do |filename|
          next if filename =~ /^\./
          hash[ filename.gsub /\.html$/, '' ] = File.read( [dirname, filename] * '/' )
        end
      end
      hash
    end

    private



    def load_dir dir
      Dir[dir].sort.each do |file|
        begin
#          puts Benchmark.measure("from #load_dir: rd: #{file}") {
          require_dependency file
#          }.format("%n: %t %r")
        rescue Exception=>e
          Rails.logger.info "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
          raise e
        end
      end
    end

  end
end
