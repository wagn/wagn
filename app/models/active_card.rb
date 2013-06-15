class ActiveCard
  include ActiveModel::Validations
  validates_with RightValidator

  cattr_accessor :traits

  class << self

    def card_accessor *args
      options = args.extract_options!
      add_traits args, options.merge( :reader=>true, :writer=>true )
    end

    def card_reader *args
      options = args.extract_options!
      add_traits args, options.merge( :reader=>true )
    end

    def card_writer *args
      options = args.extract_options!
      add_traits args, options.merge( :writer=>true )
      options = args.extract_options!
    end

    def add_traits args, options
      warn "card_trait #{args.inspect}, #{options.inspect}"
      self.traits ||= {}
      args.each do |trait|
        self.traits[trait.to_sym] = options
      end
    end
  end

  def inspect
    "<#{self.class}:#{(self.class.traits||{}).keys.map {|iv| "#{iv}=#{instance_variable_get("@#{iv}")}" }*', '}>"
  end

  def method_missing method_id, *args
    method = method_id.to_s
    assign = method.chomp!("=")
    warn "mm #{method}, #{assign}, #{args.inspect}"
    if opts = self.class.traits[method.to_sym]
      if assign
        return instance_variable_set( "@#{method}", args[0] ) if opts[:writer]
      else
        return instance_variable_get( "@#{method}" ) if opts[:reader]
      end 
    end
    super method_id, *args
  end
end
