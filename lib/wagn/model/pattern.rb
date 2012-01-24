module Wagn::Model
  module Pattern

    @@subclasses = []

    class << self
      def register_class(klass) @@subclasses.unshift klass end

      def method_key(opts)
        @@subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false;
            return pclass.method_key_from_opts(opts)
          end
        end
      end
    end

#    def before_save_rule()
#      # do LTypeRightPattern need deeper checks?
#      rule? && left.reset_patterns()
#      Rails.logger.debug "before_save_rule: #{name}, #{rule?}"
#    end
#    def reset_patterns_if_rule() rule? && reset_patterns()
#      Rails.logger.debug "after_save_rule: #{name}, #{rule?}"
#    end

    def reset_patterns()
#      Rails.logger.debug "reset_patterns[#{name}]"
      @rule_cards={}
      @real_set_names = @set_mods_loaded = @junction_only = @patterns = @set_modules =
         @method_keys = @set_names = @template = @skip_type_lookup = nil
      true
#      Rails.logger.debug "reset_patterns[#{name}] #{inspect}"
    end

    def patterns()
      @patterns ||= @@subclasses.map { |sub| sub.new(self) }.compact
    end
    def patterns_with_new()
      new_card? ? patterns_without_new[1..-1] : patterns_without_new()
    end
    alias_method_chain :patterns, :new

    def set_names() @set_names ||= patterns_without_new.map(&:set_name) end
    def set_names_with_new()
      r=new_card? ? set_names_without_new[1..-1] : set_names_without_new()
      #warn "set_names #{new_card?}: #{r*', '}"; r
    end
    alias_method_chain :set_names, :new

    def real_set_names()
      rsn=set_names.find_all { |set_name| Card.exists? set_name }
      #warn "real sets #{rsn*', '}"; rsn
    end

    def method_keys()    @method_keys ||= patterns.map(&:method_key)        end

    def css_names()      patterns.map(&:css_name).reverse*" "               end

    def junction_only?()
      !@junction_only.nil? ? @junction_only :
         @junction_only = patterns.map(&:class).find(&:junction_only?)
      #@junction_only ||= patterns.map(&:class).find(&:junction_only?)
    end

    def set_modules()
      #warn "including set modules for #{name}"
      #raise "no type #{cardname.inspect}" if cardname.typename.nil?
      @set_modules ||= begin
          v1=patterns_without_new.reverse
          v2=v1.map(&:set_const)
          
      #warn (Rails.logger.debug "set_mods[#{name}] :#{v2.inspect}, #{v2.compact.inspect}, #{v1.inspect}"); v2.compact
      end
=begin
        |pattern|
          if mod = pattern.set_module # and
            warn (Rails.logger.debug "set_mod[#{name}] #{pattern.inspect}, #{mod}")
            #const = suppress(NameError) do

            if mod =~ /^\w+(::\w+)+$/            and
            const = begin
                      mm=find_module mod
                      #r=(Module === mm) ? mm : nil
            warn (Rails.logger.debug "set_mod[#{cardname.inspect}]:#{mm}> #{mod} T:#{caller[0..20]*"\n"}") unless Module===mm; mm
                    rescue Exception => e
                      Rails.logger.info "include error is #{e.inspect}, #{e.backtrace*"\n"}" unless NameError === e
                      nil
              end
            end
            const
        end
      end.compact
=end
      #Rails.logger.debug "set_mods #{self}, #{self.object_id} [#{name}] #{m.map(&:to_s)*", "}"; m
    end

    def label
      found = @@subclasses.find { |sub| cardname.tag_name.to_s==sub.key }
      found and found.label(cardname.left_name)
    end
  end


  class SetBase

    def set_const() SetBase.find_module(set_module) end
=begin
    def set_const
      m2=set_module
      warn "set_mod #{m2}"
      m1=SetBase.find_module(m2)
      warn "#{inspect}.set_const: #{m1}, #{m1.inspect}"; m1
    rescue Exception => e
      return nil if NameError===e
      warn "exception #{e.inspect}" #{e.backtrace*"\n"}"
      raise e
