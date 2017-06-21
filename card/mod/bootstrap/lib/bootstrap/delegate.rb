class Bootstrap
  module Delegate
    def method_missing method_name, *args, &block
      # return super unless @context.respond_to? method_name
      if block_given?
        @context.send(method_name, *args, &block)
      else
        @context.send(method_name, *args)
      end
    end

    def respond_to_missing? method_name, _include_private=false
      @context.respond_to? method_name
    end
  end
end
