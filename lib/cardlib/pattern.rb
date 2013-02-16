module Cardlib
  module Pattern
    mattr_accessor :subclasses
    @@subclasses = []

    def self.register_class klass
      @@subclasses.unshift klass
    end

    def self.method_key opts
      @@subclasses.each do |pclass|
        if !pclass.opt_keys.map(&opts.method(:has_key?)).member? false;
          return pclass.method_key_from_opts(opts)
        end
      end
    end

    def reset_patterns_if_rule
      return if name.blank?
      #warn "rpatIrule if #{!simple?} and #{!new_card?} and #{setting=right and setting.type_id==Card::SettingID} and #{set=left and set.type_id==Card::SetID}"
      if !simple? and !new_card? and setting=right and setting.type_id==Card::SettingID and set=left and set.type_id==Card::SetID
        #warn "rpatIrule #{inspect}, #{set.inspect}, #{setting.inspect}"
        set.include_set_modules
        self.read_rule_updates( set.item_cards :limit=>0 ) if setting.id == Card::ReadID
        set.reset_patterns
        set.reset_set_patterns
      end
    end

    def reset_patterns
      @rule_cards={}
      @set_mods_loaded = @patterns = @set_modules = @junction_only = @method_keys = @set_names = @template = nil # @virtual ?
      true
    end

    def patterns
      @patterns ||= @@subclasses.map { |sub| sub.new(self) }.compact
    end

    def patterns_with_new
      new_card? ? patterns_without_new[1..-1] : patterns_without_new
    end
    alias_method_chain :patterns, :new

    def real_set_names
      set_names.find_all &Card.method(:exists?)
    end

    def safe_keys
      patterns.map(&:safe_key).reverse*" "
    end

    def set_modules
      @set_modules ||= patterns_without_new.reverse.map(&:set_const).compact
    end

    def set_names
      Card.set_members(@set_names = patterns.map(&:to_s), key) if @set_names.nil?
      @set_names
    end

    def method_keys
      @method_keys ||= patterns.map(&:get_method_key).compact
    end
  end

  module Patterns
    class BasePattern

      RUBY19 = !!(RUBY_VERSION =~ /^1\.9/)
      MODULES={}

      class << self

        attr_accessor :key, :key_id, :opt_keys, :junction_only, :method_key

        def find_module mod
          module_name_parts = mod.split('/') << 'model'
          module_name_parts.inject Wagn::Set do |base, part|
            return if base.nil?
            #Rails.logger.warn "find m #{base}, #{part}"
            part = part.camelize
            key = "#{base}::#{part}"
            if MODULES.has_key?(key)
              MODULES[key]
            else
              args = RUBY19 ? [part, false] : [part]
              MODULES[key] = base.const_defined?(*args) ? base.const_get(*args) : nil
            end
          end
        rescue Exception => e
        #rescue NameError => e
          Rails.logger.warn "find_module error #{mod}: #{e.inspect}"
          return nil if NameError ===e
        end

        def trunk_name card; ''                     end
        def junction_only?;  !!junction_only        end
        def trunkless?;      !!method_key           end # method key determined by class only when no trunk involved

        def new card
          super if pattern_applies? card
        end

        def key_name
          @key_name ||= (code=Wagn::Codename[self.key] and card=Card[code] and card.name)
        end

        def register key, opt_keys, opts={}
          Cardlib::Pattern.register_class self
          self.key = key
          self.key_id = Wagn::Codename[key]
          self.opt_keys = Array===opt_keys ? opt_keys : [opt_keys]
          opts.each { |key, val| send "#{key}=", val }
          #warn "reg K:#{self}[#{key}] OK:[#{opt_keys.inspect}] jo:#{junction_only.inspect}, mk:#{method_key.inspect}"
        end

        def method_key_from_opts opts
          method_key || ((opt_keys.map do |opt_key|
              opts[opt_key].to_s.gsub('+', '-')
            end << key) * '_')
        end

        def pattern_applies? card
          junction_only? ? card.cardname.junction? : true
        end
      end

      def initialize card
        @trunk_name = self.class.trunk_name(card).to_name
        raise if @trunk_name.to_s == 'true'
        self
      end

      def set_const
        if set_module = case
              when  self.class.trunkless?    ; self.class.key
              when  opt_vals.member?( nil )  ; nil
              else  "#{self.class.key}/#{opt_vals * '_'}"
            end

          self.class.find_module set_module

        end

      rescue Exception => e; warn "exception set_const #{e.inspect}," #{e.backtrace*"\n"}"
      end

      def get_method_key
        tkls_key = self.class.method_key
        return tkls_key if tkls_key
        return self.class.method_key if self.class.trunkless?
        opts = {}
        self.class.opt_keys.each_with_index do |key, index|
          return nil unless opt_vals[index]
          opts[key] = opt_vals[index]
        end
        self.class.method_key_from_opts opts
      end

      def opt_vals
        if @opt_vals.nil?
          @opt_vals = self.class.trunkless? ? [] :
            @trunk_name.parts.map do |part|
              card=Card.fetch(part, :skip_virtual=>true, :skip_modules=>true) and Wagn::Codename[card.id.to_i]
            end
        end
        @opt_vals
      end

      def to_s
        kn = self.class.key_name
        #warn "pat to_s  #{self.class} #{@trunk_name}+#{kn}" if @trunk_name == 'address'
        self.class.trunkless? ? kn : "#{@trunk_name}+#{kn}"
      end

      def inspect
        "<#{self.class} #{to_s.to_name.inspect}>"
      end

      def safe_key()
        caps_part = self.class.key.gsub(' ','_').upcase
        self.class.trunkless? ? caps_part : "#{caps_part}-#{@trunk_name.safe_key}"
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
      def self.label            name;   %{All "#{name}" cards}     end
      def self.prototype_args   base;   {:type=>base}              end
      def self.pattern_applies? card;   !!card.type_id             end
      def self.trunk_name       card;   card.type_name             end
    end

    class StarPattern < BasePattern
      register 'star', :star, :method_key=>'star'
      def self.label            name;   'All "*" cards'            end
      def self.prototype_args   base;   {:name=>'*dummy'}          end
      def self.pattern_applies? card;   card.cardname.star?        end
    end

    class RstarPattern < BasePattern
      register 'rstar', :rstar, :method_key=>'rstar', :junction_only=>true
      def self.label            name;   'All "+*" cards'           end
      def self.prototype_args   base;   { :name=>'*dummy+*dummy'}  end
      def self.pattern_applies? card;   card.cardname.rstar?       end
    end

    class RightPattern < BasePattern
      register 'right', :right, :junction_only=>true
      def self.label            name;   %{All "+#{name}" cards}    end
      def self.prototype_args   base;   {:name=>"*dummy+#{base}"}  end
      def self.trunk_name       card;   card.cardname.tag          end
    end

    class LeftTypeRightNamePattern < BasePattern
      register 'type_plus_right', [:ltype, :right], :junction_only=>true
      class << self
        def label name
          %{All "+#{name.to_name.tag}" cards on "#{name.to_name.left_name}" cards}
        end
        def prototype_args base
          { :name=>"*dummy+#{base.tag}",
            :loaded_left=> Card.new( :name=>'*dummy', :type=>base.trunk_name )
          }
        end
        def trunk_name card
          left = card.loaded_left || card.left
          type_name = (left && left.type_name) || Card[ Card::DefaultTypeID ].name
          "#{type_name}+#{card.cardname.tag}"
        end
      end
    end

    class SelfPattern < BasePattern
      register 'self', :name
      def self.label            name;   %{The card "#{name}"}      end
      def self.prototype_args   base;   { :name=>base }            end
      def self.trunk_name       card;   card.name                  end
    end
  end
end