=end

    class << self
      def find_module(mod)
        set, name = mod.split '::'
        return nil  unless name and mod1= (Wagn::Set.const_defined?(set,false) ?
           Wagn::Set.const_get(set,false) : nil)
        if mod1.const_defined?(name,false)
          mod1.const_get(name,false)
        else nil end
      rescue Exception => e
        return nil if NameError===e
        warn "exception #{e.inspect}" #{e.backtrace*"\n"}"
        raise e
      end

      def opt_keys()                 []    end
      def method_key_from_opts(opts) ''    end
      def trunkless?()               false end
      def junction_only?()           false end
      def pattern_applies?(c)        true  end
      def pattern_name(card)     key   end
      def new(card) super(card) if self.pattern_applies?(card) end
      def label(name)                ''    end
      def prototype_args(base)       {}    end
    end

    def inspect()            "<#{self.class} #{@pat_name.inspect}>"        end
    def initialize(card)
      @pat_name = Card===(pn=self.class.pattern_name(card)) ? pn : pn.to_cardname
#      Rails.logger.warn "new#pattern #{self.class}#new(#{card}) #{@pat_name}"
      self
    end
    def set_name()           @pat_name.to_s                                end
    def css_name()
      sn = @pat_name
      sn.tag_name.to_s.gsub(' ','_').gsub('*','').upcase + '-' + sn.trunk_name.css_name.to_s
    end

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
    def method_key()                   ''             end
    def set_module()                 "All" end

    Wagn::Model::Pattern.register_class self
  end

  class AllPlusPattern < SetBase
    class << self
      def key()                     Wagn::Codename['*all_plu'] end
      def opt_keys()                   [:all_plus]             end
      def method_key_from_opts(opts)   'all_plus'              end
      def trunkless?()                 true                    end
      def junction_only?()             true                    end
      def pattern_applies?(card)       card.junction?          end
      def label(name)                  'All Plus Cards'        end
      def prototype_args(base)         {:name=>'+'}            end
    end
    def css_name()                     "ALL_PLUS"              end
    def method_key()                   'all_plus'              end
    def set_module()                   "AllPlus"    end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                     Wagn::Codename['*type']                 end
      def opt_keys()                 [:type]                                end
      def method_key_from_opts(opts)
        opts[:type].to_cardname.css_name+'_type'
      end
      def label(name)                "All #{name} cards"                    end
      def prototype_args(base)       {:type=>base}                          end

      def pattern_name(card)
        #warn (Rails.logger.debug "pattern_name (type) #{card.inspect} #{card.typecode.inspect}")
        card.typecode.nil? ? 'Basic+*type' : "#{card.typename}+#{key}"
      end
    end
