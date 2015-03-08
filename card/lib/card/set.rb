# -*- encoding : utf-8 -*-

class Card
  #remove_const :Set if const_defined?(:Set, false)

  module Set
   
    mattr_accessor :modules, :traits
    @@modules = { :base=>[], :base_format=>{}, :nonbase=>{}, :nonbase_format=>{} }
   
    
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
    add or override Card and/or Format methods directly.  The majority of Card code is contained
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
    information about set_ptterns and mod/core/set/all/fetch.rb for more about fetching.)

    Similarly, whenever a Format object is instantiated for a card, it includes all views
    associated with BOTH (a) sets of which the card is a member and (b) the current format or 
    its ancestors.  More on defining views below.

 
    In order to have a set file associated with "all cards ending in +address", you could create
    a file in mywagn/mod/mymod/set/right/address.rb.  The recommended mechanism for doing so
    is running `wagn generate set modname set_pattern set_anchor`. In the current example, this
    would translate to `wagn generate set mymod right address`. Note that both the set_pattern 
    and the set_anchor must correspond to the codename of a card in the database to function
    correctly but you can add arbitrary subdirectories to organize your code rules. The rule above 
    for example could be saved in mywagn/mod/mymod/set/right/address/america/north/canada.rb.

    
    When a Card application loads, it uses these files to autogenerate a tmp_file that uses this set file to
    createa Card::Set::Right::Address module which itself is extended with Card::Set. A set file
    is "just ruby" but is generally quite concise because Card uses its file location to 
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
      mattr_accessor :views
      @@views = {}
      
      def view view, *args, &block
        view = view.to_name.key.to_sym
        views[self] ||= {}
        view_block = views[self][view] = if block_given?
          Card::Format.extract_class_vars view, args[0]
          block
        else
          alias_block view, args
        end
        define_method "_view_#{ view }", view_block
      end
      
      def alias_block view, args
        opts = Hash===args[0] ? args.shift : { :view => args.shift }
        opts[:mod]  ||= self
        opts[:view] ||= view
        views[ opts[:mod] ][ opts[:view] ] or fail
      rescue
        raise "cannot find #{ opts[:view] } view in #{ opts[:mod] }; failed to alias #{view} in #{self}"
      end
      
    end

    
    def format *format_names, &block
      if format_names.empty?
        format_names = [:base]
      elsif format_names.first == :all
        format_names = Card::Format.registered.reject {|f| Card::Format.aliases[f]}
      end
      format_names.each do |f|
        define_on_format f, &block
      end
    end
    
    def define_on_format format_name=:base, &block
      klass = Card::Format.format_class_name format_name   # format class name, eg. HtmlFormat
      mod = const_get_or_set klass do                      # called on current set module, eg Card::Set::Type::Pointer
        m = Module.new                                     # yielding set format module, eg Card::Set::Type::Pointer::HtmlFormat
        register_set_format Card.const_get(klass), m
        m.extend Card::Set::Format
        m
      end                                             
      mod.class_eval &block
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
            Card.with_logging :event, :message=>event, :context=>self.name, :details=>opts do
              send final_method
            end
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
        if set_module.all_set?
          modules[ :base ] << set_module
        else
          modules[ :nonbase ][ set_module.shortname ] ||= []
          modules[ :nonbase ][ set_module.shortname ] << set_module
        end      
      end
      
      def write_tmp_file set_pattern, anchors, from_file, seq
        # FIXME - this does not properly handle anchorless sets
        # There are special hacks for *all, but others (like *rstar) will not be found by
        # include_set_modules, which will look for Card::Set::Rstar, not Card::Set::Rstar::Blah
        # This issue appears to be addressed by making the entries, in modules arrays.
        # If yes remove this comment.

        to_file = "#{Cardio.paths['tmp/set'].first}/#{set_pattern}/#{seq}-#{anchors * '-'}.rb"
        anchor_modules = anchors.map { |a| "module #{a.camelize};" } * ' '
        file_content = <<EOF
# -*- encoding : utf-8 -*-
class Card; module Set; module #{set_pattern.camelize}; #{anchor_modules}
extend Card::Set
# ~~~~~~~~~~~ above autogenerated; below pulled from #{from_file} ~~~~~~~~~~~

#{ File.read from_file }

# ~~~~~~~~~~~ below autogenerated; above pulled from #{from_file} ~~~~~~~~~~~
end;end;end;#{'end;'*anchors.size}
EOF
        File.write to_file, file_content
        to_file
      end
      
      
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Organization Phase

      # "base modules" are modules that are permanently included on the Card or Format class
      # "nonbase modules" are included dynamically on singleton_classes
      def process_base_modules
        process_base_module_list modules[:base], Card
        modules[:base_format].each do |format_class, modules_list|
          process_base_module_list modules_list, format_class
        end
        modules.delete :base
        modules.delete :base_format
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
        clean_empty_module_from_hash modules[ :nonbase ]
        modules[ :nonbase_format ].values.each do |hash|
          clean_empty_module_from_hash hash
        end
      end
      
      def clean_empty_module_from_hash hash
        hash.each do |mod_name, modlist|
          modlist.delete_if { |x| x.instance_methods.empty? }
          hash.delete mod_name if modlist.empty?
        end
      end
      
    end


    def register_set_format format_class, mod
      if self.all_set?
        modules[ :base_format ][ format_class ] ||= []
        modules[ :base_format ][ format_class ] << mod
      else
        format_hash = modules[ :nonbase_format ][ format_class ] ||= {}
        format_hash[ shortname ] ||= []
        format_hash[ shortname ] << mod
      end
    end

    def shortname
      parts = name.split '::'
      first = 2 # shortname eliminates Card::Set
      set_class = Card::SetPattern.find parts[first].underscore
      
      last = first + set_class.anchor_parts_count
      parts[first..last].join '::'
    end

    def all_set?
      name =~ /^Card::Set::All::/
    end

    private
    
    
    def set_event_callbacks event, opts
      [:before, :after, :around].each do |kind|
        if object_method = opts.delete(kind)
          this_set_module = self
          Card.class_eval do
            set_callback object_method, kind, event, :prepend=>true, :if=> proc { |c|
              c.singleton_class.include?( this_set_module ) and c.event_applies? opts
            }
          end
        end
      end
    end

    def get_traits mod
      Card::Set.traits ||= {}
      Card::Set.traits[mod] or Card::Set.traits[mod] = {}
    end

    def add_traits args, options
      mod = self
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

