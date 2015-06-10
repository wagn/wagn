# -*- encoding : utf-8 -*-

require_dependency 'card/set'
require_dependency 'card/set_pattern'

class Card
  class << self
    def config
      Cardio.config
    end

    def paths
      Cardio.paths
    end
  end

  module Loader

    class << self
      def load_mods
        load_set_patterns
        load_formats
        load_sets
        
        if Wagn.config.performance_logger
          Card::Log::Performance.load_config Wagn.config.performance_logger
        end
      end

      def load_chunks
        mod_dirs.each do |mod|
          load_dir "#{mod}/chunk/*.rb"
        end
      end

      def load_layouts
        mod_dirs.inject({}) do |hash, mod|
          dirname = "#{mod}/layout"
          if File.exists? dirname
            Dir.foreach( dirname ) do |filename|
              next if filename =~ /^\./
              hash[ filename.gsub /\.html$/, '' ] = File.read( [dirname, filename] * '/' )
            end
          end
          hash
        end
      end

      def mod_dirs
        @@mod_dirs ||= begin
          if Card.paths['local-mod']
            Card.paths['mod'] << Card.paths['local-mod']
            Rails.logger.warn 'DEPRECATION WARNING: Append to paths[\'mod\'] vs. local-mod for configuring location of local (deck) modules.'
          end

          Card.paths['mod'].existent.map do |dirname|
            Dir.entries( dirname ).sort.map do |filename|
              "#{dirname}/#{filename}" if filename !~ /^\./
            end.compact
          end.flatten.compact
        end
      end

      private

      def load_set_patterns
        if rewrite_tmp_files?
          load_set_patterns_from_source
        end
        load_dir "#{Card.paths['tmp/set_pattern'].first}/*.rb"
      end

      def load_set_patterns_from_source
        prepare_tmp_dir 'tmp/set_pattern'
        seq = 100
        mod_dirs.each do |mod|
          dirname = "#{mod}/set_pattern"
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
          load_dir "#{mod}/format/*.rb"
        end
      end

      def load_sets
        prepare_tmp_dir 'tmp/set'
        load_sets_by_pattern
        Set.process_base_modules
        Set.clean_empty_modules
      end


      def load_sets_by_pattern
        Card.set_patterns.reverse.map(&:pattern_code).each do |set_pattern|
          pattern_tmp_dir = "#{Card.paths['tmp/set'].first}/#{set_pattern}"
          if rewrite_tmp_files?
            Dir.mkdir pattern_tmp_dir
            load_implicit_sets_from_source set_pattern
          end
          if Dir.exists? pattern_tmp_dir
            load_dir "#{pattern_tmp_dir}/**/*.rb"
          end
        end
      end

      def load_implicit_sets_from_source set_pattern
        seq = 1000
        mod_dirs.each do |mod_dir|
          dirname = [mod_dir, 'set', set_pattern] * '/'
          next unless File.exists?( dirname )

          old_pwd = Dir.pwd
          Dir.chdir dirname
          Dir.glob( "**/*.rb" ).sort.each do |anchor_path|
            path_parts = anchor_path.gsub(/\.rb/,'').split(File::SEPARATOR)
            filename = File.join dirname, anchor_path
            Set.write_tmp_file set_pattern, path_parts, filename, seq
            seq = seq + 1
          end
          Dir.chdir old_pwd
        end
      end

      def prepare_tmp_dir path
        if rewrite_tmp_files?
          p = Card.paths[ path ]
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
          @@rewrite = !( Rails.env.production? and Card.paths['tmp/set'].existent.first )
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

