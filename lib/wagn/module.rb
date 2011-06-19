require 'card'

module Wagn
  class Module
    cattr_accessor :dirs

    class << self
      def dirs() @@dirs ||= [] end
      def dir(newdir)
        dirs << newdir
        STDERR << "dir[#{dirs.inspect}]\n"
        @@dirs
      end

      def load_all 
        #STDERR << "available_modules = #{@@dirs.inspect}\n"
        if dirs.empty?
          #STDERR << "No mods registered: #{Kernel.caller*"\n"}"
        end
        dirs.each do |dir|
          #STDERR << "Mods: #{Dir[dir].inspect}\n"
          Dir[dir].each do |file|
            begin
              #STDERR << "loading mods #{file}\n"
              require_dependency file  #"#{RAILS_ROOT}/modules/#{module_name}"
            rescue Exception=>e
              detail = e.backtrace.join("\n")
              raise "Error loading #{file} #{e.message}\n#{detail}"
            end
          end
        end
      end
    end
  end
end

