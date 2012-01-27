module Wagn::Model
  module Pattern

    @@pattern_subclasses = []

    class << self
      def register_class(klass) @@pattern_subclasses.unshift klass end
      def pattern_subclasses() @@pattern_subclasses end

      def method_key(opts)
        @@pattern_subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false; 
            return pclass.method_key_from_opts(opts) 
          end
        end
      end
    end

    def patterns()
      @patterns ||= @@pattern_subclasses.map do |sub|
        instance = sub.new self
        instance.pattern_applies? ? instance : nil
      end.compact
    end
    def reset_patterns()
      @set_mods_loaded = @junction_only = @patterns = @method_keys = @set_names = @template = @virtual = nil
    end
    def set_names()      @set_names ||= patterns.map(&:set_name)                  end
    def real_set_names() set_names.find_all { |set_name| Card.exists? set_name }  end
    def method_keys()    @method_keys ||= patterns.map(&:get_method_key)          end
    def css_names()      patterns.map(&:css_name).reverse*" "                     end
  end


  class SetBase
    attr_accessor :card

    class << self
      def register key, opt_keys, opts={} #(key, opt_keys)
        Wagn::Model::Pattern.register_class self
        cattr_accessor :key, :opt_keys, :trunkless, :junction_only, :method_key
        self.key = key
        self.opt_keys = Array===opt_keys ? opt_keys : [opt_keys]
        opts.each { |key, val| self.send "#{key}=", val }
      end
      def method_key_from_opts(opts) method_key    end
      def junction_only?()   !!self.junction_only  end
      def trunkless?()       !!self.method_key     end
    end

    def initialize(card)   @card = card                           end
    def opt_vals()         []                                     end
    def set_name()         (opt_vals << self.class.key).join '+'  end
    def get_method_key()
      return self.class.method_key if self.class.trunkless?
      opts = {}
      opt_keys.each_with_index{ |key, index| opts[key] = opt_vals[index] }
      self.class.method_key_from_opts opts
    end
    def pattern_applies?
      self.class.junction_only? ? card.cardname.junction? : true
    end
    def css_name()
      caps_part = self.class.key.gsub(' ','_').gsub('*','').upcase
      self.class.trunkless? ? caps_part : "#{caps_part}-#{set_name.to_cardname.trunk_name.css_name}"
    end
  end


  class AllPattern < SetBase
    register '*all', [], :method_key=>''
    def self.label(name)           'All Cards'    end
    def self.prototype_args(base)  {}             end
  end
  
  class AllPlusPattern < SetBase
    register '*all plus', :all_plus, :method_key=>'all_plus', :junction_only=>true
    def self.label(name)                  'All Plus Cards'        end
    def self.prototype_args(base)         {:name=>'+'}            end
  end

  class TypePattern < SetBase
    register '*type', :type
    def self.label(name)                "All #{name} cards"                       end
    def self.prototype_args(base)       {:type=>base}                             end
    def self.method_key_from_opts(opts) opts[:type].to_cardname.css_name+'_type'  end
    def opt_vals()                      [card.typename.to_s]                      end
  end

  class StarPattern < SetBase
    register '*star', :star, :method_key=>'star'
    def self.label(name)               'Star Cards'            end
    def self.prototype_args(base)      {:name=>'*dummy'}       end
    def pattern_applies?()             card.cardname.star?     end
  end

  class RstarPattern < SetBase
    register '*rstar', :rstar, :method_key=>'rstar', :junction_only=>true
    def self.label(name)           "Cards ending in +(Star Card)"                 end
    def self.prototype_args(base)  {:name=>'*dummy+*dummy'}                       end
    def pattern_applies?()         n=card.cardname and n.junction? && n.tag_star? end
  end

  class RightPattern < SetBase
    register '*right', :right, :junction_only=>true
    def self.label(name)                "Cards ending in +#{name}"                  end
    def self.prototype_args(base)       {:name=>"*dummy+#{base}"}                   end
    def self.method_key_from_opts(opts) opts[:right].to_cardname.css_name+'_right'  end
    def opt_vals()                      [card.cardname.tag_name]                    end
  end

  class LeftTypeRightNamePattern < SetBase
    register '*type plus right', [:ltype, :right], :junction_only=>true
    class << self
      def label(name) "Any #{name.left_name} card plus #{name.tag_name}"     end
      def prototype_args(base)
        { :name=>"*dummy+#{base.tag_name}", :loaded_trunk=> Card.new( :name=>'*dummy', :type=>base.trunk_name ) }
      end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{opts[:right].to_cardname.css_name}_typeplusright}
      end
    end
    def opt_vals
      left = card.loaded_trunk || card.left
      left_type = left ? left.typename : 'Basic'
      [ left_type, card.cardname.tag_name ]
    end
  end

  class SelfPattern < SetBase
    register '*self', :name
    def self.label(name)                %{The card "#{name}"}                     end
    def self.prototype_args(base)       { :name=>base }                           end
    def self.method_key_from_opts(opts) opts[:name].to_cardname.css_name+'_self'  end
    def opt_vals()                      [card.cardname]                           end
    def pattern_applies?()              !card.new_card?                           end
  end
end
