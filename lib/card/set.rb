# -*- encoding : utf-8 -*-

class Card
  module Set

    mattr_accessor :traits,
      :base_modules, :base_format_modules,
      :includable_modules, :includable_format_modules
    @@base_modules, @@base_format_modules = [], {}
    @@includable_modules, @@includable_format_modules= {}, {}
    
    
=begin
    A "Set" is a group of cards to which "Rules" may be applied.  Sets can be as specific as
    a single card, as general as all cards, or anywhere in between.

    Rules take two main forms: card rules and code rules.

    "Card rules" are defined in card content. These are generally configured via the web
    interface and are thus documented at http://wagn.org/rules.

    "Code rules" can be defined in a "set file" within any "Mod" (short for both "module" and
    "modification"). In accordance with Wagn's "MoVE" architecture, there are two main kinds of
    code rules you can create in a set file: Views, and Events.  Events are associated with the
    Card class, and Views are associated with a Format class.  You can also use set files to 
    add or override Card and/or Format methods directly.  The majority of Wagn code is contained
    in these files.
    
        (FIXME - define mod, add generator)

    Whenever you fetch or instantiate a card, it will automatically include all the
    set modules defined in set files associated with sets of which it is a member.  This 
    entails both simple model methods and "events", which are special methods explored
    in greater detail below.
    
    For example, say you have a Plaintext card named "Philipp+address", and you have set files
    for the following sets:
    
        * all cards
        * all Plaintext cards
        * all cards ending in +address
    
    When you run this:
    
        mycard = Card.fetch 'Philipp+address'
    
    ...then mycard will include the set modules associated with each of those sets in the above
    order.  (The order is determined by the set pattern; see lib/card/set_pattern.rb for more
    information about set_ptterns and mods/core/sets/all/fetch.rb for more about fetching.)

    Similarly, whenever a Format object is instantiated for a card, it includes all views
    associated with BOTH (a) sets of which the card is a member and (b) the current format or 
    its ancestors.  More on defining views below.

 
    In order to have a set file associated with "all cards ending in +address", you could create
    a file in mywagn/mods/mymod/sets/right/address.rb.  The recommended mechanism for doing so
    is running `wagn generate set modname set_pattern set_anchor`. In the current example, this
    would translate to `wagn generate set mymod right address`. Note that both the set_pattern 
    and the set_anchor must correspond to the codename of a card in the database to function
    correctly.

    
    When Wagn loads, it uses these files to autogenerate a tmp_file that uses this set file to
    createa Card::Set::Right::Address module which itself is extended with Card::Set. A set file
    is "just ruby" but is generally quite concise because Wagn uses its file location to 
    autogenerate ruby module names and then uses Card::Set module to provide additional API.


 View definitions

   When you declare:
     view :view_name do |args|
       #...your code here
     end

   Methods are defined on the format

   The external api with checks:
     render(:viewname, args)


