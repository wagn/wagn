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

    def before_save_rule()
      # do LTypeRightPattern need deeper checks?
      rule? && left.reset_patterns()
      Rails.logger.debug "before_save_rule: #{name}, #{rule?}"
    end
    def after_save_rule() rule? && reset_patterns()
      Rails.logger.debug "after_save_rule: #{name}, #{rule?}"
    end

    def set_names() @set_names ||= patterns.map(&:set_name)   end

    def reset_patterns()
      Rails.logger.debug "reset_patterns[#{name}]"
      @setting_cards={}
      @real_set_name = @set_mods_loaded = @junction_only = @patterns =
         @method_keys = @set_names = @template = nil
#      Rails.logger.debug "reset_patterns[#{name}] #{inspect}"
    end

    def patterns()
      @patterns ||= @@subclasses.map { |sub| sub.new(self) }.compact
    end

    def patterns_with_new()
      #Rails.logger.debug "patterns_with_new() #{cardname.inspect}, Bk:#{name.blank?} NC:#{!new_card?}"
      if !real?
        patterns_without_new[1..-1]
      else
        patterns_without_new()
      end
    end
    alias_method_chain :patterns, :new

    def set_names()
      set_names ||= patterns_without_new.map(&:set_name)
    end
    def set_names_with_new()
      if !real?
        set_names_without_new[1..-1]
      else
        set_names_without_new()
      end
    end
    alias_method_chain :set_names, :new

    def real_set_names()
      #Rails.logger.warn "START real_sets for #{cardname}, #{self.patterns}, #{@patterns}"
      rr=
      #@real_set_names ||=
        self.patterns.map { |pat|
          Card.exists?(sname=pat.set_name) && sname
        }.compact
       #warn "setting real_sets for #{cardname.inspect} RR>#{rr.inspect}"; rr
    end

    def method_keys()    @method_keys ||= patterns.map(&:method_key)        end

    def css_names()      patterns.map(&:css_name).reverse*" "               end

    def junction_only?()
      @junction_only ||= patterns.map(&:class).find(&:junction_only?)
    end

    def label()
      tag_key = cardname.tag_name.to_cardname.key
      #FIXME: should be codenames, not keys here
      @@subclasses.first_value { |sub| tag_key==sub.key && sub.label() }
    end

    def set_modules()
      #raise "no type #{cardname.inspect}" if cardname.typename.nil?
      #Rails.logger.debug "set_mods[#{cardname.inspect}]"
      m=@set_modules = @set_modules || patterns_without_new.reverse.map do
        |subclass|
          if mod = subclass.set_module # and
            #Rails.logger.debug "set_mod[#{name}] #{subclass}, #{mod}"
            #const = suppress(NameError) do
            if mod =~ /^\w+(::\w+)+$/            and
            const = begin
                      mm=eval( mod )
                      r=(Module === mm) ? mm : nil
            #Rails.logger.debug "set_mod[#{cardname.inspect}]:#{mm}> #{subclass}, #{mod} R:#{r}"; r
                    rescue Exception => e
                      Rails.logger.info "include error is #{e.inspect}, #{e.backtrace*"\n"}" unless NameError === e
                      nil
              end
            end
            const
        end
      end.compact
      #Rails.logger.debug "set_mods #{self}, #{self.object_id} [#{name}] #{m.map(&:to_s)*", "}"; m
    end
  end


  class SetBase
    attr_accessor :pat_name

    class << self
      def opt_keys()                 []    end
      def method_key_from_opts(opts) ''    end
      def trunkless?()               false end
      def junction_only?()           false end
      def pattern_applies?(c)        true  end
      def pattern_name(card)     key   end
      def new(card) super if self.pattern_applies?(card) end
    end

    def inspect()            "<#{self.class} #{pat_name.inspect}>"        end
    def initialize(card)
      @pat_name = self.class.pattern_name(card).to_cardname
      #Rails.logger.warn "new#pattern #{self.class}#new(#{card}) #{@pat_name}" if card.name =~ /^Yo /
      self
    end
    def set_name()           pat_name.to_s                                end
    def css_name()
      sn = pat_name
      sn.tag_name.to_s.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name.to_s
    end

  end


  class AllPattern < SetBase
    class << self
      def key()  Wagn::Codename.name_of_code('*all')  end
      def opt_keys()                 []               end
      def method_key_from_opts(opts) ''               end
      def trunkless?()               true             end
    end
    def label()                      'All Cards'      end
    def css_name()                   "ALL"            end
    def method_key()                 ''               end
    def set_module()                 "Wagn::Set::All" end

    Wagn::Model::Pattern.register_class self
  end

  class AllPlusPattern < SetBase
    class << self
      def key() Wagn::Codename.name_of_code('*all plus')       end
      def opt_keys()                   [:all_plus]             end
      def method_key_from_opts(opts)   'all_plus'              end
      def trunkless?()                 true                    end
      def junction_only?()             true                    end
      def pattern_applies?(card)       card.junction?          end
    end
    def label()                        'All Plus Cards'        end
    def css_name()                     "ALL_PLUS"              end
    def method_key()                   'all_plus'              end
    def set_module()                   "Wagn::Set::AllPlus"    end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                      Wagn::Codename.name_of_code('*type')      end
      def opt_keys()                 [:type]                                   end
      def method_key_from_opts(opts) opts[:type].to_cardname.css_name+'_type'  end

      def pattern_name(card)
        card.type_lookup
      Rails.logger.debug "pattern_name (type) #{card.inspect} #{card.typename}"
        "#{card.typename}+#{key}"
      end
    end
    def label()      "All #{left_name} cards"                         end
    def left_name()  pat_name.left_name.to_s                          end
    def method_key() self.class.method_key_from_opts :type=>left_name end
    def set_module()
      Rails.logger.debug "set_module (type) #{left_name}, #{pat_name.inspect}"
      "Wagn::Set::Type::#{Cardtype.classname_for(left_name)}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()          Wagn::Codename.name_of_code('*star')  end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def trunkless?()                 true                    end
      def pattern_applies?(card) card.cardname.simple? and card.cardname.star? end
    end
    def label()                        'Star Cards'            end
    def css_name()                     "STAR"                  end
    def method_key()                   'star'                  end
    def set_module()                  "Wagn::Set::Star"       end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                  Wagn::Codename.name_of_code('*rstar')  end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'rstar'                          end
      def trunkless?()                 true                             end
      def junction_only?()             true                             end
      def pattern_applies?(card) card.cardname.junction? && card.cardname.tag_star? end
    end
    def label()                        "Cards ending in +(Star Card)"   end
    def method_key()                   'rstar'                          end
    def method_key()                   'star'                           end
    def set_module()                   "Wagn::Set::Rstar"               end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                   Wagn::Codename.name_of_code('*right')  end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts) opts[:right].to_cardname.css_name+'_right' end
      def junction_only?()           true                                end
      def pattern_name(card)
        r="#{card.cardname.tag_name}+#{key}"
        #Rails.logger.debug "pattern_name Right #{cardname}, #{r}"; r
      end
      def pattern_applies?(card) card.cardname.junction?                  end
    end
    def label()      "Cards ending in +#{pat_name.left_name}" end
    def method_key() self.class.method_key_from_opts :right=>pat_name.left_name end
    def set_module()
      # this should be codename based
      "Wagn::Set::Right::#{(pat_name.left_name.
        to_cardname.key.gsub(/^\*/,'X')).camelcase}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class LeftTypeRightNamePattern < SetBase
    class << self
      def key()              '*type plus right'                              end
      def opt_keys()         [:ltype, :right]                                end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{opts[:right].to_cardname.css_name}_typeplusright}
      end
      def junction_only?()   true                                            end
      def pattern_applies?(card) card.cardname.junction?                     end
      def pattern_name(card)
        #if cardname.tag_name == key # recursion protection ?
          #Rails.logger.info "pattern ? #{key} (LtRt) Set #{cardname.to_s}"
         # return cardname
        #end
        raise "Applies? #{card.cardname.to_s}" unless pattern_applies?(card)
        #left_name=card.cardname.left_name
        left = card.loaded_trunk || card.left
        #Rails.logger.info "pattern_name LTRN [#{card.cardname.to_s}] #{left}, #{left&&left.known?}, #{left&&left.typename}"
        typename = (left && left.known? && left.typename) || 'Basic'
        #typename = ((left=left_name.card) && left.known? && left.typename) || 'Basic'
        "#{typename}+#{card.cardname.tag_name}+#{key}"
      end
    end
    def label()    "Any #{left_type} card plus #{pat_name.left_name.tag_name}" end
    def left_type()
      r=pat_name.left_name.left_name.to_s || 'Basic'
      #Rails.logger.debug "left_type[#{pat_name.s}] #{r}"; r
    end
    def method_key()
      self.class.method_key_from_opts :ltype=>left_type, :right=>pat_name.left_name.tag_name
    end
    def set_module()
      #Rails.logger.debug "set_module? #{pat_name.inspect}" unless  pat_name.left_name
      tk=((tn = pat_name.left_name.tag_name) and tn.to_cardname.key.gsub(/^\*/,'X'))
      #Rails.logger.debug "set_module LtypeRname #{left_type.camelcase} #{tk.camelcase}"
      "Wagn::Set::LTypeRight::#{left_type.camelcase+tk.camelcase}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
    class << self
      def key()                      '*self'                                  end
      def opt_keys()                 [:name]                                  end
      def method_key_from_opts(opts)
        opts[:name].to_cardname.css_name+'_self'
      end
      def pattern_name(card)
#        Rails.logger.info "pattern Solo Set recursion issue? #{name}" if cardname.tag_name == key # recursion protection ?
#        return if cardname.tag_name == key # recursion protection ?
        "#{card.name}+#{key}"
      end
      def pattern_applies?(card)
        true
      end #FIXME: we need to represent plus card classnames
    end
    def label()                %{Just "#{pat_name.trunk_name.to_s}"}    end
    def method_key()
#      warn "pat name for #{pat_name}"
      self.class.method_key_from_opts(:name=>pat_name.left_name.to_s)
    end
    def set_module()
      #Rails.logger.info "set_mod solo#{pat_name}: #{pat_name.left_name.to_s.camelize}"
      #Rails.logger.info "Solo set_module #{pat_name.codename}, #{pat_name}"
      #"Wagn::Set::Self::#{(pat_name.codename||pat_name).camelize}";
      return unless pat_name.size == 2 # simple? cards have two parts <c>+*self
      "Wagn::Set::Self::#{pat_name.left_name.to_s.camelize}";
    end

    Wagn::Model::Pattern.register_class self
  end
end

