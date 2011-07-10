module Wagn
  class Pattern
    @@subclasses = []
    cattr_accessor :key

    class << self
      def cache
        @@cache ||= {}
        @@cache[System.wagn_name] ||= {}
      end

      def reset_cache
        @@cache ||= {}
        @@cache[System.wagn_name] = {}
      end

      def register_class klass
        @@subclasses.unshift klass
      end

      def subclasses
        @@subclasses
      end

      def rule_modules(card)
        @@subclasses.reverse.each do |subclass|
          if subclass.pattern_applies?(card)     and
                mod = subclass.rule_module(card) and
                mod =~ /::\w+$/                  and
              const = suppress(NameError) { eval( mod ) }
            yield const
          end
        end
      end

      def method_key(opts)
        @@subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false; 
            return pclass.method_key_from_opts(opts) 
          end
        end
      end

      def generate_cache_key card
        name = card.name
        left = (name && name.junction?) ? (card.loaded_trunk || card.left) : nil
        left_key = left ? left.typecode : ''
        cache_key = "#{name}-#{card.typecode}-#{left_key}-#{card.new_card?}"
      end

      def set_names card
        cache_key = "SETNAMES-#{generate_cache_key card}"
        self.cache[cache_key] ||= generate_set_names(card)
      end

      def generate_set_names card
