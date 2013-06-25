# -*- encoding : utf-8 -*-

module Card::Set

  mattr_accessor :modules_by_set
  @@modules_by_set = {}


  # View definitions
  #
  #   When you declare:
  #     view :view_name, "<set>" do |args|
  #
  #   Methods are defined on the format
  #
  #   The external api with checks:
  #     render(:viewname, args)
  #
  #   Roughly equivalent to:
  #     render_viewname(args)
  #
  #   The internal call that skips the checks:
  #     _render_viewname(args)
  #
  #   Each of the above ultimately calls:
  #     _final(_set_key)_viewname(args)

  #
  # ~~~~~~~~~~  VIEW DEFINITION
  #

  def view *args, &block
    format do view *args, &block end
  end

  def format fmt=nil, &block
    if block_given?
      f = Card::Format
      format = fmt.nil? ? f : f.get_format(fmt)
      format.class_eval &block
    else
      fail "block required"
    end
  end


  def event event, opts={}, &final
    opts[:on] = [:create, :update ] if opts[:on] == :save

    Card.define_callbacks event

    mod = self.ancestors.first
    mod_name = mod.name || Wagn::Loader.current_set_name
    mod = if mod == Card || mod_name =~ /^Card::Set::All::/
        Card
      else
        Wagn::Loader.current_set_module
      end

    mod.class_eval do
      include ActiveSupport::Callbacks

      final_method = "#{event}_without_callbacks" #should be private?
      define_method final_method, &final

      define_method event do #|*a, &block|
        #Rails.logger.warn "running #{event} for #{name}, Meth: #{final_method}"
        run_callbacks event do
          action = self.instance_variable_get(:@action)
          if !opts[:on] or Array.wrap(opts[:on]).member? action
            send final_method #, :block=>block
          end
        end
      end
    end


    [:before, :after, :around].each do |kind|
      if object_method = opts[kind]
        options = {:prepend=>true } 
        if mod != Card
          parts = mod_name.split '::'
          set_class_key, anchor_or_placeholder = parts[-2].underscore.to_sym, parts[-1].underscore
          set_key = Card.method_key( set_class_key => anchor_or_placeholder )
          options.merge!( { :if => proc do |c| c.method_keys.member? set_key end } )           
        end
        Card.class_eval { set_callback object_method, kind, event, options }
      end
    end
  end


  def self.[]= set_name, value
    modules_by_set[prepend_base set_name] = value
  end

  def self.[] set_name
    modules_by_set[prepend_base set_name]
  end

  def self.register_set set_module
    Card::Set[set_module.name]= set_module
  end

  def self.set_module_from_name *args
    module_name_parts = args.length == 1 ? args[0].split('::') : args
    module_name_parts.inject Card::Set do |base, part|
      return if base.nil?
      part = part.camelize
      module_name = "#{base.name}::#{part}"
      if modules_by_set.has_key?(module_name)
        modules_by_set[module_name]
      else
        modules_by_set[module_name] = base.const_get_or_set( part ) { Module.new }
      end
    end
  rescue NameError => e
    Rails.logger.warn "set_module_from_name error #{args.inspect}: #{e.inspect}"
    return nil if NameError ===e
  end

  private

  def self.prepend_base set_name
    set_name =~ /^Card::Set::/ ? set_name : 'Card::Set::' + set_name
  end

  #
  # ActiveCard support: accessing plus cards as attributes
  #


  mattr_accessor :traits

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
    raise "Can't define card traits on all set" if Wagn::Loader.current_set_module == Card

    Card::Set.traits ||= {}
    mod_traits = Card::Set.traits[Wagn::Loader.current_set_module]
    if mod_traits.nil?
      #warn "active card #{Wagn::Loader.current_set_name}"
      mod_traits = Card::Set.traits[Wagn::Loader.current_set_module] = {}
    end
    #warn "card_trait #{args.inspect}, #{options.inspect}"
    args.each do |trait|
      trait_sym = trait.to_sym
      trait_card = "#{trait}_card".to_sym
      #warn "second definition of #{trait} at: #{caller[0]}" if mod_traits[trait]

      if options[:reader]
        Wagn::Loader.current_set_module.class_eval do
          define_method trait_card do
            new_opts = options[:type] ? {:type=>options[:type]} : {}
            new_opts.merge!( {:content => options[:default]} ) if options[:default]
            card = trait_var("@#{trait_card}") do fetch(:trait=>trait_sym, :new=>new_opts) end
          end
          define_method trait do
            send(trait_card).content
          end
        end
      end
      #warn "card_trait #{args.inspect}, #{options.inspect}"
      args.each do |trait|
        trait_sym = trait.to_sym
        trait_card = "#{trait}_card".to_sym
        #warn "second definition of #{trait} at: #{caller[0]}" if mod_traits[trait]
        if options[:reader]
          Wagn::Loader.current_set_module.class_eval do
            define_method trait_card do
              new_opts = options[:type] ? {:type=>options[:type]} : {}
              new_opts.merge!( {:content => options[:default]} ) if options[:default]
              card = trait_var("@#{trait_card}") do fetch(:trait=>trait_sym, :new=>new_opts) end
            end
            define_method trait do
              send(trait_card).content
            end
          end
        end
        if options[:writer]
          Wagn::Loader.current_set_module.class_eval do
            define_method "#{trait}=" do |value|
              card = send trait_card
              card.content = value
Rails.logger.warn "set #{trait} on #{inspect} tc:#{card.inspect} to #{value.inspect}"

              instance_variable_set "@#{trait}", value
            end
          end
        end
      end
      mod_traits[trait_sym] = options
    end
  end

  def self.clean_empty_modules
    modules_by_set.each do |mod_name, mod|
      modules_by_set.delete mod_name if mod.instance_methods.empty?
    end
  end
end

