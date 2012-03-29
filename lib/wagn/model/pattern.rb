module Wagn::Model
  module Pattern

    mattr_accessor :subclasses
    @@subclasses = []

    def self.register_class(klass) @@subclasses.unshift klass end
    def self.method_key(opts)
      @@subclasses.each do |pclass|
        if !pclass.opt_keys.map(&opts.method(:has_key?)).member? false; 
          return pclass.method_key_from_opts(opts) 
        end
      end
    end

=begin
    def before_save_rule()
      # do LTypeRightPattern need deeper checks?
      rule? && left.reset_patterns()
      Rails.logger.debug "before_save_rule: #{name}, #{rule?}"
    end
=end

    def reset_patterns_if_rule()
      !simple? and tag.type_id == Card::SettingID and
          (set=trunk).type_id == Card::SetID and set.reset_patterns
          #set.simple? ? set.reset_patterns : set.trunk.reset_patterns()
      #warn (Rails.logger.debug "after_save_rule: #{name}, #{set.inspect}")
    end

    def reset_patterns()
#      Rails.logger.debug "reset_patterns[#{name}]"
      @rule_cards={}
      @real_set_names = @set_mods_loaded = @junction_only = @patterns =
        @set_modules = @method_keys = @set_names = @template =
        @skip_type_lookup = nil
      true
    end

    def patterns()
      @patterns ||= @@subclasses.map { |sub| sub.new(self) }.compact
    end
    def patterns_with_new()
      new_card? ? patterns_without_new()[1..-1] : patterns_without_new()
    end
    alias_method_chain :patterns, :new

    def real_set_names() set_names.find_all &Card.method(:exists?)   end
    def css_names()      patterns.map(&:css_name).reverse*" "        end

    def junction_only?()
      !@junction_only.nil? ? @junction_only :
         @junction_only = patterns.map(&:class).find(&:junction_only?)
    end

    def set_modules()
      @set_modules ||= patterns_without_new.reverse.map(&:set_const).compact
      #warn (Rails.logger.debug "set_mods#{self.object_id}[#{name}] #{@set_modules.map(&:inspect)*", "}"); @set_modules
    end

    def label
      found = @@subclasses.find { |sub| cardname.tag_name.to_s==sub.key_name }
      found and found.label(cardname.left_name)
    end
    def set_names()     r= @set_names ||= patterns.map(&:to_s)               
          #warn "set_names #{r*', '}"; r
    end
    def method_keys()    @method_keys ||= patterns.map(&:get_method_key)     end
  end


  class SetBase
    include AllSets
    @@ruby19 = !!(RUBY_VERSION =~ /^1\.9/)
    @@setmodroot = Wagn::Set

    def set_const() (sm=set_module) ? SetBase.find_module(sm) : nil end

    class << self
      def find_module(mod)
        set, name = *(mod.split('::'))
        #warn "find_mod #{set}, #{name}, #{@@ruby19}"
        return nil unless name
        setm = find_real_module(@@setmodroot, set) or return nil
        find_real_module(setm, name)
      end

      def find_real_module(base, part)
        if @@ruby19
          base.const_defined?(part, false) ? base.const_get(part, false) : nil
        else
          #warn "1.8#{base}, #{part}: #{base.const_defined?(part)} ? #{base.const_get(part)}"
          base.const_defined?(part)        ? base.const_get(part)        : nil
        end
      rescue Exception => e
        return nil if NameError===e
        warn "exception #{e.inspect} #{e.backtrace*"\n"}"
        raise e
      end

      def pattern_applies?(c)        true     end
      def pattern_name(card)         key_name end
      def register key, opt_keys, opts={}
        Wagn::Model::Pattern.register_class self
        cattr_accessor :key, :opt_keys, :junction_only, :method_key, :trunkless, :key_name
        self.key_name = Card::Codename[key ] || ?*+key+??
        self.key = key
        #warn "Register pat #{self.key}, #{self.key_name} #{opt_keys.inspect} #{opts.inspect}"
        self.opt_keys = Array===opt_keys ? opt_keys : [opt_keys]
        opts.each { |key, val| self.send "#{key}=", val }
        self.trunkless = !!self.method_key
      end
      def method_key_from_opts(opts) method_key            end
      def junction_only?()           !!self.junction_only  end
      def trunkless?()               !!self.method_key     end
      def new(card) super(card) if pattern_applies?(card)  end
      def pattern_applies?(card)
        junction_only? ? card.cardname.junction? : true
      end
    end

    def initialize(card)
      @pat_name = Card===(pn=self.class.pattern_name(card)) ? pn : pn.to_cardname
      raise "Not a cardname #{@pat_name.inspect}" unless Wagn::Cardname===@pat_name
