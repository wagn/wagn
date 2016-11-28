class Bootstrap
  module ComponentLoader
    def include_component class_name
      define_method class_name.underscore do |*args, &block|
        component_const = self.class.const_get("::Bootstrap::Component::#{class_name}")
        component_const.render(self, *args, &block)
      end
    end

    def load_components
      path = File.expand_path "../component/*.rb", __FILE__
      Dir.glob(path).each do |file|
        require file
        class_name = File.basename(file, ".rb").camelcase
        include_component class_name
      end
    end
  end
end


