module Wagn::Model
  module Pattern

    @@subclasses = []

    class << self
      def register_class(klass) @@subclasses.unshift klass end
      def subclasses() @@subclasses end

      def method_key(opts)
        @@subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false; 
            return pclass.method_key_from_opts(opts) 
          end
        end
      end
    end

    def patterns()
if @patterns
  na = @patterns.detect { |p| !p.pattern_applies? }
  raise "All patterns should apply #{name} #{na.inspect}" if na
  Rails.logger.debug "patterns set #{@patterns.inspect}"
end
      @patterns ||= @@subclasses.map { |sub|
      x=(n=sub.new(self)).pattern_applies? ? n : nil
      Rails.logger.info "subc[#{n&&n.card&&n.card.name}] #{x.inspect}"; x
      }.compact
      Rails.logger.info "patterns[#{name}] #{@patterns.inspect}"; @patterns
    end
    def set_names()      @set_names ||= patterns.map(&:set_name)                    end
    def reset_patterns()
      Rails.logger.info "reset_patterns[#{name}]"
      @patterns = @set_names = nil                             end
    #def real_set_names() patterns.reject(&:set_missing?).compact.map(&:set_name)    end
    def real_set_names()
      rsn1 = patterns.reject(&:set_missing?)
      Rails.logger.info "RSN1 #{rsn1.inspect}"
      rsn = rsn1.map(&:set_name)
      #patterns.reject(:set_missing?).map(&:set_name)
      Rails.logger.info "RSN #{rsn1.inspect} #{rsn.inspect}"; rsn
    end
    def method_keys()    @method_keys ||= patterns.map(&:method_key)                end
    def css_names()      patterns.map(&:css_name).reverse*" "                       end

    def label(name)
      patterns.map do |pat|
        return pat.label(name) if name.tag_name==pat.class.key
      end
      return nil
    end
  end


  class SetBase
    attr_accessor :card

    class << self
      def key()                      nil   end
      def opt_keys()                 []    end
      def method_key_from_opts(opts) ''    end
      def label(name)                ''    end
      def trunkless?()               false end
    end

    def css_name()
      sn = set_name
      sn.tag_name.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name
    end

    def initialize(card) @card = card                          end
    def set_missing?()   !(pattern_applies? && Card[set_name]) end
  end


  class AllPattern < SetBase
    class << self
      def key()                        '*all'       end
      def opt_keys()                   []           end
      def label(name)                  'All Cards'  end
      def method_key_from_opts(opts)   ''           end
      def trunkless?()                 true         end
    end
    def css_name()                     "ALL"        end
    def pattern_applies?()             true         end
    def set_name()                   self.class.key end
    def method_key()                   ''           end

    Wagn::Model::Pattern.register_class self
  end
  
  class AllPlusPattern < SetBase
    class << self
      def key()                        '*all plus'      end
      def opt_keys()                   [:all_plus]      end
      def method_key_from_opts(opts)   'all_plus'       end
      def label(name)                  'All Plus Cards' end
      def trunkless?()                 true             end
    end
    def css_name()                     "ALL_PLUS"       end
    def pattern_applies?()             card.junction?   end
    def set_name()                     self.class.key   end
    def method_key()                   'all_plus'       end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                        '*type'                           end
      def opt_keys()                   [:type]                           end
      def label(name)                 "All #{name.trunk_name} cards"     end
      def method_key_from_opts(opts) opts[:type].to_s.css_name+'_type'   end
    end
    def pattern_applies?()           true                                end
    def set_name()                  "#{card.typename}+#{self.class.key}" end
    def method_key()     self.class.method_key_from_opts :type=>card.typename end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()                        '*star'                 end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def label(name)                  'Star Cards'            end
      def trunkless?()                 true                    end
    end
    def css_name()                     "STAR"                  end
    def pattern_applies?()             card.star?              end
    def set_name()                     self.class.key          end
    def method_key()                   'star'                  end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                        '*rstar'                         end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'star'                           end
      def trunkless?()                 true                             end
      def label(name)                  "Cards ending in +(Star Card)"   end
    end
    def pattern_applies?()   card.junction? && card.name.tag_name.star? end
    def set_name()          "#{card.name.tag_name}+#{self.class.key}"   end
    def method_key()                   'star'                           end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                          '*right'                        end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts) opts[:right].to_s.css_name+'_right' end
      def label(name)              "Cards ending in +#{name.trunk_name}" end
    end
    def pattern_applies?()               card.junction?                  end
    def set_name()            "#{card.name.tag_name}+#{self.class.key}"  end
    def method_key() self.class.method_key_from_opts :right=>card.name.tag_name end

    Wagn::Model::Pattern.register_class self
  end

  class LeftTypeRightNamePattern < SetBase
    class << self
      def key()              '*type plus right'                              end
      def opt_keys()         [:ltype, :right]                                end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_s.css_name}_#{opts[:right].to_s.css_name}_typeplusright}
      end
      def label(name)
        "Any #{name.trunk_name.trunk_name} card plus #{name.trunk_name.tag_name}"
      end
    end
    def css_name()         'TYPE_PLUS_RIGHT-' + set_name.trunk_name.css_name end
    def left()             card.loaded_trunk || card.left                    end
    def pattern_applies?() card.junction? && !!(left)                        end
    def set_name()
      raise "no left #{card&&card.name}" unless left
      "#{left.typename}+#{card.name.tag_name}+*type plus right" end
    def method_key()
      self.class.method_key_from_opts :ltype=>left.typename, :right=>card.name.tag_name
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
    class << self
      def key()                       '*self'                                end
      def opt_keys()                  [:name]                                end
      def method_key_from_opts(opts)  opts[:name].to_s.css_name+'_self'      end
      def label(name)                 %{Just "#{name.trunk_name}"}           end
    end
    #FIXME!!! we do not want these to stay commented out, but they need to be
    #there so that patterns on builtins can be recognized for now. 
    # soon those cards should actually exist.  Is this now fixed????
    def pattern_applies?() card.name and !card.virtual? and !card.new_card?  end
    def set_name()         "#{card.name}+#{self.class.key}"                  end
    def method_key()      self.class.method_key_from_opts(:name=>card.name)  end

    Wagn::Model::Pattern.register_class self
  end
end