=end

    module Format
      def view view, *args, &block
        view = view.to_name.key.to_sym
        if block_given?
          Card::Format.extract_class_vars view, args[0]
          define_method "_view_#{ view }", &block
        else
          opts = Hash===args[0] ? args.shift : nil
          alias_view view, args.shift, opts
        end
      end
      
      def alias_view alias_view, referent_view, opts
        if opts.blank? # alias to another view in the same set (or ancestors)
          define_method "_view_#{ alias_view }" do |*a|
            send "_view_#{ referent_view }", *a
          end
        else           # aliasing to a view in another set
          
          # FIXME - not implemented
          # need to call the instance method of the referent set module...
          # might try getting the unbound method like this: Card::Set::Type::PlainText::HtmlFormat.instance_method :_view_editor
          #... and then binding it to the current_format (however that works)
        end
      end     
    end

    def format format=nil, &block
      klass = Card::Format.format_class_name format
      set_format_mod = const_get_or_set klass do Module.new end
      Card::Set.register_set_format Card.const_get(klass), set_format_mod
      
      set_format_mod.extend Card::Set::Format
      set_format_mod.class_eval &block
    end

    def view *args, &block
      format do
        view *args, &block
      end
    end
    

    def event event, opts={}, &final
      opts[:on] = [:create, :update ] if opts[:on] == :save

      Card.define_callbacks event

      class_eval do
        final_method = "#{event}_without_callbacks" #should be private?
        define_method final_method, &final

        define_method event do
          run_callbacks event do
            send final_method
          end
        end
      end
    
      set_event_callbacks event, opts
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




    # the set loading process has two main phases:
    
    #  1. Definition: interpret each set file, creating/defining set and set_format modules
    #  2. Organization: have base classes include modules associated with the "all" set, and
    #     clean up the other modules
       
    class << self

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Definition Phase
    
      # each set file calls `extend Card::Set` when loaded
      def extended mod
        register_set mod
      end
  
      def register_set set_module
        if all_set?( set_module )
          @@current = Card
          base_modules << set_module
        else
          @@current = set_module
          includable_modules[ set_module.name ] = set_module
        end      
      end
      
      def register_set_format format_class, mod
        if @@current == Card
          base_format_modules[ format_class ] ||= []
          base_format_modules[ format_class ] << mod
        else
          includable_format_modules[ format_class ] ||= {}
          includable_format_modules[ format_class ][ @@current.name ] = mod
        end
      end
    
    
      def all_set? set_module
        set_module == Card or set_module.name =~ /^Card::Set::All::/
      end

      def write_tmp_file set_pattern, anchor, from_file, seq
        # FIXME - this does not properly handle anchorless sets
        # There are special hacks for *all, but others (like *rstar) will not be found by
        # include_set_modules, which will look for Card::Set::Rstar, not Card::Set::Rstar::Blah
        
        to_file = "#{Wagn.paths['tmp/sets'].first}/#{set_pattern}/#{seq}-#{anchor}.rb"
        file_content = <<EOF
# -*- encoding : utf-8 -*-
class Card; module Set; module #{set_pattern.camelize}; module #{anchor.camelize}
extend Card::Set
# ~~~~~~~~~~~ above autogenerated; below pulled from #{from_file} ~~~~~~~~~~~

#{ File.read from_file }

# ~~~~~~~~~~~ below autogenerated; above pulled from #{from_file} ~~~~~~~~~~~
end;end;end;end
EOF
        File.write to_file, file_content
        to_file
      end
      
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Organization Phase

          
      def process_base_modules
        process_base_module_list base_modules, Card
        base_format_modules.each do |format_class, modules_list|
          process_base_module_list modules_list, format_class
        end
        @@base_modules, @@base_format_modules = [], [] #needed?
      end
      
      def process_base_module_list list, klass
        list.each do |mod|
          if mod.instance_methods.any?
            klass.send :include, mod
          end
          if class_methods = mod.const_get_if_defined( :ClassMethods )
            klass.send :extend, class_methods
          end
        end
      end
    
      def clean_empty_modules
        clean_empty_module_from_hash includable_modules
        includable_format_modules.values.each do |hash|
          clean_empty_module_from_hash hash
        end
      end
      
      def clean_empty_module_from_hash hash
        hash.each do |mod_name, mod|
          if mod.instance_methods.empty?
            hash.delete mod_name
          end
        end
      end
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      # FIXME - like everything else related to "set patterns", this needs renaming
      # it no longer has anything to do with methods
      # (also, this should probably be with the set patterns code, not here)
      
      def method_key opts
        Card.set_patterns.each do |pclass|
          if !pclass.opt_keys.map(&opts.method(:has_key?)).member? false;
            return pclass.method_key_from_opts(opts)
          end
        end
      end
    
    end


    private
    


    def set_event_callbacks event, opts
      [:before, :after, :around].each do |kind|
        if object_method = opts.delete(kind)
          options = { :prepend => true } 
          parts = self.name.split '::'
          
          set_class_key, anchor_or_placeholder = parts[-2].underscore.to_sym, parts[-1].underscore
          set_key = Card::Set.method_key( set_class_key => anchor_or_placeholder )
          
          options[:if] = proc { |c| c.method_keys.member? set_key and c.event_applies? opts }
          Card.class_eval { set_callback object_method, kind, event, options }
        end
      end
    end

    def get_traits mod
      Card::Set.traits ||= {}
      Card::Set.traits[mod] or Card::Set.traits[mod] = {}
    end

    def add_traits args, options
      mod = @@current
  #    raise "Can't define card traits on all set" if mod == Card
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
          fetch :trait=>trait.to_sym, :new=>opts.clone
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
        self.subcards ||= {}
        self.subcards[card.name] = {:type_id => card.type_id, :content=>value }
        instance_variable_set "@#{trait}", value
      end
    end

  end
end

