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
=begin
if @patterns
  na = @patterns.detect { |p| !p.pattern_applies? }
  raise "All patterns should apply #{name} #{na.inspect}" if na
=end
      @patterns ||= @@subclasses.map { |sub|
        (n=sub.new(self)).pattern_applies? ? n : nil
      }.compact
      Rails.logger.info "patterns[#{to_s}] >> #{@patterns.map(&:set_name).inspect}"; @patterns
    end
    def set_names()      @set_names ||= patterns.map(&:set_name)   end
    def reset_patterns()
      Rails.logger.info "reset_patterns[#{name}]"
      @junction_only = @patterns = @set_names = nil end
    #def real_set_names() patterns.find_all(&:set_card).compact.map(&:set_name)    end
    def real_set_names()
      r = patterns.find_all(&:set_card).map(&:set_name).compact
      Rails.logger.info "Pats: #{set_names*" "} RSN #{r.map(&:to_s)*' '}"; r end
    def method_keys()    @method_keys ||= patterns.map(&:method_key)        end
    def css_names()      patterns.map(&:css_name).reverse*" "               end
    def junction_only?()
      !@junction_only.nil? ? @junction_only :
         @junction_only = patterns.map(&:class).find(&:junction_only?)
    end

    def label(name)
      tag = name.tag_name
      found = patterns.find { |pat|
        Rails.logger.info "label search ... #{pat} #{name}: #{tag} :: #{pat.class.key}"
        tag==pat.class.key
      } and found.label(name)
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
      sn = set_name.to_cardname
      #Rails.logger.debug "css_name #{sn.tag_name}, #{sn.trunk_name.css_name}"
      sn.tag_name.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name
    end

    def initialize(card)
      #Rails.logger.debug "card has no name" if card.name.blank?
      @card = card                          end
    #def set_missing?()   !(pattern_applies? && Card[set_name]) end
    def set_card()    raise "doesn't apply" unless pattern_applies?
      r=                   set_name && Card[set_name]
      Rails.logger.info "set_missing #{set_name} R:#{r.inspect}";r
    end
    def set_name()        self.class.key                        end
  end


  class AllPattern < SetBase
    class << self
      def key()  Wagn::Codename.name_of_code('*all')  end
      def opt_keys()                   []             end
      def label(name)                  'All Cards'    end
      def method_key_from_opts(opts)   ''             end
      def trunkless?()                 true           end
    end
    def css_name()                     "ALL"          end
    def pattern_applies?()             true           end
    def method_key()                   ''             end

    Wagn::Model::Pattern.register_class self
  end
  
  class AllPlusPattern < SetBase
    class << self
      def key() Wagn::Codename.name_of_code('*all plus')   end
      def opt_keys()                   [:all_plus]         end
      def method_key_from_opts(opts)   'all_plus'          end
      def label(name)                  'All Plus Cards'    end
      def trunkless?()                 true                end
      def junction_only?()             true                end
    end
    def css_name()                     "ALL_PLUS"          end
    def pattern_applies?()             card.cardname.junction? end
    def method_key()                   'all_plus'          end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                    Wagn::Codename.name_of_code('*type')  end
      def opt_keys()                  [:type]                           end
      def label(name)                "All #{name.trunk_name.to_s} cards" end
      def method_key_from_opts(opts) opts[:type].to_cardname.css_name+'_type'   end
    end
    def pattern_applies?()           true                                end
    def set_name() 
      r="#{card.typename.to_s}+#{self.class.key}"
      #Rails.logger.debug "type setname #{card.typename.to_s}, #{self.class.key} r:#{r.inspect}"; r
    end
    def method_key()     self.class.method_key_from_opts :type=>card.typename end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()          Wagn::Codename.name_of_code('*star')  end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def label(name)                  'Star Cards'            end
      def trunkless?()                 true                    end
    end
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
      def label(name)                  "Cards ending in +(Star Card)"   end
      def junction_only?()             true                             end
    end
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
      def label(name) r="Cards ending in +#{name.trunk_name.to_s}"       end
      def junction_only?()             true                              end
    end
    def pattern_applies?()          card.cardname.junction?              end
    def set_name()
      #Rails.logger.debug "right setname #{card.cardname.tag_name}, #{self.class.key}"
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
      def label(name)
        "Any #{name.nth_left(2)} card plus #{name.trunk_name.tag_name}"
      end
      def junction_only?()             true             end
    end
    def css_name() 'TYPE_PLUS_RIGHT-' + set_name.to_cardname.trunk_name.css_name end
    def left()             card.loaded_trunk or card.left                    end
    def pattern_applies?()
      #Rails.logger.info "LRPAp#{card.name} #{card.cardname.junction?}"
      card.cardname.junction? &&
        !!self.left
    end
    def set_name()
      raise "no left #{card&&card.name}" unless self.left
      #Rails.logger.debug "ltype right setname #{self.left.typename.to_s}+#{card.cardname.tag_name}+#{self.class.key}"
      "#{self.left.typename.to_s}+#{card.cardname.tag_name}+#{self.class.key}" end
    def method_key()
      self.class.method_key_from_opts :ltype=>self.left.typename, :right=>card.cardname.tag_name
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
      # Why is this in the class scope for all the others, but this one is broken that way?
      def label(name)                 %{Just "#{name.trunk_name}"}           end
    class << self
      #def label(name)                 %{Just "#{name.trunk_name}"}           end
      def key()                       '*self'                                end
      def opt_keys()                  [:name]                                end
      def method_key_from_opts(opts)  opts[:name].to_cardname.css_name+'_self'      end
      #def label(name)                 %{Just "#{name.trunk_name}"}           end
    end
    #FIXME!!! we do not want these to stay commented out, but they need to be
    #there so that patterns on builtins can be recognized for now. 
    # soon those cards should actually exist.  Is this now fixed????
    def pattern_applies?() card.name and !card.virtual? and !card.new_card?  end
    def set_name()
      #raise "name? #{card.cardname.to_s}, #{card.name.inspect}" if card.name.blank?
      "#{card.name}+#{self.class.key}"                  end
    def method_key()      self.class.method_key_from_opts(:name=>card.cardname)  end

    Wagn::Model::Pattern.register_class self
  end
end

