module Wagn::Pack
  mattr_accessor :dirs

  class << self
    def dirs() @@dirs ||= [] end

    def dir(newdir)
      dirs << newdir
      #STDERR << "dir[#{dirs.inspect}]\n"
      @@dirs
    end

    def load_all 
      #Rails.logger.debug "load_all available_modules = #{@@dirs.inspect}\n"
      dirs.each do |dir|
        Dir[dir].each do |file|
          begin
            require_dependency file
          rescue Exception=>e
            detail = e.backtrace.join("\n")
            raise "Error loading #{file} #{e.message}\n#{detail}"
          end
        end
      end
    end
  end
end

