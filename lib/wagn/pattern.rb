module Wagn
  class Pattern
    @@subclasses = []
    cattr_accessor :key
    @@cache = {}

    class << self
      def reset_cache
        @@cache = {}
      end

      def register_class klass
        @@subclasses.unshift klass
      end

      def subclasses
        @@subclasses
      end
      
      def method_keys card
        @@subclasses.map do |pclass| 
          pclass.pattern_applies?(card) ? pclass.method_key(card) : nil
        end.compact
      end

      def method_key(opts)
        @@subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false; 
            return pclass.method_key_from_opts(opts) 
          end
        end
      end

      def set_keys card
        card.new_record? ? generate_set_keys(card) :
          (@@cache[(card.name ||"") + (card.type||"")] ||= generate_set_names(card))
      end

      def generate_set_keys card
        @@subclasses.map do |pclass|
          pclass.pattern_applies?(card) and pclass.set_name(card) 
        end.compact
      end

#      def codenames card, view
#        @@subclasses.map do |pclass|
#          pclass.pattern_applies?(card) and codename = pclass.codename(card)
#          next unless codename
#          codename = (codename.blank? ? view : "#{codename}_#{view}").to_sym
#          block_given? ? yield(codename) : codename
#        end
#      end

      def set_names card
        left = (card.name && card.name.junction?) ? (card.loaded_trunk || card.left) : nil
        left_key = left ? left.type : ''
        cache_key = "#{card.name}-#{card.type}-#{left_key}-#{card.new_card?}"
        if names = Card.cache.read(cache_key)
          names
        else
          names = generate_set_names(card)
          Card.cache.write(cache_key, names)
          names
        end
          
#        card.new_record? ? generate_set_names(card) : 
#          (@@cache[(card.name ||"") + (card.type||"")] ||= generate_set_names(card))
#Rails.logger.debug "set_names #{card&&card.name} #{r.inspect}"; r
      end

      def generate_set_names card
raise "no card" unless card
        @@subclasses.map do |pclass|
          pclass.pattern_applies?(card) and
          pclass.set_name(card) or nil
        end.compact
      end

      def css_names card
        @@subclasses.map do |pclass|
          pclass.pattern_applies?(card) and pclass.css_name(card) or nil
        end.compact.reverse.join(" ")
      end

      def label name
        @@subclasses.map do |pclass|
          return pclass.label(name) if pclass.match(name)
        end
        return nil
      end

      def match name
        name.tag_name==self.key
      end

      def css_name card
        sn = set_name card
        sn.tag_name.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name
      end
    end

    attr_reader :spec

    def initialize spec
      @spec = spec
    end

  end

  class AllPattern < Pattern
    class << self
      def key
        '*all'
      end
      
      def opt_keys
        []
      end

      def pattern_applies? card
        true
      end

      def set_name card
        key
      end

      def method_key card
        ''
      end

      def method_key_from_opts(opts)
        ''
      end

      def css_name card
        "ALL"
      end

      def label name
        'All Cards'
      end
    end
    register_class self
  end

  class TypePattern < Pattern
    class << self
      def key
        '*type'
      end

      def opt_keys
        [:type]
      end

      def pattern_applies? card
        true
      end

      def set_name card
        "#{card.cardtype_name}+#{key}"
      end

      def method_key card
        method_key_from_opts :type=>card.cardtype_name
      end

      def method_key_from_opts(opts)
        opts[:type].to_s.css_name+'_type'
      end

      def label name
        "All #{name.trunk_name} cards"
      end
    end
    register_class self
  end

  class RightNamePattern < Pattern
    class << self
      def key
        '*right'
      end

      def opt_keys
        [:right]
      end

      def pattern_applies? card
        card.name && card.name.junction?
      end

      def set_name card
        "#{card.name.tag_name}+#{key}"
      end

      def method_key card
        method_key_from_opts :right=>card.name.tag_name
      end

      def method_key_from_opts(opts)
        opts[:right].to_s.css_name+'_right'
      end

      def label name
        "Cards ending in +#{name.trunk_name}"
      end
    end
    register_class self
  end

  class LeftTypeRightNamePattern < Pattern
    class << self
      def key
        '*type plus right'
      end

      def opt_keys
        [:ltype, :right]
      end

      def pattern_applies? card
        card.name && card.name.junction? && left(card)
      end

      def left card
        card.loaded_trunk || card.left
      end

      def set_name card
        "#{left(card).cardtype_name}+#{card.name.tag_name}+*type plus right"
      end

      def css_name card
        'TYPE_PLUS_RIGHT-' + set_name(card).trunk_name.css_name
      end

      def method_key card
        method_key_from_opts :ltype=>left(card).cardtype_name, :right=>card.name.tag_name
      end

      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_s.css_name}_#{opts[:right].to_s.css_name}_typeplusright}
      end

      def label name
        "Any #{name.trunk_name.trunk_name} card plus #{name.trunk_name.tag_name}"
      end
    end
    register_class self
  end

  class SoloPattern < Pattern
    class << self
      def key
        '*self'
      end

      def pattern_applies? card
        #FIXME!!! we do not want these to stay commented out, but they need to be there so that patterns on builtins can be recognized for now. 
        # soon those cards should actually exist.
        card.name and !card.virtual? and !card.new_card?
      end
      
      def opt_keys
        [:name]
      end

      def set_name card
        "#{card.name}+#{key}"
      end
      
      def method_key card
        method_key_from_opts :name=>card.name
      end

      def method_key_from_opts opts
        opts[:name].to_s.css_name+'_self'
      end

      def label name
        "Just \"#{name.trunk_name}\""
      end
    end
    register_class self
  end

end

