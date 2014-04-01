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
        prepare_tmp_dir 'tmp/set_patterns'
        mod_dirs.each do |mod|
          dirname = "#{mod}/set_patterns"
          if Dir.exists? dirname
            Dir.entries( dirname ).sort.each do |filename|
              if m = filename.match( /^(\d+_)?([^\.]*).rb/) and key = m[2]
                filename = [ dirname, filename ] * '/'
                tmp_file = SetPattern.write_tmp_file key, filename
                require_dependency tmp_file
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
        prepare_tmp_dir 'tmp/sets'
        mod_dirs.each do |mod|
          if File.directory? mod
            load_implicit_sets "#{mod}/sets"
          else
            next unless mod =~ /\.rb$/
            require_dependency mod
          end
          Set.process_base_modules #must do this here because core sets must be processed into Card class before loading standard sets
        end      
        Set.clean_empty_modules
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

            filename = [dirname, anchor_filename] * '/'
            tmp_file = Set.write_tmp_file set_pattern, anchor, filename
            require_dependency tmp_file
          end
            
        end
      end
      
      def prepare_tmp_dir path
        unless Rails.env.production? and Card.cache.read("TMPDIR-#{path}")
          p = Wagn.paths[ path ]
          if p.existent.first
            FileUtils.rm_rf p.first, :secure=>true
          end
          Dir.mkdir p.first
          Card.cache.write("TMPDIR-#{path}", true)
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
