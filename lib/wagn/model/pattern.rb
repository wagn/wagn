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

    def reset_patterns_if_rule()
      #warn (Rails.logger.debug "save_rule? #{inspect}")
      if !simple? and (setting=tag).type_id == Card::SettingID and
         (set=trunk).type_id == Card::SetID
        #warn (Rails.logger.debug "reset set: #{name}, Set:#{set.object_id}, #{set.class} #{set.id}, #{set.inspect} + #{setting.inspect}")
        set.include_set_modules
        set.reset_set_patterns(setting)
      end
    end

    def reset_patterns
      @rule_cards={}
      @real_set_names = @set_mods_loaded = @junction_only = @patterns =
        @method_keys = @set_names = @template = @skip_type_lookup = nil
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

    def set_modules()
      @set_modules ||= patterns_without_new.reverse.map(&:set_const).compact
      #warn "@set_modules = #{@set_modules}"
      #@set_modules
    end

    def set_names()     r= @set_names ||= patterns.map(&:to_s)
          #warn "set_names #{r*', '}"; r
    end
    def method_keys()   @method_keys ||= patterns.map(&:get_method_key).compact   end
  end


  class BasePattern
    include AllSets
    @@ruby19 = !!(RUBY_VERSION =~ /^1\.9/)
    @@setmodroot = Wagn::Set

    def set_module
#      warn "set_module called for #{self.class}"
      case 
        when self.class.trunkless?
          key.camelize
        when  opt_vals.member?( nil )
          nil
        else 
          self.key.camelize + '::' + ( opt_vals.join('_').camelize )
        end
    end

    def set_const
      sm = set_module
#      warn "sm = #{sm}"
      sm ? BasePattern.find_module(sm) : nil
    end

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
      def key_name()
        Rails.logger.warn "key_name #{self.key} #{Card::Codename[self.key]}"
        Card::Codename[self.key] || self.key
      end

      def register key, opt_keys, opts={}
        Wagn::Model::Pattern.register_class self
        cattr_accessor :key, :opt_keys, :junction_only, :method_key
        self.key = key
        self.opt_keys = Array===opt_keys ? opt_keys : [opt_keys]
        opts.each { |key, val| self.send "#{key}=", val }
      end
      def method_key_from_opts(opts) method_key            end
      def junction_only?()           !!self.junction_only  end
      def trunkless?()               !!self.method_key     end # method key determined by class only when no trunk involved
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
      return self.class.method_key if self.class.trunkless?
      opts = {}
      opt_keys.each_with_index do |key, index|
        return nil unless opt_vals[index]
        opts[key] = opt_vals[index].downcase # FIXME - shouldn't need to downcase
      end
      self.class.method_key_from_opts opts
    end
    def opt_vals()      []                                            end
    def inspect()       "<#{self.class} #{@pat_name.inspect}>"        end
    def to_s()          @pat_name.to_s                                end
    def css_name()
      caps_part = self.class.key.gsub(' ','_').upcase
      self.class.trunkless? ? caps_part : "#{caps_part}-#{@pat_name.trunk_name.css_name}"
    end
  end


  class AllPattern < BasePattern
    register 'all', [], :method_key=>''
    def self.label(name)           'All Cards'    end
    def self.prototype_args(base)  {}             end
  end

  class AllPlusPattern < BasePattern
    register 'all_plus', :all_plus, :method_key=>'all_plus', :junction_only=>true
    def self.label(name)                  'All Plus Cards'        end
    def self.prototype_args(base)         {:name=>'+'}            end
  end

  class TypePattern < BasePattern
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
    def opt_vals()                      [Card::Codename[@pat_name.left_name]]                 end
#    def set_module()
#      "Type::#{Card.typecode_from_id(Card.type_id_from_name(@pat_name.left_name))}"
#    end
  end

  class StarPattern < BasePattern
    register 'star', :star, :method_key=>'star'
    def self.label(name)               'Star Cards'            end
    def self.prototype_args(base)      {:name=>'*dummy'}       end
    def self.pattern_applies?(card)             card.cardname.star?     end
  end

  class RstarPattern < BasePattern
    register 'rstar', :rstar, :method_key=>'rstar', :junction_only=>true
    def self.label(name)           "Cards ending in +(Star Card)"            end
    def self.prototype_args(base)  {:name=>'*dummy+*dummy'}                  end
    def self.pattern_applies?(card) n=card.cardname and n.junction? && n.tag_star?  end
  end

  class RightPattern < BasePattern
    register 'right', :right, :junction_only=>true
    class << self
      def label(name)          "Cards ending in +#{name.to_s}"          end
      def prototype_args(base) {:name=>"*dummy+#{base}"}                end
      def pattern_name(card)   "#{card.cardname.tag_name}+#{key_name}"  end
      def method_key_from_opts(opts)
        opts[:right].to_cardname.css_name+'_right'
      end
    end
    def opt_vals()      [Card::Codename[@pat_name.left_name.to_s]]      end
  end

  class LeftTypeRightNamePattern < BasePattern
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
    def opt_vals() [Card::Codename[left_type], Card::Codename[@pat_name.left_name.tag_name]] end
    
    private
    def left_type() @pat_name.left_name.left_name end
  end

  class SelfPattern < BasePattern
    register 'self', :name
    class << self
      def label(name)                %{The card "#{name.to_s}"}           end
      def prototype_args(base)       { :name=>base }                      end
      def pattern_applies?(card)     true                                 end
      def method_key_from_opts(opts)
        opts[:name].to_cardname.css_name+'_self'
      end
      def pattern_name(card)
#        Rails.logger.info "pattern Solo Set ? #{card} #{name}"
        "#{card.name}+#{key_name}"
      end
    end
    def opt_vals()                      
      warn "@pat_name = #{@pat_name}; left_name = #{@pat_name.left_name}; codename = #{Card::Codename[@pat_name.left_name]}"
      [Card::Codename[@pat_name.left_name]]
    end
  end
end

