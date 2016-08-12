class Card
  module Loader
    class ModDirs < Array
      attr_reader :mods

      def initialize mod_paths
        @mods = []
        @paths = {}
        mod_paths = Array(mod_paths)
        mod_paths.each do |mp|
          @current_path = mp
          load_from_modfile || load_from_dir
        end
        super()
        @mods.each do |mod_name|
          self << @paths[mod_name]
        end
      end

      def mod mod_name
        @mods << mod_name
        # TODO: do something if two mods have the same name?
        @paths[mod_name] = File.join @current_path, mod_name
      end

      def each type=nil
        super() do |path|
          dirname = type ? File.join(path, type.to_s) : path
          next unless Dir.exist? dirname
          yield dirname
        end
      end

      def each_tmp type
        @mods.each do |mod|
          path = tmp_dir mod, type
          next unless Dir.exist? path
          yield path
        end
      end

      def each_with_tmp type=nil
        @mods.each do |mod|
          dirname = type ? File.join(@paths[mod], type.to_s) : @paths[mod]
          next unless Dir.exist? dirname
          yield dirname, tmp_dir(mod, type)
        end
      end

      private

      def load_from_modfile
        modfile_path = File.join @current_path, "Modfile"
        return unless File.exist? modfile_path
        eval File.read(modfile_path), binding
      end

      def load_from_dir
        Dir.entries(@current_path).sort.each do |filename|
          next if filename =~ /^\./
          mod filename
        end.compact
      end

      def tmp_dir modname, type
        index = @mods.index modname
        File.join Card.paths["tmp/#{type}"].first,
                  "mod#{'%03d' % (index + 1)}-#{modname}"
      end
    end
  end
end
