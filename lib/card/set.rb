# -*- encoding : utf-8 -*-

module Card::Set

  mattr_accessor :includable_modules, :traits, :current
  @@includable_modules = {}


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
      final_method = "#{event}_without_callbacks" #should be private?
      define_method final_method, &final

      define_method event do
        if event_applies? opts
          run_callbacks event do
            send final_method
          end
        end
      end
    end
    
    set_event_callbacks event, mod, opts
  end

  class << self
    
    def extended mod
      register_set mod
    end
    
    def register_set set_module
      self.current = {
        :module => set_module,
        :opts   => opts_from_module( set_module )
      }
      includable_modules[ set_module.name ] = set_module
    end

    def opts_from_module set_module
      if name_parts = set_module.to_s.split('::')[2..-1]
        pattern, anchor = name_parts.map { |part| part.underscore.to_sym }
        { pattern => anchor }
      else
        { }
      end
    end

    def set_module_from_name *args
      module_name_parts = args.length == 1 ? args[0].split('::') : args
      module_name_parts.inject Card::Set do |base, part|
        return if base.nil?
        part = part.camelize
        module_name = "#{base.name}::#{part}"
        if includable_modules.has_key?(module_name)
          includable_modules[module_name]
        else
          includable_modules[module_name] = base.const_get_or_set( part ) { Module.new }
        end
      end
    rescue NameError => e
      Rails.logger.warn "set_module_from_name error #{args.inspect}: #{e.inspect}"
      return nil if NameError ===e
    end
    
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
    includable_modules.each do |mod_name, mod|
      includable_modules.delete mod_name if mod.instance_methods.empty?
    end
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
            #FIXME -- need to unify this :if stuff with #event_applies? / :when handling
            # (though ideally the above would be obviated by a move to set-based callback handling)
        end
        Card.class_eval { set_callback object_method, kind, event, options }
      end
    end
  end

  def get_module
    mod = if self.ancestors.first == Card or self.current[:module].name =~ /^Card::Set::All::/
      Card
    else
      self.current[:module]
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

