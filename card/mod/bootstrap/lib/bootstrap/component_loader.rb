class Bootstrap
  module ComponentLoader
    def load_components
      components.each do |component|
        require "component/#{component}"
        include_component component
      end
    end

    def include_component component
      component_class = to_const component.camelcase
      define_method component do |*args, &block|
        component_class.render self, *args, &block
      end
    end

    def components
      path = File.expand_path "../component/*.rb", __FILE__
      Dir.glob(path).map do |file|
        File.basename file, ".rb"
      end
    end

    def to_const name
      self.class.const_get "::Bootstrap::Component::#{name.camelcase}"
    end
  end
end


