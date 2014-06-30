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
        if rewrite_tmp_files?
          load_set_patterns_from_source
        end
        load_dir "#{Wagn.paths['tmp/set_patterns'].first}/*.rb"
      end

      def load_set_patterns_from_source
        prepare_tmp_dir 'tmp/set_patterns'
        seq = 100
        mod_dirs.each do |mod|
          dirname = "#{mod}/set_patterns"
          if Dir.exists? dirname
            Dir.entries( dirname ).sort.each do |filename|
              if m = filename.match( /^(\d+_)?([^\.]*).rb/) and key = m[2]
                filename = [ dirname, filename ] * '/'
                SetPattern.write_tmp_file key, filename, seq
                seq = seq + 1
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
        load_sets_by_pattern
        Set.process_base_modules 
        Set.clean_empty_modules
      end


      def load_sets_by_pattern
        Card.set_patterns.reverse.map(&:pattern_code).each do |set_pattern|
          pattern_tmp_dir = "#{Wagn.paths['tmp/sets'].first}/#{set_pattern}"
          if rewrite_tmp_files?
            Dir.mkdir pattern_tmp_dir
            load_implicit_sets_from_source set_pattern
          end
          if Dir.exists? pattern_tmp_dir
            load_dir "#{pattern_tmp_dir}/*.rb"
          end
        end    
      end

      def load_implicit_sets_from_source set_pattern
        seq = 1000
        mod_dirs.each do |mod_dir|
          dirname = [mod_dir, 'sets', set_pattern] * '/'
          next unless File.exists?( dirname )

          #FIXME support multiple anchors!
          Dir.entries( dirname ).sort.each do |anchor_filename|
            next if anchor_filename =~ /^\./
            anchor = anchor_filename.gsub /\.rb$/, ''

            filename = [dirname, anchor_filename] * '/'
            Set.write_tmp_file set_pattern, anchor, filename, seq
            seq = seq + 1
          end
        end
      end

      
      
      def prepare_tmp_dir path
        if rewrite_tmp_files?
          p = Wagn.paths[ path ]
          if p.existent.first
            FileUtils.rm_rf p.first, :secure=>true
          end
          Dir.mkdir p.first
        end
      end
      
      def rewrite_tmp_files?
        if defined?( @@rewrite )
          @@rewrite
        else
          @@rewrite = !( Rails.env.production? and Wagn.paths['tmp/sets'].existent.first )
        end
      end

      def load_dir dir
        Dir[dir].sort.each do |file|
  #          puts Benchmark.measure("from #load_dir: rd: #{file}") {
          require_dependency file
  #          }.format("%n: %t %r")
        end
      end
    end
  end
end
