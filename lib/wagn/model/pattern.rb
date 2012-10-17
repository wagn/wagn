module Wagn::Model
  module Pattern
    mattr_accessor :subclasses
    @@subclasses = []

    def self.register_class(klass) @@subclasses.unshift klass end
    def self.method_key(opts)
      @@subclasses.each do |pclass|
        if !pclass.opt_keys.map(&opts.method(:has_key?)).member? false; 
          #warn "mk[#{pclass}] #{opts.inspect}"
          return pclass.method_key_from_opts(opts) 
        end
      end
    end

    def reset_patterns_if_rule()
      return if name.blank?
#      warn Rails.logger.warn("reset p ifr[#{inspect}], #{name_without_tracking}")
      if !simple? and !new_card? and setting=right and setting.type_id==Card::SettingID and set=left and set.type_id==Card::SetID
        #warn (Rails.logger.debug "reset set: #{name}, Set:#{set.inspect} + Setting:#{setting.inspect}")
        set.include_set_modules
        #warn (Rails.logger.debug "reset RR [#{set.name}]? #{self.update_read_rule_list.inspect}")
        self.update_read_rule_list = self.update_read_rule_list.concat( set.item_cards(:limit=>0) ) if setting.id == Card::ReadID
        #warn (Rails.logger.debug "reset RR> #{self.update_read_rule_list.inspect}")
        set.reset_patterns
        set.reset_set_patterns
      end
    end

    def reset_patterns
      @rule_cards={}
      @real_set_names = @set_mods_loaded = @junction_only = @patterns = @set_modules =
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

    def real_set_names
      set_names.find_all &Card.method(:exists?)
    end
    def css_names()      patterns.map(&:css_name).reverse*" "                                   end
    def set_modules()    @set_modules ||= patterns_without_new.reverse.map(&:set_const).compact end
    def set_names()
      Card.set_members(@set_names = patterns.map(&:to_s), key) if @set_names.nil?
      #warn Rails.logger.warn("sn #{@set_names.inspect}")
      @set_names
    end
    def method_keys()
      rr =
      @method_keys ||= patterns.map(&:get_method_key).compact
      #warn "mks[#{inspect}] #{rr.inspect}"; rr
    end
  end

  class BasePattern
    include AllSets

    @@ruby19 = !!(RUBY_VERSION =~ /^1\.9/)
    @@setmodroot = Wagn::Set

    class << self
      def find_module mod
        set, name = *(mod.split('::'))
        #warn "find_mod #{set}, #{name}, #{@@ruby19}"
        return nil unless name
        setm = find_real_module(@@setmodroot, set) or return nil
        find_real_module(setm, name)
      end

      def find_real_module base, part
        if @@ruby19
          base.const_defined?(part, false) ? base.const_get(part, false) : nil
        else
          base.const_defined?(part)        ? base.const_get(part)        : nil
        end
      rescue Exception => e
        Rails.logger.warn "frm exception #{e.inspect} #{e.backtrace[0..8]*"\n"}"
        return nil if NameError===e
        warn "exception #{e.inspect} #{e.backtrace[0..8]*"\n"}"
        raise e
      end

      def trunk_name(card)  ''                                     end
      def junction_only?()  !!self.junction_only                   end
      def trunkless?()      !!self.method_key                      end # method key determined by class only when no trunk involved
      def new(card)         super(card) if pattern_applies?(card)  end
      def key_name()
        @key_name ||= (cn=Wagn::Codename[self.key] and c=Card[cn] and c.name)
      end

      def register key, opt_keys, opts={}
        Wagn::Model::Pattern.register_class self
        #@@pattern_class.register_class self
        cattr_accessor :key, :opt_keys, :junction_only, :method_key
        self.key = key
        self.opt_keys = Array===opt_keys ? opt_keys : [opt_keys]
        opts.each { |key, val| self.send "#{key}=", val }
        #warn "reg K:#{self}[#{self.key}] OK:[#{opt_keys.inspect}] jo:#{junction_only.inspect}, mk:#{method_key.inspect}"
      end
      
      def method_key_from_opts opts            
        method_key || begin
          parts = opt_keys.map do |opt_key|
            opts[opt_key].to_s.gsub('+', '-')
          end << key
          parts.join '_'
        end
      end
      
      def pattern_applies?(card)
        junction_only? ? card.cardname.junction? : true
      end
    end

    def initialize(card)
      @trunk_name = self.class.trunk_name(card).to_cardname
      self
    end
    
    def set_module
      case 
      when  self.class.trunkless?    ; key.camelize
      when  opt_vals.member?( nil )  ; nil
      else  self.key.camelize + '::' + ( opt_vals.join('_').camelize )
      end
    end

    def set_const
      (sm = set_module) ? BasePattern.find_module(sm) : nil
    end
    
    def get_method_key()
      tkls_key = self.class.method_key
      #warn "tkls[#{@trunk_name}] #{tkls_key.inspect}" if tkls_key
      return tkls_key if tkls_key
      return self.class.method_key if self.class.trunkless?
      opts = {}
      ov = opt_vals
      #warn "gmkey [#{@trunk_name.inspect}] ov:#{ov.inspect}, ok:#{opt_keys.inspect}"
      opt_keys.each_with_index do |key, index|
        return nil unless opt_vals[index]
        opts[key] = opt_vals[index]
      end
      r=self.class.method_key_from_opts opts
      #warn "gmkey[#{@trunk_name}] #{opt_keys.inspect}, #{opts.inspect}, R:#{r}";r
    end
    
    def inspect()       "<#{self.class} #{to_s.to_cardname.inspect}>" end

    def opt_vals
      if @opt_vals.nil?
        @opt_vals = self.class.trunkless? ? [] : @trunk_name.parts.map do |part|
          card=Card.fetch(part, :skip_virtual=>true, :skip_modules=>true) and
               Wagn::Codename[card.id.to_i]
        end
      end
      @opt_vals
    end

    def to_s()
      k = self.class.key_name
      self.class.trunkless? ? k : "#{@trunk_name}+#{k}"
    end
    
    def css_name()
      caps_part = self.class.key.gsub(' ','_').upcase
      self.class.trunkless? ? caps_part : "#{caps_part}-#{@trunk_name.css_name}"
    end
  end

  class AllPattern < BasePattern
    register 'all', [], :method_key=>''
    def self.label(name)              'All cards'                end
    def self.prototype_args(base)     {}                         end
  end

  class AllPlusPattern < BasePattern
    register 'all_plus', :all_plus, :method_key=>'all_plus', :junction_only=>true
    def self.label(name)              'All "+" cards'            end
    def self.prototype_args(base)     {:name=>'+'}               end
  end

  class TypePattern < BasePattern
    register 'type', :type
    def self.label(name)              %{All "#{name}" cards}     end
    def self.prototype_args(base)     {:type=>base}              end
    def self.pattern_applies?(card)
      return false if card.type_id.nil?
      raise "bogus type id" if card.type_id < 1
      true       end
    def self.trunk_name(card)         card.type_name              end
  end

  class StarPattern < BasePattern
    register 'star', :star, :method_key=>'star'
    def self.label(name)              'All "*" cards'            end
    def self.prototype_args(base)     {:name=>'*dummy'}          end
    def self.pattern_applies?(card)   card.cardname.star?        end
  end

  class RstarPattern < BasePattern
    register 'rstar', :rstar, :method_key=>'rstar', :junction_only=>true
    def self.label(name)              'All "+*" cards'           end
    def self.prototype_args(base)     { :name=>'*dummy+*dummy'}  end
    def self.pattern_applies?(card)   card.cardname.rstar?       end
  end

  class RightPattern < BasePattern
    register 'right', :right, :junction_only=>true
    def self.label(name)              %{All "+#{name}" cards}    end
    def self.prototype_args(base)     {:name=>"*dummy+#{base}"}  end
    def self.trunk_name(card)         card.cardname.tag_name     end
  end

  class LeftTypeRightNamePattern < BasePattern
    register 'type_plus_right', [:ltype, :right], :junction_only=>true
    class << self
      def label name
        %{All "+#{name.to_cardname.tag_name}" cards on "#{name.to_cardname.left_name}" cards}
      end
      def prototype_args base
        { :name=>"*dummy+#{base.tag_name}", 
          :loaded_trunk=> Card.new( :name=>'*dummy', :type=>base.trunk_name )
        }
      end
      def trunk_name card
        lft = card.loaded_trunk || card.left
        type_name = (lft && lft.type_name) || Card[ Card::DefaultTypeID ].name
        "#{type_name}+#{card.cardname.tag_name}"
      end
    end
  end

  class SelfPattern < BasePattern
    register 'self', :name
    def self.label(name)              %{The card "#{name}"}      end
    def self.prototype_args(base)     { :name=>base }            end
    def self.trunk_name(card)         card.name                  end
  end
end
