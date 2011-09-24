module Wagn::Model
  module Pattern

    @@subclasses = []
    #@@key_pattern = {}

    class << self
=begin # caching support off for start
      def included(base)
        super
        base.class_eval {
          attr_accessor :set_names, :patterns, :real_set_name, :set_modules, :settings
        }
      end
=end
    
      def subclasses() @@subclasses end
      
      def register_class(klass)
        @@subclasses.unshift klass
      end

      def method_key(opts)
        @@subclasses.each do |pclass|
          if !pclass.opt_keys.map{|key| opts.has_key?(key)}.member? false; 
            return pclass.method_key_from_opts(opts) 
          end
        end
      end
    end

    def before_save_rule()
      rule? && left.reset_patterns()
      Rails.logger.debug "before_save_rule: #{name}, #{rule?}"
    end
    def after_save_rule() rule? && reset_rules()
      Rails.logger.debug "after_save_rule: #{name}, #{rule?}"
    end
    def reset_patterns()
      #Rails.logger.debug "reset_patterns[#{name}]"
      @junction_only = @patterns = @set_names = @real_set_name = nil
    end

    def patterns()
      #raise "??? #{cardname.inspect}" unless cardname.cardinfo
      Rails.logger.warn "START patterns #{cardname.inspect}" 
      #ps= @patterns ||= @@subclasses.map { |sub|
      ps= @@subclasses.map { |sub|
        #warn " looking up #{sub} pattern for #{cardname}"
        if new_pat = sub.new(self)
          r1=new_pat.pat_name
          #warn "looking up new pattern #{new_pat}, #{r1.inspect}"
#          r2=r1.card if r1 # prefetch the card
          new_pat
        end
      }.compact
      Rails.logger.warn "END patterns #{cardname.inspect}.  #{ps.inspect}" 
      ps
    end

    def patterns_with_new()
      Rails.logger.debug "patterns_with_new() #{cardname.inspect}, Bk:#{name.blank?} NC:#{!new_card?}"
      if !real?
        patterns_without_new[1..-1]
      else
        patterns_without_new()
      end
    end
    alias_method_chain :patterns, :new

    def set_names()
      #set_names ||= patterns_without_new.map(&:set_name)
      patterns_without_new.map(&:set_name)
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
      Rails.logger.warn "START real_sets for #{cardname}, #{self.patterns}, #{@patterns}"
      rr= self.patterns.map do |pat|
        set_name = pat.set_name
        set_card = Card.fetch(set_name, :skip_virtual=>true, :skip_after_fetch=>true)
#        warn "real_sets [#{set_card.real?}] SN:#{set_card} CN:#{cardname.inspect}:"
        set_card && set_card.real? ? set_name : nil
      end.compact
#      warn "setting real_sets for #{cardname.inspect} RR>#{rr.inspect}"; rr
    end

    def method_keys()
      #self.method_keys ||= patterns_without_new.map(&:method_key)
      patterns.map(&:method_key)
    end

    def css_names()      patterns.map(&:css_name).reverse*" "               end

    def junction_only?()
         @junction_only ||= patterns.map(&:class).find(&:junction_only?)
    end

    def label(nm='')
      tag = cardname.tag_name.to_s
      @@subclasses.first_value { |sub| tag==sub.key && sub.label(cardname.trunk_name.to_s) }
#      found and found.label(name)
      
