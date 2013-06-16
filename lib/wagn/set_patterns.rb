module Wagn::SetPatterns
  class BasePattern

    class << self

      attr_accessor :key, :key_id, :opt_keys, :junction_only, :method_key, :assigns_type

      def junction_only?()  !!junction_only  end
      def anchorless?()     !!method_key     end # method key determined by class only when no trunk involved
      def anchor_name(card) ''               end

      def new card
        super if pattern_applies? card
      end

      def key_name
        Card.fetch(self.key_id, :skip_modules=>true).cardname
      end

      def register key, opts={}
        if self.key_id = Wagn::Codename[key]
          self.key = key
          Card.register_pattern self, opts.delete(:index)
          self.opt_keys = opts.delete(:opt_keys) || [ key.to_sym ]
          opts.each { |key, val| send "#{key}=", val }
        end
      end

      def method_key_from_opts opts
        method_key || ((opt_keys.map do |opt_key|
          opts[opt_key].to_s.gsub('+', '-')
        end << key) * '_' )
      end

      def pattern_applies? card
        junction_only? ? card.cardname.junction? : true
      end
    end

    def initialize card
      @anchor_name = self.class.anchor_name(card).to_name

      @anchor_id = if self.class.respond_to? :anchor_id
        self.class.anchor_id card
      else
        anchor_card = Card.fetch @anchor_name, :skip_virtual=>true, :skip_modules=>true
        anchor_card && anchor_card.id
      end
      self
    end


    def set_const
      set_module = case
        when  self.class.anchorless?    ; self.class.key
        when  opt_vals.member?( nil )  ; nil
        else  "#{self.class.key}::#{opt_vals * '_'}"
        end

      Card.find_set_model_module set_module if set_module

    rescue Exception => e; warn "exception set_const #{e.inspect}," #{e.backtrace*"\n"}"
    end

    def get_method_key
      if self.class.anchorless?
        self.class.method_key
      else
        opts = {}
        self.class.opt_keys.each_with_index do |key, index|
          return nil unless opt_vals[index]
          opts[key] = opt_vals[index]
        end
        self.class.method_key_from_opts opts
      end
    end

    def opt_vals
      if @opt_vals.nil?
        @opt_vals = self.class.anchorless? ? [] : find_opt_vals
      end
      @opt_vals
    end

    def find_opt_vals
      anchor_parts = if self.class.opt_keys.size > 1
        [ @anchor_name.left, @anchor_name.right ]
      else
        [ @anchor_name ]
      end
      anchor_parts.map do |part|
        card = Card.fetch part, :skip_virtual=>true, :skip_modules=>true
        card && Wagn::Codename[card.id.to_i] or return []
      end
    end

    def key_name
      @key_name ||= self.class.key_name
    end

    def to_s
      self.class.anchorless? ? key_name.s : "#{@anchor_name}+#{key_name}"
    end

    def inspect
      "<#{self.class} #{to_s.to_name.inspect}>"
    end

    def safe_key()
      caps_part = self.class.key.gsub(' ','_').upcase
      self.class.anchorless? ? caps_part : "#{caps_part}-#{@anchor_name.safe_key}"
    end

    def rule_set_key
      if self.class.anchorless?
        self.class.key
      elsif @anchor_id
        [ @anchor_id, self.class.key ].map( &:to_s ) * '+'
      end
    end
  end

  class AllPattern < BasePattern
    register 'all', :opt_keys=>[], :method_key=>''
    def self.label(name)              'All cards'                end
    def self.prototype_args(anchor)   {}                         end
  end

  class AllPlusPattern < BasePattern
    register 'all_plus', :method_key=>'all_plus', :junction_only=>true
    def self.label(name)              'All "+" cards'            end
    def self.prototype_args(anchor)   {:name=>'+'}               end
  end

  class TypePattern < BasePattern
    register 'type'
    def self.label             name;  %{All "#{name}" cards}     end
    def self.prototype_args  anchor;  {:type=>anchor}            end
    def self.pattern_applies?  card;  !!card.type_id             end
    def self.anchor_name       card;  card.type_name             end
    def self.anchor_id         card;  card.type_id               end
  end

  class StarPattern < BasePattern
    register 'star', :method_key=>'star'
    def self.label            name;   'All "*" cards'            end
    def self.prototype_args anchor;   {:name=>'*dummy'}          end
    def self.pattern_applies? card;   card.cardname.star?        end
  end

  class RstarPattern < BasePattern
    register 'rstar', :method_key=>'rstar', :junction_only=>true
    def self.label            name;   'All "+*" cards'           end
    def self.prototype_args anchor;   { :name=>'*dummy+*dummy'}  end
    def self.pattern_applies? card;   card.cardname.rstar?       end
  end

  class RightPattern < BasePattern
    register 'right', :junction_only=>true, :assigns_type=>true
    def self.label            name;  %{All "+#{name}" cards}     end
    def self.prototype_args anchor;  {:name=>"*dummy+#{anchor}"} end
    def self.anchor_name      card;  card.cardname.tag           end
  end

  class LeftTypeRightNamePattern < BasePattern
    register 'type_plus_right', :opt_keys=>[:ltype, :right], :junction_only=>true, :assigns_type=>true
    class << self
      def label name
        %{All "+#{name.to_name.tag}" cards on "#{name.to_name.left_name}" cards}
      end
      def prototype_args anchor
        { :name=>"*dummy+#{anchor.tag}",
          :loaded_left=> Card.new( :name=>'*dummy', :type=>anchor.trunk_name )
        }
      end
      def anchor_name card
        left = card.loaded_left || card.left
        type_name = (left && left.type_name) || Card[ Card::DefaultTypeID ].name
        "#{type_name}+#{card.cardname.tag}"
      end
    end
  end


  class SelfPattern < BasePattern
    register 'self', :opt_keys=>[ :self ]
    #note: does not assign type bc this causes trouble when cardtype cards have a *self set.
    def self.label            name;     %{The card "#{name}"}      end
    def self.prototype_args anchor;     { :name=>anchor }          end
    def self.anchor_name      card;     card.name                  end
    def self.anchor_id        card;     card.id                    end
  end

end
