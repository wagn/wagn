# -*- encoding : utf-8 -*-

module Card::Set

  mattr_accessor :modules_by_set, :traits
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

    mod = get_module
    Card.define_callbacks event

    mod.class_eval do
#      include ActiveSupport::Callbacks # may need this when callbacks are truly by module

      final_method = "#{event}_without_callbacks" #should be private?
      define_method final_method, &final

      define_method event do
        run_callbacks event do
          if event_applies? opts
            send final_method
          end
        end
      end
    end
    
    set_event_callbacks event, mod, opts
  end

  #not sure these shortcuts are worth it.
  def self.[]= set_name, value
    modules_by_set[prepend_base set_name] = value
  end

  def self.[] set_name
    modules_by_set[prepend_base set_name]
  end

  def self.register_set set_module
    Wagn::Loader.current_set_module = set_module
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


  #
  # ActiveCard support: accessing plus cards as attributes
  #


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
  end

  private

  def self.clean_empty_modules
    modules_by_set.each do |mod_name, mod|
      modules_by_set.delete mod_name if mod.instance_methods.empty?
    end
  end
  
  def self.prepend_base set_name
    set_name =~ /^Card::Set::/ ? set_name : 'Card::Set::' + set_name
  end

  def set_event_callbacks event, mod, opts
    [:before, :after, :around].each do |kind|
      if object_method = opts[kind]
        options = {:prepend=>true } 
        if mod != Card
          parts = mod.name.split '::'
          set_class_key, anchor_or_placeholder = parts[-2].underscore.to_sym, parts[-1].underscore
          set_key = Card.method_key( set_class_key => anchor_or_placeholder )
          options.merge!( { :if => proc do |c| c.method_keys.member? set_key end } )           
        end
        Card.class_eval { set_callback object_method, kind, event, options }
      end
    end
  end

  def get_module
    mod = self.ancestors.first
    mod_name = mod.name || Wagn::Loader.current_set_name
    
    case
    when mod == Card                           ; Card
    when mod_name =~ /^Card::Set::All::/       ; Card
    when csm = Wagn::Loader.current_set_module ; csm
    else
      # needed for explicit loading
      Card::Set[mod.name]= mod
      mod
    end
  end

  def get_traits mod
    Card::Set.traits ||= {}
    Card::Set.traits[mod] or Card::Set.traits[mod] = {}
  end

  def add_traits args, options
    mod  = get_module
    raise "Can't define card traits on all set" if mod == Card
    mod_traits = get_traits mod
    
    new_opts = options[:type] ? {:type=>options[:type]} : {}
    new_opts.merge!( {:content => options[:default]} ) if options[:default]
    
    args.each do |trait|   
      define_trait_card trait, new_opts
      define_trait_reader trait if options[:reader]
      define_trait_writer trait if options[:writer]

      mod_traits[trait.to_sym] = options
    end
  end
  
  def define_trait_card trait, opts
    define_method "#{trait}_card" do
      trait_var "@#{trait}_card" do
        fetch :trait=>trait.to_sym, :new=>opts
      end
    end
  end
  
  def define_trait_reader trait
    define_method trait do
      trait_var "@#{trait}" do
        send( "#{trait}_card" ).content
      end
    end
  end

  def define_trait_writer trait
    define_method "#{trait}=" do |value|
      card = send "#{trait}_card"
      self.cards ||= {}
      self.cards[card.name] = {:type_id => card.type_id, :content=>value }
      instance_variable_set "@#{trait}", value
    end
  end

end

