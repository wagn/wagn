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
      @set_mods_loaded = @junction_only = @patterns = @method_keys =
        @set_names = @template = @virtual = nil
    end
    def set_names()      @set_names ||= patterns.map(&:set_name)     end
    def method_keys()    @method_keys ||= patterns.map(&:method_key) end
    def css_names()      patterns.map(&:css_name).reverse*" "        end
    def real_set_names()
      rsn=(sn=set_names).find_all { |set_name| Card.exists? set_name }
      #warn "rsn = #{rsn.inspect}, sn = #{sn.inspect}"; rsn
    end
  end


  class SetBase
    attr_accessor :card

    class << self
      def key()                      nil   end
      def opt_keys()                 []    end
      def method_key_from_opts(opts) ''    end
      def trunkless?()               false end
      def junction_only?()           false end
      def label(name)                ''    end
      def prototype_args(base)       {}    end
    end

    def css_name()
      sn = set_name.to_cardname
      #Rails.logger.debug "css_name #{sn.tag_name}, #{sn.trunk_name.css_name}"
      sn.tag_name.to_s.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name.to_s
    end

    def initialize(card) @card = card                          end
    def set_name()        self.class.key                        end
  end


  class AllPattern < SetBase
    class << self
      def key()                Wagn::Codename['*all'] end
      def opt_keys()                   []             end
      def method_key_from_opts(opts)   ''             end
      def trunkless?()                 true           end
      def label(name)                  'All Cards'    end
    end
    def css_name()                     "ALL"          end
    def pattern_applies?()             true           end
    def method_key()                   ''             end

    Wagn::Model::Pattern.register_class self
  end
  
  class AllPlusPattern < SetBase
    class << self
      def key()                     Wagn::Codename['*all_plu'] end
      def opt_keys()                   [:all_plus]             end
      def method_key_from_opts(opts)   'all_plus'              end
      def trunkless?()                 true                    end
      def junction_only?()             true                    end
      def label(name)                  'All Plus Cards'        end
      def prototype_args(base)         {:name=>'+'}            end
    end
    def css_name()                     "ALL_PLUS"              end
    def pattern_applies?()             card.cardname.junction? end
    def method_key()                   'all_plus'              end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                     Wagn::Codename['*type']                 end
      def opt_keys()                [:type]                                 end
      def method_key_from_opts(ops) ops[:type].to_cardname.css_name+'_type' end
      def label(name)               "All #{name} cards"                     end
      def prototype_args(base)      {:type=>base}                           end
    end
    def pattern_applies?()          true                                    end
    def set_name()                  "#{card.typename}+#{self.class.key}"    end
    def method_key()   self.class.method_key_from_opts :type=>card.typename end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()                        Wagn::Codename['*star'] end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def trunkless?()                 true                    end
      def label(name)                  'Star Cards'            end
      def prototype_args(base)         {:name=>'*dummy'}       end
    end
    def css_name()                     "STAR"                  end
    def pattern_applies?()             card.cardname.star?     end
    def method_key()                   'star'                  end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                        Wagn::Codename['*rstar']         end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'rstar'                          end
      def trunkless?()                 true                             end
      def junction_only?()             true                             end
      def label(name)                  "Cards ending in +(Star Card)"   end
      def prototype_args(base)         {:name=>'*dummy+*dummy'}         end
    end
    def pattern_applies?()
      card.cardname.junction? && card.cardname.tag_star?
    end
    def method_key()                   'rstar'                          end
    def set_name()                     self.class.key                   end
    def method_key()                   'star'                           end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                         Wagn::Codename['*right']         end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts)
        opts[:right].to_cardname.css_name+'_right'
      end
      def junction_only?()             true                              end
      def label(name)                  "Cards ending in +#{name}"        end
      def prototype_args(base)         {:name=>"*dummy+#{base}"}         end
    end
    def pattern_applies?()          card.cardname.junction?              end
    def set_name()        "#{card.cardname.tag_name}+#{self.class.key}"  end
    def method_key()
      self.class.method_key_from_opts :right=>card.cardname.tag_name
    end

    Wagn::Model::Pattern.register_class self
  end

  class LeftTypeRightNamePattern < SetBase
    class << self
      def key()              Wagn::Codename['*type_plu_right']              end
      def opt_keys()         [:ltype, :right]                                end
      def junction_only?()   true                                            end
      def label(name) "Any #{name.left_name} card plus #{name.tag_name}"     end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{
            opts[:right].to_cardname.css_name}_typeplusright}
      end
      def prototype_args(base)
        { :name=>"*dummy+#{base.tag_name}",
          :loaded_trunk=> Card.new( :name=>'*dummy', :type=>base.trunk_name ) }
      end
    end
    def css_name()
      "TYPE_PLUS_RIGHT-#{set_name.to_cardname.trunk_name.css_name}"
    end
    def left_name()        card.left.cardname or card.cardname.left_name end
    def left_type()        (lft=self.left) ? lft.typename : 'Basic'      end
    def left()             card.loaded_trunk or card.left                end
    def pattern_applies?() card.cardname.junction?                       end
    def set_name()
      "#{left_type}+#{card.cardname.tag_name}+#{self.class.key}"
    end
    def method_key()
      self.class.method_key_from_opts :ltype=>left_type,
                                      :right=>card.cardname.tag_name
    end


    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
      # Why is this in the class scope for all the others, but this one is broken that way?
    class << self
      def key()                      '*self'                                 end
      def opt_keys()                 [:name]                                 end
      def method_key_from_opts(opts) opts[:name].to_cardname.css_name+'_self' end
      def label(name)                %{The card "#{name}"}                   end
      def prototype_args(base)       { :name=>base }                         end
    end
    
    #FIXME!!! we do not want these to stay commented out, but they need to be
    #there so that patterns on builtins can be recognized for now. 
    # soon those cards should actually exist.  Is this now fixed????
    def pattern_applies?()           !card.new_card?                         end
    def set_name()                   "#{card.name}+#{self.class.key}"        end
    def method_key()  self.class.method_key_from_opts(:name=>card.cardname)  end

    Wagn::Model::Pattern.register_class self
  end
end

