module CoreExtensions
  module Module
    RUBY_VERSION_18 = !!(RUBY_VERSION =~ /^1\.8/)

    def const_get_if_defined const
      args = RUBY_VERSION_18 ? [const] : [const, false]
      const_get(*args) if const_defined?(*args)
    end

    def const_get_or_set const
      const_get_if_defined(const) || const_set(const, yield)
    end

    def add_set_modules list
      Array(list).each do |mod|
        include mod if mod.instance_methods.any?
        if (class_methods = mod.const_get_if_defined(:ClassMethods))
          extend class_methods
        end
      end
    end
  end
end
