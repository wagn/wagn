class Card::Log::Performance
  module BigBrother

    def watch_method method_name, method_type=:all, options={}
      Card::Log::Performance.enable_method method_name
      if !SPECIAL_METHODS.include? method_name
        if method_type == :all || method_type == :singleton
          add_singleton_logging method_name, options
        end
        if method_type == :all || method_type == :instance
          add_instance_logging method_name, options
        end
      end
    end

    def watch_instance_method *names
      names.each do |name|
        watch_method name, :instance
      end
    end

    def watch_singleton_method *names
      names.each do |name|
        watch_method name, :singleton
      end
    end

    def watch_all_instance_methods
      watch_instance_method *instance_methods
    end

    def watch_all_singleton_methods
      fragile_methods = [:default_scope, :default_scopes, :default_scopes=]  # if I touch these methods ActiveRecord breaks
      watch_singleton_method *(singleton_methods - fragile_methods)
    end

    def watch_all_methods
      watch_all_instance_methods
      watch_all_singleton_methods
    end

    private

    def add_singleton_logging method_name, options
      return unless singleton_class.method_defined? method_name
      m = method(method_name)
      add_logging method_name, :define_singleton_method, options do |bind_object, args, &block|
        m.call(*args, &block)
      end
    end

    def add_instance_logging  method_name, options
      return unless method_defined? method_name
      m = instance_method(method_name)
      add_logging method_name, :define_method, options do  |bind_object, args, &block|
        m.bind(bind_object).(*args, &block)
      end
    end

    def add_logging method_name, define_method, options, &bind_block
      send(define_method, method_name) do |*args, &block|
        #puts "#{method name } logged"
        Rails.logger.error "#{method_name} logged"
        log_args = {}
        options.each do |key,value|
          log_args[key] = case value
            when Integer then args[value-1]
            when Range   then args[value]
            when Symbol  then eval(value.to_s)
            when Proc    then value.call(self)
            else              value
            end
        end
        Card::Log::Performance.with_timer(method_name, log_args) do
          bind_block.call(self, args, &block)
        end
      end
    end

    def log_options_variable_name method_name, define_method
      "@_#{self.class.name}_#{method_name.hash.to_s.sub(/^-/,'_')}_#{define_method}_logging_options".to_sym
    end

  end
end
