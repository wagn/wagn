require "pathname"

module Wagn
  module ScriptWagnLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) + RbConfig::CONFIG["EXEEXT"]
    SCRIPT_WAGN = File.join("script", "wagn")

    def self.exec_script_wagn!
      cwd = Dir.pwd
      return unless in_wagn_application? || in_wagn_application_subdirectory?
      exec RUBY, SCRIPT_WAGN, *ARGV if in_wagn_application?
      Dir.chdir("..") do
        # Recurse in a chdir block: if the search fails we want to be sure
        # the application is generated in the original working directory.
        exec_script_wagn! unless cwd == Dir.pwd
      end
    rescue SystemCallError
      # could not chdir, no problem just return
    end

    def self.in_wagn_application?
      File.exist?(SCRIPT_WAGN)
    end

    def self.in_wagn_application_subdirectory? path=Pathname.new(Dir.pwd)
      File.exist?(File.join(path, SCRIPT_WAGN)) || !path.root? && in_wagn_application_subdirectory?(path.parent)
    end
  end
end
