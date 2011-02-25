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

      def pattern_key(opts)
        subclasses.each do |pclass|
          if pk=pclass.pattern_key(opts); return pk end
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

      def codenames card, view
        @@subclasses.map do |pclass|
          pclass.pattern_applies?(card) and codename = pclass.codename(card)
          next unless codename
          codename = (codename.blank? ? view : "#{codename}_#{view}").to_sym
          block_given? ? yield(codename) : codename
        end
      end

      def set_names card
r=
        card.new_record? ? generate_set_names(card) :
          (@@cache[(card.name ||"") + (card.type||"")] ||= generate_set_names(card))
Rails.logger.info "set_names #{card&&card.name} #{r.inspect}"; r
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

      def pattern_applies? card
        true
      end

      def set_name card
        key
      end

      def codename(card) '' end

      def pattern_key(opts)
        opts.empty? && ''
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

      def pattern_applies? card
        true
      end

      def set_name card
        "#{card.cardtype_name}+#{key}"
      end

      def codename(card) "#{card.cardtype_name}_type" end #FIXME codename

      def pattern_key(opts)
        if opts.has_key?(:type)
          opts.delete(:type).to_s.gsub('+','_').to_key+'_type'
        end
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

      def pattern_applies? card
        card.name && card.name.junction?
      end

      def set_name card
        "#{card.name.tag_name}+#{key}"
      end

      def codename(card) "#{card.name.tag_name}_right" end

      def pattern_key(opts)
        if opts.has_key?(:right)
          opts.delete(:right).to_s.gsub('+','_').to_key+'_right'
        end
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

      def pattern_applies? card
        card.name && card.name.junction? && left(card)
      end

      def left card
        card.loaded_trunk || card.left
      end

      def set_name card
        "#{left(card).cardtype_name}+#{card.name.tag_name}+*type plus right"
      end

      def codename(card) "#{left(card).cardtype_name}_#{card.name.tag_name}_ltype_rt" end

      def css_name card
        'LTYPE_RIGHT-' + set_name(card).trunk_name.css_name
      end

      def pattern_key(opts)
        if opts.has_key?(:ltype) and opts.has_key?(:right)
          %{#{
            opts.delete(:ltype).to_s.gsub('+','_').to_key
          }_#{
            opts.delete(:right).to_s.gsub('+','_').to_key
          }_ltype_rt}
        end
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
        card.name and !card.virtual? and !card.new_record?
      end

      def set_name card
        "#{card.name}+#{key}"
      end

      def codename(card) "#{card.name}_self" end

      def pattern_key(opts)
        if opts.has_key?(:name)
          opts.delete(:name).to_s.gsub('+','_').to_key+'_self'
        end
      end

      def label name
        "Just \"#{name.trunk_name}\""
      end
    end
    register_class self
  end

end