#      
#      found = patterns.first_value { |pat| pat.class.pattern_name(self) &&
#        begin
#        Rails.logger.debug "label #{cardname.left_name.to_s}, SN:#{pat.set_name}"; found
#        pat.label
#        end
#      }
    end

    #def set_modules_with_cache()
    def set_modules()
      #raise "no type #{cardname.inspect}" if cardname.typename.nil?
      Rails.logger.debug "set_mods[#{cardname.inspect}]"
      #m=self.set_modules_without_cache = cardname.set_modules_without_cache || patterns_without_new.reverse.map do
      m=patterns_without_new.reverse.map do
        |subclass|
          if mod = subclass.set_module # and
            Rails.logger.debug "set_mod[#{name}] #{subclass}, #{mod}"
            #const = suppress(NameError) do
            if mod =~ /^\w+(::\w+)+$/            and
            const = begin 
                      mm=eval( mod )
                      r=(Module === mm) ? mm : nil
            Rails.logger.debug "set_mod[#{cardname.inspect}]:#{mm}> #{subclass}, #{mod} R:#{r}"; r
                    rescue Exception => e
                      Rails.logger.info "include error is #{e.inspect}, #{e.backtrace*"\n"}" unless NameError === e
                      nil
              end
            end
            const
        end
      end.compact
      Rails.logger.debug "set_mods #{self}, #{self.object_id} [#{name}] #{m.map(&:to_s)*", "}"; m
    end
  end
  #alias_method_chain :set_modules, :cache


  class SetBase
    attr_accessor :pat_name

    class << self
      #def key()                      nil   end
      #def label()              ''                                           end
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
      Rails.logger.warn "new#pattern #{self.class}#new(#{card}) #{@pat_name}" if card.name =~ /^Yo /
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
      def label(name)                  'All Cards'    end
      def opt_keys()                   []             end
      def method_key_from_opts(opts)   ''             end
      def trunkless?()                 true           end
    end
    def css_name()                     "ALL"          end
    def method_key()                   ''             end
    def set_module()             "Wagn::Set::All"    end

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
      def label(name)                  'All Plus Cards'        end
    end
    def css_name()                     "ALL_PLUS"       end
    def method_key()                   'all_plus'       end
    def set_module()            "Wagn::Set::AllPlus"   end

    Wagn::Model::Pattern.register_class self
  end

  class TypePattern < SetBase
    class << self
      def key()                      Wagn::Codename.name_of_code('*type')      end
      def opt_keys()                 [:type]                                   end
      def method_key_from_opts(opts) opts[:type].to_cardname.css_name+'_type'  end
      def label(name)                "All #{name} cards"                       end
        
      def pattern_name(card)
        "#{card.typename}+#{key}"
      end
    end
    def left_name()       
      if @cardname && @cardname.cardinfo.fetch_type
        self.pat_name = self.class.pattern_name(@cardname).to_cardname
        @cardname = nil if self.pat_name
        Rails.logger.info "left_name #{pat_name.inspect}"
      end
      pat_name.left_name.to_s
    end
