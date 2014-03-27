# -*- encoding : utf-8 -*-

require_dependency 'wagn/exceptions'

class Card
  module Loader
    
    class << self
      def load_mods
        load_set_patterns
        load_formats
        load_sets
      end
      
      def load_chunks
        mod_dirs.each do |mod|
          load_dir "#{mod}/chunks/*.rb"
        end
      end
            
      def load_layouts
        mod_dirs.inject({}) do |hash, mod|
          dirname = "#{mod}/layouts"
          if File.exists? dirname
            Dir.foreach( dirname ) do |filename|
              next if filename =~ /^\./
              hash[ filename.gsub /\.html$/, '' ] = File.read( [dirname, filename] * '/' )
            end
          end
          hash
        end
      end

      private
    
      def mod_dirs
        @@mod_dirs ||= begin
          (Wagn.paths['gem-mods'].existent + Wagn.paths['local-mods'].existent).map do |dirname|
            Dir.entries( dirname ).sort.map do |filename|
              "#{dirname}/#{filename}" if filename !~ /^\./
            end
          end.flatten.compact
        end
      end

      def load_set_patterns
        mod_dirs.each do |mod|
          dirname = "#{mod}/set_patterns"
          if Dir.exists? dirname
            Dir.entries( dirname ).sort.each do |filename|
              if m = filename.match( /^(\d+_)?([^\.]*).rb/) and key = m[2]
                mod = Module.new
                filename = [ dirname, filename ] * '/'
                mod.class_eval { mattr_accessor :options }
                mod.class_eval File.read( filename ), filename, 1

                klass = SetPattern.const_set "#{key.camelize}Pattern", Class.new( Card::SetPattern )
                klass.extend mod
                klass.register key, (mod.options || {})

              end
            end
          end
        end
      end

      def load_formats
        #cheating on load issues now by putting all inherited-from formats in core mod.
        mod_dirs.each do |mod|
          load_dir "#{mod}/formats/*.rb"
        end
      end

      def load_sets
        mod_dirs.each do |mod|
          if File.directory? mod
            load_implicit_sets "#{mod}/sets"
          else
            next unless mod =~ /\.rb$/
            require_dependency mod
          end
          Set.process_base_modules #must do this here because core sets must be processed into Card class before loading standard sets
        end
      
        #Set.process_base_modules #why is this run again?
        Set.clean_empty_modules
        #Set.register_set Card # reset so events in card.rb will be defined on card itself  (temporary?)
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

#            set_module = Set.set_module_from_name( set_pattern, anchor )
            filename = [dirname, anchor_filename] * '/'
            tmp_set_file = Set.write_tmp_set_file set_pattern, anchor, filename
            require_dependency tmp_set_file
          
#            set_module.extend Set
#            set_module.class_eval File.read( filename ), filename, 1
            #FIXME - this #class_eval call causes several issues:
            #  1. confusing backtraces
            #  2. failure to show up in Simplecov (built-in ruby Coverage tracking is triggered by require or load)
            #  3. others?
            # proposed fix: generate tmp files for set files and then require them (or, more precisely, use require_dependency on them)
            # would ultimately be preferable not to have to have to regenerate them every time but support a mode where gem mod set files
            # are required (without regeneration) but mods in instances are loaded dynamically
          end
            
        end
      end
      

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
end
