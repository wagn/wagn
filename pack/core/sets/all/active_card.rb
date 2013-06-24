# -*- encoding : utf-8 -*-


module ClassMethods
  attr_accessor :traits

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

private

  def add_traits args, options
    Card.traits ||= {}
    mod_traits = Card.traits[Wagn::Loader.current_set_name]
    if mod_traits.nil?
      #warn "active card #{Wagn::Loader.current_set_name}"
      mod_traits = Card.traits[Wagn::Loader.current_set_name] = {}
    end
    #warn "card_trait #{args.inspect}, #{options.inspect}"
    args.each do |trait|
      trait_sym = trait.to_sym
      #warn "second definition of #{trait} at: #{caller[0]}" if mod_traits[trait]
=begin
      if options[:reader]
        Wagn::Loader.current_set_module.class_eval { define_method trait do instance_variable_get "@#{trait}" end }
      end
      if options[:writer]
        Wagn::Loader.current_set_module.class_eval { define_method "#{trait}=" do |value| instance_variable_set "@#{trait}", value end }
      end
=end
      mod_traits[trait_sym] = options
    end
  end

end