#    def css_name()         "TYPE-#{left_name}"               end
    def method_key() self.class.method_key_from_opts :type=>left_name end
    def set_module()
      typecd = Cardtype.classname_for(left_name)
      r="Wagn::Set::Type::#{typecd}"
      Rails.logger.info "set_module T #{r}"; r
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
      def label(name)                    'Star Cards'          end
    end
    def css_name()                     "STAR"                  end
    def method_key()                   'star'                  end
    def set_module()                  "Wagn::Set::Star"       end

    Wagn::Model::Pattern.register_class self
  end

  class RstarPattern < SetBase
    class << self
      def key()                  Wagn::Codename.name_of_code('*rstar')  end
      def label(name)                  "Cards ending in +(Star Card)"   end
      def opt_keys()                   [:rstar]                         end
      def method_key_from_opts(opts)   'rstar'                          end
      def trunkless?()                 true                             end
      def junction_only?()             true                             end
      def pattern_applies?(card) card.cardname.junction? && card.cardname.tag_star? end
    end
    def method_key()                   'rstar'                           end
    def method_key()                   'star'                           end
    def set_module()                  "Wagn::Set::Rstar"               end

    Wagn::Model::Pattern.register_class self
  end


  class RightNamePattern < SetBase
    class << self
      def key()                   Wagn::Codename.name_of_code('*right')  end
      def label(name)             "Cards ending in +#{name}"             end
      def opt_keys()                     [:right]                        end
      def method_key_from_opts(opts) opts[:right].to_cardname.css_name+'_right' end
      def junction_only?()           true                                end
      def pattern_name(card)
        r="#{card.cardname.tag_name}+#{key}"
        #Rails.logger.debug "pattern_name Right #{cardname}, #{r}"; r
      end
      def pattern_applies?(card) card.cardname.junction?                  end
    end
    def method_key() self.class.method_key_from_opts :right=>pat_name.left_name end
    def set_module()
      # this should be codename based
      #return unless tk = tagkey
      tk=((tn = pat_name.left_name.tag_name) and tn.to_cardname.key.gsub(/^\*/,'X'))
      Rails.logger.debug "set_module Rname #{tk.camelcase}"
      "Wagn::Set::Right::#{tk.camelcase}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class LeftTypeRightNamePattern < SetBase
    class << self
      def key()              '*type plus right'                              end
      def label(name)    "Any #{name.trunk_name} card plus #{name.tag_name}" end
      def opt_keys()         [:ltype, :right]                                end
      def method_key_from_opts(opts)
        %{#{opts[:ltype].to_cardname.css_name}_#{opts[:right].to_cardname.css_name}_typeplusright}
      end
      def junction_only?()   true                                            end
      def pattern_applies?(card) card.cardname.junction?                      end
      def pattern_name(card)
        #if cardname.tag_name == key # recursion protection ?
          #Rails.logger.info "pattern ? #{key} (LtRt) Set #{cardname.to_s}"
         # return cardname
        #end
        raise "Applies? #{card.cardname.to_s}" unless pattern_applies?(card)
        #left_name=card.cardname.left_name
        left = card.loaded_trunk || card.left
        Rails.logger.info "pattern_name LTRN [#{card.cardname.to_s}] #{left}, #{left&&left.known?}, #{left&&left.typename}"
        typename = (left && left.known? && left.typename) || 'Basic'
        #typename = ((left=left_name.card) && left.known? && left.typename) || 'Basic'
        r="#{typename}+#{card.cardname.tag_name}+#{key}"
        Rails.logger.info "set_name LTRN #{card.cardname}: #{r}"; r
      end
    end
    def left_type()
      r=pat_name.left_name.left_name.to_s || 'Basic'
      #Rails.logger.debug "left_type[#{pat_name.s}] #{r}"; r
    end


#    def css_name() "TYPE_PLUS_RIGHT-#{left_type}-#{pat_name.left_name.tag_name}"  end
    def method_key()
      self.class.method_key_from_opts :ltype=>left_type, :right=>pat_name.left_name.tag_name
    end
    def set_module()
      tk=((tn = pat_name.left_name.tag_name) and tn.to_cardname.key.gsub(/^\*/,'X'))
      Rails.logger.debug "set_module LtypeRname #{left_type.camelcase} #{tk.camelcase}"
      "Wagn::Set::LTypeRight::#{left_type.camelcase+tk.camelcase}"
    end

    Wagn::Model::Pattern.register_class self
  end

  class SoloPattern < SetBase
    class << self
      def key()                      '*self'                                  end
      def label(name)                %{Just "#{pat_name.trunk_name.to_s}"}    end
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
    def method_key()
#      warn "pat name for #{@cardname} = #{pat_name}"
      self.class.method_key_from_opts(:name=>pat_name.left_name.to_s)
    end
    def set_module()
      Rails.logger.info "set_mod solo#{pat_name}: #{pat_name.left_name.to_s.camelize}"
      #Rails.logger.info "Solo set_module #{pat_name.codename}, #{pat_name}"
      #"Wagn::Set::Self::#{(pat_name.codename||pat_name).camelize}";
      return unless pat_name.size == 2 # simple? cards have two parts <c>+*self
      "Wagn::Set::Self::#{pat_name.left_name.to_s.camelize}";
    end

    Wagn::Model::Pattern.register_class self
  end
end

