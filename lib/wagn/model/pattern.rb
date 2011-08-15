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
      @patterns ||= @@subclasses.map { |sub|
        x=(n=sub.new(self)).pattern_applies? ? n : nil
      #Rails.logger.info "subc[#{n&&n.card&&n.card.name}] #{x.inspect}"; x
      }.compact
      #Rails.logger.info "patterns[#{to_s}] >> #{@patterns.map(&:set_name).inspect}"; @patterns
    end
    def set_names()      @set_names ||= patterns.map(&:set_name)   end
    def reset_patterns()
      Rails.logger.debug "reset_patterns[#{name}]"
      @junction_only = @patterns = @set_names = nil end
    def real_set_names() patterns.find_all(&:set_card).compact.map(&:set_name)    end
    def method_keys()    @method_keys ||= patterns.map(&:method_key)        end
    def css_names()      patterns.map(&:css_name).reverse*" "               end
    def junction_only?()
      !@junction_only.nil? ? @junction_only :
         @junction_only = patterns.map(&:class).find(&:junction_only?)
    end

    def label(nm='')
      tag = cardname.tag_name.to_s
      found = patterns.find { |pat| tag==pat.class.key }
      found and found.label(name)
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
    end
    def label(name)                ''    end

    def css_name()
      sn = set_name.to_cardname
      #Rails.logger.debug "css_name #{sn.tag_name}, #{sn.trunk_name.css_name}"
      sn.tag_name.to_s.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name.to_s
    end

    def initialize(card) @card = card                          end
    def set_card()
raise "doesn't apply" unless pattern_applies?
      set_name && Card[set_name]
    end
    def set_name()        self.class.key                        end
  end


  class AllPattern < SetBase
    class << self
      def key()  Wagn::Codename.name_of_code('*all')  end
      def opt_keys()                   []             end
      def method_key_from_opts(opts)   ''             end
      def trunkless?()                 true           end
    end
    def label(name)                    'All Cards'    end
    def css_name()                     "ALL"          end
    def pattern_applies?()             true           end
    def method_key()                   ''             end

    Wagn::Model::Pattern.register_class self
  end
  
  class AllPlusPattern < SetBase
    class << self
      def key() Wagn::Codename.name_of_code('*all plus')       end
      def opt_keys()                   [:all_plus]             end
      def method_key_from_opts(opts)   'all_plus'              end
      def trunkless?()                 true                    end
      def junction_only?()             true                    end
    end
    def label(name)                    'All Plus Cards'        end
    def css_name()                     "ALL_PLUS"              end
    def pattern_applies?()             card.cardname.junction? end
    def method_key()                   'all_plus'              end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                      Wagn::Codename.name_of_code('*type')      end
      def opt_keys()                 [:type]                                   end
      def method_key_from_opts(opts) opts[:type].to_cardname.css_name+'_type'  end
    end
    def label(name)        "All #{card.cardname.trunk_name.to_s} cards"        end
    def pattern_applies?() true                                                end
    def set_name()         "#{card.typename.to_s}+#{self.class.key}"           end
    def method_key()      self.class.method_key_from_opts :type=>card.typename end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()          Wagn::Codename.name_of_code('*star')  end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def trunkless?()                 true                    end
    end
    def label(name)                    'Star Cards'            end
    def css_name()                     "STAR"                  end
    def pattern_applies?()             card.cardname.star?     end
    def method_key()                   'star'                  end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                  Wagn::Codename.name_of_code('*rstar')  end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'rstar'                          end
      def trunkless?()                 true                             end
      def junction_only?()             true                             end
    end
    def label(name)                    "Cards ending in +(Star Card)"   end
    def pattern_applies?() card.cardname.junction? && card.cardname.tag_star? end
    def method_key()                   'rstar'                           end
    def set_name()                     self.class.key                   end
    def method_key()                   'star'                           end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                   Wagn::Codename.name_of_code('*right')  end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts) opts[:right].to_cardname.css_name+'_right' end
      def junction_only?()             true                              end
    end
    def label(name) "Cards ending in +#{card.cardname.trunk_name.to_s}"  end
    def pattern_applies?()          card.cardname.junction?              end
    def set_name()
      "#{card.cardname.tag_name}+#{self.class.key}"  end
    def method_key() self.class.method_key_from_opts :right=>card.cardname.tag_name end

    Wagn::Model::Pattern.register_class self
  end

  class LeftTypeRightNamePattern < SetBase
    class << self
      def key()              '*type plus right'                              end
      def opt_keys()         [:ltype, :right]                                end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{opts[:right].to_cardname.css_name}_typeplusright}
      end
      def junction_only?()             true             end
    end
    def label(name)
      "Any #{card.cardname.nth_left(2).to_s} card plus #{
             card.cardname.trunk_name.tag_name.to_s}"
    end
    def css_name() "TYPE_PLUS_RIGHT-#{set_name.to_cardname.trunk_name.css_name}" end
    def left_name()        card.left.cardname or card.cardname.left_name end
    def left_type()        (lft=self.left) ? left.typename : 'Basic'     end
    def left()             card.loaded_trunk or card.left                end
    def pattern_applies?() card.cardname.junction?                       end
    def set_name()
      "#{left_type}+#{card.cardname.tag_name}+#{self.class.key}"         end
    def method_key()
      self.class.method_key_from_opts :ltype=>left_type, :right=>card.cardname.tag_name
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
      # Why is this in the class scope for all the others, but this one is broken that way?
    class << self
      def key()                      '*self'                                end
      def opt_keys()                 [:name]                                end
      def method_key_from_opts(opts) opts[:name].to_cardname.css_name+'_self' end
      
    end
    
    def label(name)                   %{Just "#{name.trunk_name}"}           end
    #FIXME!!! we do not want these to stay commented out, but they need to be
    #there so that patterns on builtins can be recognized for now. 
    # soon those cards should actually exist.  Is this now fixed????
    def pattern_applies?() card.name and !card.virtual? and !card.new_card?  end
    def label(name)                %{Just "#{card.cardname.trunk_name.to_s}"} end
    def set_name()
      #raise "name? #{card.cardname.to_s}, #{card.name.inspect}" if card.name.blank?
      "#{card.name}+#{self.class.key}"                  end
    def method_key()      self.class.method_key_from_opts(:name=>card.cardname)  end

    Wagn::Model::Pattern.register_class self
  end
end