#    def pat_name()
#      Rails.logger.debug "pat_name( #{@pat_name.inspect} )"
#      Card===@pat_name && !@pat_name.typecode.nil? ?
#        @pat_name=self.class.pattern_name(@pat_name).to_cardname :
#        @pat_name || 'Basic+*type'.to_cardname
#    end
    def left_name()  @pat_name.left_name.to_s                                end
    def method_key() self.class.method_key_from_opts :type=>left_name        end
    def set_module()
      r="Type::#{Card.typecode_from_id(Card.type_id_from_name(@pat_name.left_name))}"
      #warn (Rails.logger.debug "set_module (type) #{@pat_name.left_name.inspect}, #{@pat_name.inspect} R:#{r}"); r
    end
    def set_name()   "#{@pat_name.left_name}+#{self.class.key}"              end

    Wagn::Model::Pattern.register_class self
  end

  class StarPattern < SetBase
    class << self
      def key()                        Wagn::Codename['*star'] end
      def opt_keys()                   [:star]                 end
      def method_key_from_opts(opts)   'star'                  end
      def trunkless?()                 true                    end
      def pattern_applies?(card)       card.cardname.star?     end
      def label(name)                  'Star Cards'            end
      def prototype_args(base)         {:name=>'*dummy'}       end
    end
    def css_name()                     "STAR"                  end
    def method_key()                   'star'                  end
    def set_module()                   "Star"                  end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                        Wagn::Codename['*rstar']         end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'rstar'                          end
      def trunkless?()                 true                             end
      def junction_only?()             true                             end
      def pattern_applies?(card)
        card.junction? && card.cardname.tag_name.to_cardname.star?
      end
      def label(name)                  "Cards ending in +(Star Card)"   end
      def prototype_args(base)         {:name=>'*dummy+*dummy'}         end
    end
    def method_key()                   'rstar'                          end
    def set_module()                   "Rstar"                          end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                         Wagn::Codename['*right']         end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts)
        opts[:right].to_cardname.css_name+'_right'
      end
      def pattern_name(card)
        "#{card.cardname.tag_name}+#{key}"
       #warn (Rails.logger.debug "pattern_name Right #{card.cardname}, #{r}"); r
      end
      def pattern_applies?(card)        card.junction?                   end
      def label(name)                  "Cards ending in +#{name}"        end
      def prototype_args(base)         {:name=>"*dummy+#{base}"}         end
      def junction_only?()             true                              end
    end
    def set_module()
      # this should be codename based
      "Right::#{(@pat_name.left_name.key.gsub(/^\*/,'X')).camelcase}"
    end
    def method_key()
      self.class.method_key_from_opts :right=>@pat_name.left_name
    end
    def set_name()            "#{@pat_name.left_name}+#{self.class.key}"  end

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
      def pattern_name(card)
        lft = card.loaded_trunk || card.left
        #warn (Rails.logger.info "pattern_name LTRN [#{card.cardname.to_s}] #{left}, #{left&&left.known?}, #{left&&left.typename}")
        typename = (lft && lft.typename) || 'Basic'
        "#{typename}+#{card.cardname.tag_name}+#{key}"
      end
      def pattern_applies?(card)     card.junction?                        end
      def label(name) "Any #{name.left_name} card plus #{name.right_name}" end
      def prototype_args(base) {:name=>base}                               end
    end
    def left_type()
      #warn "looking up left_type for #{@pat_name.inspect}.  left pattern name = #{@pat_name.left_name.left_name.inspect}"
      @pat_name.left_name.left_name.to_s || 'Basic'
      id = Card.type_id_from_name(@pat_name.left_name.left_name)
      lt = Card.typecode_from_id(id)
      #warn "left_type #{@pat_name}, #{id}, #{lt}"; lt
    end
    def method_key()
      self.class.method_key_from_opts :ltype=>left_type,
           :right=>@pat_name.left_name.tag_name
    end
    def set_module()
      #Rails.logger.debug "set_module? #{@pat_name.inspect}" unless  @pat_name.left_name
      tk=((tn = @pat_name.left_name.tag_name) and tn.to_cardname.key.gsub(/^\*/,'X'))
      #warn (Rails.logger.debug "set_module LtypeRname #{left_type} #{tk.camelcase}")
      "LTypeRight::#{left_type+tk.camelcase}"
    end
    def css_name()
      "TYPE_PLUS_RIGHT-#{set_name.to_cardname.trunk_name.css_name}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
    class << self
      def key()                      '*self'                                 end
      def opt_keys()                 [:name]                                 end
      def method_key_from_opts(opts) opts[:name].to_cardname.css_name+'_self' end
      def pattern_name(card)
#        Rails.logger.info "pattern Solo Set recursion issue? #{name}" if cardname.tag_name == key # recursion protection ?
#        return if cardname.tag_name == key # recursion protection ?
        "#{card.name}+#{key}"
      end
      def label(name)                %{The card "#{name}"}                   end
      def prototype_args(base)       { :name=>base }                         end
    end
    def method_key()
      r=self.class.method_key_from_opts(:name=>@pat_name.left_name.to_s)
      #warn "pat name for #{@pat_name}: #{r}"; r
    end
    def set_module()
      Rails.logger.info "set_mod solo#{@pat_name}: #{@pat_name.left_name.to_s.camelize}"
      #Rails.logger.info "Solo set_module #{@pat_name.codename}, #{@pat_name}"
      #"Wagn::Set::Self::#{(@pat_name.codename||@pat_name).camelize}";
      return unless @pat_name.size == 2 # simple? cards have two parts <c>+*self
      "Self::#{@pat_name.left_name.to_s.camelize}"
    end

    Wagn::Model::Pattern.register_class self
  end
end
