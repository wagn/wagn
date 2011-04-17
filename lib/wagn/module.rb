require_dependency 'renderer'
module Wagn
  class Module
    class << self
      def load_all 
        #puts "available_modules = #{Wagn::Config.config.inspect} #{Wagn::Config.config.available_modules.inspect}"
        Wagn::Config.config.available_modules.each do |file|
          module_name = file.gsub(/.*\/([^\/]*)$/, '\1')
          begin
            require_dependency file  #"#{RAILS_ROOT}/modules/#{module_name}"
          rescue Exception=>e
            detail = e.backtrace.join("\n")
            raise "Error loading modules/#{module_name}: #{e.message}\n#{detail}"
          end
        end
      end
    end
  end
end

