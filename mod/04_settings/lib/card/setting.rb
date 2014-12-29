# -*- encoding : utf-8 -*-

# Used to extend setting modules like Card::Set::Self::Create in the settings mod

class Card
  module Setting
    # Let M = Card::Setting           (module)
    #     E = Card::Set::Self::Create (module extended with M)
    #     O = Card["*create"]         (object)
    attr_accessor :codename                                                # accessible in E
    mattr_accessor :groups, :group_names, :user_specific                   # accessible in E and M 
    def self.extended(host_class)     
       host_class.mattr_accessor :restricted_to_type, :rule_type_editable  # accessible in E and O
    end
    
    @@groups = { :permission =>[], :look_and_feel=>[], :communication => [], :pointer=>[], :other =>[] }
    @@group_names = {
      :permission    => "Permission",
      :look_and_feel => "Look and Feel",
      :communication => "Communication",
      :pointer       => "Pointer",
      :other         => "Other"  
    }
    @@user_specific = ::Set.new

    def self.user_specific? codename
      @@user_specific.include? codename
    end
    
    def to_type_id type
      type.is_a?(Fixnum) ? type : Card::Codename[type]
    end
    
    # usage:
    # setting_opts :group              => :permission | :look_and_feel | ...
    #              :position           => <Fixnum> (starting at 1, default: add to end)
    #              :rule_type_editable => true | false (default: false)
    #              :restricted_to_type => <cardtype> | [ <cardtype>, ...] 
    def setting_opts opts
      group = opts[:group] || :other
      @@groups[group] ||= []
      if opts[:position]
        if @@groups[group][opts[:position]-1]
          @@groups[group].insert(opts[:position]-1, self)
        else
          @@groups[group][opts[:position]-1] = self
        end
      else
        @@groups[group] << self
      end
  
      @codename = opts[:codename] || self.name.match(/::(\w+)$/)[1].underscore.to_sym
      self.rule_type_editable = opts[:rule_type_editable]
      self.restricted_to_type = opts[:restricted_to_type] ? ::Set.new([opts[:restricted_to_type]].flatten.map{ |cardtype| to_type_id(cardtype) }) : false
      if opts[:user_specific]
        @@user_specific << @codename
      end
    end
    
    def applies_to_cardtype type_id
      !self.restricted_to_type or self.restricted_to_type.include? type_id
    end
  end
end

