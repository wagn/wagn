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
          generate_set_pattern_tmp_files
        end
        load_dir "#{Card.paths['tmp/set_pattern'].first}/*.rb"
      end

      def generate_set_pattern_tmp_files
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
        generate_tmp_set_modules
        load_tmp_set_modules
        Set.process_base_modules
        Set.clean_empty_modules
      end


      def generate_tmp_set_modules
        if prepare_tmp_dir 'tmp/set'
          seq = 1
          mod_dirs.each do |mod_dir|
            mod_tmp_dir = make_set_module_tmp_dir mod_dir, seq
            Dir.glob("#{mod_dir}/set/**/*.rb").each do |abs_filename|
              rel_filename = abs_filename.gsub "#{mod_dir}/set/", ''
              tmp_filename = "#{mod_tmp_dir}/#{rel_filename}"
              Set.write_tmp_file abs_filename, tmp_filename, rel_filename
            end
            seq = seq + 1
          end
        end
      end


      def load_tmp_set_modules
        patterns = Card.set_patterns.reverse.map(&:pattern_code).unshift 'abstract'
        Dir.glob( "#{Card.paths['tmp/set'].first}/*" ).sort.each do |tmp_mod|
          patterns.each do |pattern|
            pattern_dir = "#{tmp_mod}/#{pattern}"
            if Dir.exists? pattern_dir
              load_dir "#{pattern_dir}/**/*.rb"
            end
          end
        end
      end

      def make_set_module_tmp_dir mod_dir, seq
        modname = mod_dir.match(/[^\/]+$/)[0]
        mod_tmp_dir = "#{Card.paths['tmp/set'].first}/mod#{"%03d" % seq}-#{modname}"
        Dir.mkdir mod_tmp_dir
        mod_tmp_dir
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

