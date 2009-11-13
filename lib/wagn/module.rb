module Wagn
  class Module
    class << self
      def load_all  
        Dir["#{RAILS_ROOT}/modules/*.rb"].sort.each do |file|
          module_name = file.gsub!(/.*\/([^\/]*)$/, '\1')
          begin
            require_dependency "#{RAILS_ROOT}/modules/#{module_name}"
          rescue Exception=>e
            raise "Error loading modules/#{module_name}: #{e.message}"
          end
        end
      end
    end
  end
end

