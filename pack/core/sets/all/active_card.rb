# -*- encoding : utf-8 -*-

mattr_accessor :traits

module ClassMethods
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
    Cardlib::ActiveCard.traits ||= {}
    mod_traits = Cardlib::ActiveCard.traits[Wagn::Set.current_set_module]
    if mod_traits.nil?
      #warn "active card #{Wagn::Set.current_set_module}"
      mod_traits = Cardlib::ActiveCard.traits[Wagn::Set.current_set_module] = {}
      #Wagn::Set.module_for_current.send :include, ActiveModel::Validations
      #Wagn::Set.module_for_current.send :validates_with, RightValidator
    end
    #warn "card_trait #{args.inspect}, #{options.inspect}"
    args.each do |trait|
      trait = trait.to_sym
      #warn "second definition of #{trait} at: #{caller[0]}" if mod_traits[trait]
      if options[:reader]
        module_for_current.class_eval { define_method trait do instance_variable_get "@#{trait}" end }
      end
      if options[:writer]
        module_for_current.class_eval { define_method "#{trait}=" do |value| instance_variable_set "@#{trait}", value end }
      end
      mod_traits[trait.to_sym] = options
    end
  end
end
