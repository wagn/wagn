module CoreExtensions
  module Object
    def deep_clone
      case self
      when Fixnum, Bignum, Float, NilClass, FalseClass, TrueClass, Symbol
        klone = self
      when Hash
        klone = clone
        each { |k, v| klone[k] = v.deep_clone }
      when Array
        klone = clone
        klone.clear
        each { |v| klone << v.deep_clone }
      else
        klone = clone
      end
      klone.deep_clone_instance_variables
      klone
    end

    def send_unless method, *args, &_block
      (block_given? ? yield : self) || send(method, *args)
    end

    def send_if     method, *args, &_block
      (block_given? ? yield : self) && send(method, *args)
    end

    def to_name
      Card::Name.new self
    end

    def to_viewname
      Card::ViewName.new self
    end

    def deep_clone_instance_variables
      instance_variables.each do |v|
        instance_variable_set v, instance_variable_get(v).deep_clone
      end
    end
  end
end