#      Rails.logger.warn "new#pattern #{self.class}#new(#{card}) #{@pat_name}"
      self
    end
    def get_method_key()
      return self.class.method_key if self.class.trunkless
      opts = {}
      opt_keys.each_with_index{ |key, index| opts[key] = opt_vals[index] }
      self.class.method_key_from_opts opts
    end
    def opt_vals()         []                                     end
    def inspect()            "<#{self.class} #{@pat_name.inspect}>"        end
    def to_s()           @pat_name.to_s                                end
    def css_name()
      caps_part = self.class.key.gsub(' ','_').upcase
      self.class.trunkless? ? caps_part : "#{caps_part}-#{@pat_name.trunk_name.css_name}"
    end
  end


  class AllPattern < SetBase
    register 'all', [], :method_key=>''
    def self.label(name)           'All Cards'    end
    def self.prototype_args(base)  {}             end
    def set_module()               "All"          end
  end

  class AllPlusPattern < SetBase
    register 'all_plus', :all_plus, :method_key=>'all_plus', :junction_only=>true
    def self.label(name)                  'All Plus Cards'        end
    def self.prototype_args(base)         {:name=>'+'}            end
    def set_module()                      "AllPlus"               end
  end

  class TypePattern < SetBase
    register 'type', :type
    class << self
      def label(name)                "All #{name.to_s} cards"             end
      def prototype_args(base)       {:type=>base}                        end
      def method_key_from_opts(opts)
        opts[:type].to_cardname.css_name+'_type'
      end
      def pattern_name(card)
        #warn (Rails.logger.debug "pattern_name (type) #{card.inspect} #{card.typecode.inspect}")
        card.typecode.nil? ? 'Basic+*type' : "#{card.typename}+#{key_name}"
      end
    end
    def opt_vals()                      [@pat_name.left_name]                 end
    def set_module()
      "Type::#{Card.typecode_from_id(Card.type_id_from_name(@pat_name.left_name))}"
    end
  end

  class StarPattern < SetBase
    register 'star', :star, :method_key=>'star'
    def self.label(name)               'Star Cards'            end
    def self.prototype_args(base)      {:name=>'*dummy'}       end
    def self.pattern_applies?(card)             card.cardname.star?     end
    def set_module()                   "Star"                  end
  end

  class RstarPattern < SetBase
    register 'rstar', :rstar, :method_key=>'rstar', :junction_only=>true
    def self.label(name)           "Cards ending in +(Star Card)"            end
    def self.prototype_args(base)  {:name=>'*dummy+*dummy'}                  end
    def self.pattern_applies?(card) n=card.cardname and n.junction? && n.tag_star?  end
    def set_module()               "Rstar"                                   end
  end

  class RightPattern < SetBase
    register 'right', :right, :junction_only=>true
    class << self
      def label(name)                "Cards ending in +#{name.to_s}"    end
      def prototype_args(base)       {:name=>"*dummy+#{base}"}          end
      def method_key_from_opts(opts)
        opts[:right].to_cardname.css_name+'_right'
      end
      def pattern_name(card)
        "#{card.cardname.tag_name}+#{key_name}"
       #warn (Rails.logger.debug "pattern_name Right #{card.cardname}, #{r}"); r
      end
    end
    def opt_vals()                      [@pat_name.left_name.to_s]      end
    def set_module()
      "Right::#{@pat_name.left_name.key.camelcase}"
    end
  end

  class LeftTypeRightNamePattern < SetBase
    register 'type_plus_right', [:ltype, :right], :junction_only=>true
    class << self
      def label(name)
        "Any #{name.left_name.to_s} card plus #{name.tag_name.to_s}"
      end
      def prototype_args(base)
        { :name=>"*dummy+#{base.tag_name}", :loaded_trunk=>
          Card.new( :name=>'*dummy', :type=>base.trunk_name ) }
      end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{
            opts[:right].to_cardname.css_name}_typeplusright}
      end
      def pattern_name(card)
        lft = card.loaded_trunk || card.left
        typename = (lft && lft.typename) || 'Basic'
        "#{typename}+#{card.cardname.tag_name}+#{key_name}"
      end
    end
    def left_type() @pat_name.left_name.left_name end
    def opt_vals() [left_type, @pat_name.left_name.tag_name] end
    def set_module()
      lt, tn = opt_vals
      tk = tn&&tn.to_cardname.key.gsub(/^\*/,'X')||''
      "LTypeRight::#{lt}#{tk.camelcase}" if lt and tk
    end
  end

  class SelfPattern < SetBase
    register 'self', :name
    class << self
      def label(name)                %{The card "#{name.to_s}"}           end
      def prototype_args(base)       { :name=>base }                      end
      def pattern_applies?(card)     true                                 end
      def method_key_from_opts(opts)
        opts[:name].to_cardname.css_name+'_self'
      end
      def pattern_name(card)
#        Rails.logger.info "pattern Solo Set recursion issue? #{name}" if cardname.tag_name == key # recursion protection ?
#        return if cardname.tag_name == key # recursion protection ?
        "#{card.name}+#{key_name}"
      end
    end
    def opt_vals()                      [@pat_name.left_name]                end
    def set_module()            "Self::#{@pat_name.left_name.to_s.camelize}" end
  end
end