raise "no card" unless card
        @@subclasses.map do |pclass|
          pclass.pattern_applies?(card) and
          pclass.set_name(card) or nil
        end.compact
      end

      def method_keys card
        cache_key = "METHODKEYS-#{generate_cache_key card}"
        self.cache[cache_key] ||= generate_method_keys(card)
      end

      def generate_method_keys card
        @@subclasses.map do |pclass| 
          pclass.pattern_applies?(card) ? pclass.method_key(card) : nil
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
      
      def trunkless?
        false
      end
    end
    
    
    attr_reader :spec

    def initialize spec
      @spec = spec
    end

  end

  class AllPattern < Pattern
    class << self
      def key()                       '*all'             end
      def opt_keys()                   []                end
      def pattern_applies?(card)       true              end
      def set_name(card)               key               end
      def method_key(card)             ''                end
      def method_key_from_opts(opts)   ''                end
      def css_name(card)               "ALL"             end
      def label(name)                  'All Cards'       end
      def trunkless?()                 true              end
      # maybe this one isn't necessary, because we already include lots in base class?
      def rule_module(card)            "Wagn::Set::All"  end
    end
    register_class self
  end
  
  class AllPlusPattern < Pattern
    class << self
      def key()                        '*all plus'                   end
      def opt_keys()                   [:all_plus]                   end
      def pattern_applies?(card)       card.junction?                end
      def set_name(card)               key                           end
      def method_key(card)             'all_plus'                    end
      def method_key_from_opts(opts)   'all_plus'                    end
      def css_name(card)               "ALL_PLUS"                    end
      def label(name)                  'All Plus Cards'              end
      def trunkless?()                 true                          end
      def rule_module(card)            "Wagn::Set::AllPlus"          end
    end
    register_class self
  end

  class TypePattern < Pattern
    class << self
      def key()                        '*type'                            end
      def opt_keys()                   [:type]                            end
      def pattern_applies?(card)       true                               end
      def set_name(card)              "#{card.cardtype_name}+#{key}"      end
      def label(name)                 "All #{name.trunk_name} cards"      end
      def method_key(card) method_key_from_opts :type=>card.cardtype_name end
      def method_key_from_opts(opts)  opts[:type].to_s.css_name+'_type'   end
      def rule_module(card)           "Wagn::Set::Type::#{card.typecode}" end
    end
    register_class self
  end

  class StarPattern < Pattern
    class << self
      def key()                        '*star'                 end
      def opt_keys()                   [:star]                 end
      def pattern_applies?(card)       card.star?              end
      def set_name(card)               key                     end
      def method_key(card)             'star'                  end
      def method_key_from_opts(opts)   'star'                  end
      def css_name(card)               "STAR"                  end
      def label(name)                  'Star Cards'            end
      def trunkless?()                 true                    end
      def rule_module(card)            "Wagn::Set::Star"       end
    end
    register_class self
  end

  class RstarPattern < Pattern
    class << self
      def key()                        '*rstar'                                end
      def opt_keys()                   [:rstar]                                end
      def method_key(card)             'star'                                  end
      def method_key_from_opts(opts)   'star'                                  end
      def set_name(card)               "#{card.name.tag_name}+#{key}"          end
      def trunkless?()                 true                                    end
      def pattern_applies?(card) card.junction? && card.name.tag_name.star?    end
      def label(name)                  "Cards ending in +(Star Card)"          end
      # I think this should strip the *, but the * should be in codename, right?
      def rule_module(card)
        return unless tagcard = Card.fetch(card.name.tag_name) and
                       tagkey = tagcard.key.gsub(/^\*/,'X')
        #Rails.logger.debug "rule_module RStar #{tagkey.camelcase}"
        "Wagn::Set::Rstar::#{tagkey.camelcase}" end
    end
    register_class self
  end


  class RightNamePattern < Pattern
    class << self
      def key()                          '*right';                          end
      def opt_keys()                     [:right];                          end
      def pattern_applies?(card)         card.junction?;                    end
      def set_name(card)                 "#{card.name.tag_name}+#{key}";    end
      def method_key(card) method_key_from_opts :right=>card.name.tag_name; end
      def method_key_from_opts(opts)   opts[:right].to_s.css_name+'_right'; end
      def label(name)                "Cards ending in +#{name.trunk_name}"; end
      def rule_module(card)
        # this should be codename based
        return unless tagcard = Card.fetch(card.name.tag_name) and
                       tagkey = tagcard.key.gsub(/^\*/,'X')
        #Rails.logger.debug "rule_module Rname #{tagkey.camelcase}"
        "Wagn::Set::Right::#{tagkey.camelcase}"
      end
    end
    register_class self
  end

  class LeftTypeRightNamePattern < Pattern
    class << self
      def key()                  '*type plus right';               end
      def opt_keys()             [:ltype, :right];                 end
      def pattern_applies?(card) card.junction? && !!(left(card)); end
      def left(card)             card.loaded_trunk || card.left;   end
      def set_name(card)
        "#{left(card).cardtype_name}+#{card.name.tag_name}+*type plus right"
      end
      def css_name(card) 'TYPE_PLUS_RIGHT-' + set_name(card).trunk_name.css_name; end
      def method_key(card)
        method_key_from_opts :ltype=>left(card).cardtype_name, :right=>card.name.tag_name
      end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_s.css_name}_#{opts[:right].to_s.css_name}_typeplusright}
      end
      def label(name)
        "Any #{name.trunk_name.trunk_name} card plus #{name.trunk_name.tag_name}"
      end
      def rule_module(card)
        return unless tagcard = Card.fetch(card.name.tag_name) and
                       tagkey = tagcard.key.gsub(/^\*/,'X')

        #Rails.logger.debug "rule_module LtypeRname #{left(card).typecode} #{tagkey.camelcase}"
        "Wagn::Set::LTypeRight::#{left(card).typecode.camelcase+
                                  tagkey.camelcase}"
      end
    end
    register_class self
  end

  class SoloPattern < Pattern
    class << self
      def key() '*self'; end

      def pattern_applies? card
        #FIXME!!! we do not want these to stay commented out, but they need to be there so that patterns on builtins can be recognized for now. 
        # soon those cards should actually exist.
        card.name and !card.virtual? and !card.new_card?
      end
      
      def opt_keys() [:name]; end
      def set_name(card) "#{card.name}+#{key}"; end
      def method_key(card) method_key_from_opts :name=>card.name; end
      def method_key_from_opts(opts) opts[:name].to_s.css_name+'_self'; end
      def label(name) "Just \"#{name.trunk_name}\""; end
      def rule_module(card)
        return unless card.simple?
        "Wagn::Set::Self::#{(card.codename||card.name).camelize}"; end
    end
    register_class self
  end

end

