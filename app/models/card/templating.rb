module Card 
  module Templating  
    
    module ClassMethods
      def tag_template(name)
        return nil unless name and name.junction?
        Card[name.tag_name+"+*template"] 
      end          
      
    end
    
    def defaults_template 
      @template ||= tag_template || type_template
    end

    def hard_content_template
      if type_template.hard_template?
        type_template
      elsif t = tag_template and t.hard_template?
        t
      else
        nil
      end
    end

    def hard_templatees
      return [] unless template? and hard_template?  
      @tees ||= Card.find_all_by_tag_id(trunk.id) + 
        (template_for_cardtype? ? Card.const_get(trunk.codename).find(:all) : []).uniq
    end
=begin
    

    def hard_templatee?
      self.template != self and false #fixme!!
    end

    def templatee?
      self.template != self
    end  
    
=end      
    def template_tsar?
      attribute_card('*template') 
    end

    def template?
      tag and tag.name == '*template' 
    end
       
    def template_for_cardtype?
      template? and trunk.class_name == 'Cardtype'
    end
       
    def hard_template?
      extension_type=='HardTemplate'
    end
    
    def soft_template?
      extension_type=='SoftTemplate'
    end
    
    def tag_template
      @tag_template ||= self.class.tag_template(name)
    end
    
    def type_template
      # FIXME this should crawl up the hierarchy once we have one
      # FIXME the last case where we create a dummy defaults card should
      # ONLY come up during migration-- after that we should always have a type card
      @type_template ||= Card[type+"+*template"] || Card['Basic+*template'] || 
        Card::Basic.new(:content=>"", 
          :permissions=>[Permission.new(:task=>'read',:party=>::Role[:anon])] + 
            [:edit,:comment,:delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role[:auth])}
         )
        #raise("Should always have a type template!")
    end
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
    end
    
  end
end
