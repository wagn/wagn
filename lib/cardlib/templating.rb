module Cardlib 
  module Templating  
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
    end
        
    module ClassMethods
      def template(name)
        right_template(name) || type_template(name) || default_template
      end
      
      def right_template(name='')
        return nil unless name and name.junction?
        #(tag = find_template(name.tag_name) and find_template(Cardtype.name_for(tag.type)+"+*rform")) || 
        find_template(name.tag_name+"+*rform")
      end
      
      def type_template(name, type=nil)
        ## OPTIMIZE!!!
        multi_type_template(name) || single_type_template #(name)
      end

      def single_type_template(name)
        card = find_template(name)
        card && tform(Cardtype.name_for(self.type)) || tform('Basic')
      end
      
      def multi_type_template(name)
        if name and !name.simple? 
          trunk = find_template(name.trunk_name) or return nil
          tag   = find_template(name.tag_name)   or return nil
          tform "#{Cardtype.name_for(trunk.type)}+#{Cardtype.name_for(tag.type)}"       
        end
      end
      
      def tform(name)
        find_template(name+'+*type+*content')
      end
      
      def find_template(name)
        User.as(:wagbot) { CachedCard.get_real(name) }
      end
      
      def default_template
        # FIXME -- this should be out by 1.0
        # this last case where we create a dummy defaults card should
        # ONLY come up during migration from pre templating wagns
        # -- after that we should always have a type card      
        Card::Basic.new(:content=>"", 
          :permissions=>[Permission.new(:task=>'read',:party=>::Role[:anon])] + 
            [:edit,:comment, :delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role[:auth])}
         )        
      end        
    end
    
    
    #------( this template governs me )
    
    def template 
      @template ||= right_template || type_template || self.class.default_template  
    end
    
    def right_template
      @right_template ||= self.class.right_template(name)
    end
    
    def type_template
      @type_template ||= self.class.multi_type_template(name) || single_type_template
    end
    
    def hard_template
      template.hard_template? ? template : nil
    end
    
    def single_type_template
      self.class.tform(Cardtype.name_for(self.type)) || self.class.tform('Basic')
    end
    
    def find_template(name)
      self.class.find_template(name)
    end


    #--------( I "control" a template )
    
    def templator?  #used to be template tsar
      type_templator? or right_templator?
    end
    
    def type_templator?
      attribute_card '*type+*content'
    end
    
    def right_templator?
      attribute_card( '*right+*default')  || attribute_card( '*right+*content' )
    end
    

    
    #-----( I am a template )
    
    def template?
      name && name.template_name?
    end
       
    def type_template?
      name && name.template_name? && name =~ /\*type/
    end

    def right_template?
      name && name.template_name? && name =~ /\*right/
    end
       
    def hard_template?
      !soft_template?
    end

    def soft_template?
      name && name =~ /\*default/
    end
    
    def auto_template?
      name && name =~ /\*virtual/
    end
    
    
    
    #-----( ... and I govern these cards )
    
    def real_card
      self
    end   
    
    def hard_templatees
      # FIXME: checking self.trunk.type == "Set" caused all kindof warnings..
      if self.trunk.isa?(Card::Set)
        User.as(:wagbot)  {  self.trunk.search()  }
      else
        []
      end
    end    

    # FIXME: content settings -- do we really need the reference expiration system?
    def expire_templatee_references
	    return unless respond_to?('references_expired')
      if wql=hard_templatee_wql
        condition = User.as(:wagbot) { Wql2::CardSpec.build(wql.merge(:return=>"condition")).to_sql }
        card_ids_to_update = connection.select_rows("select id from cards t where #{condition}").map(&:first)
        card_ids_to_update.each_slice(100) do |id_batch|
          connection.execute "update cards set references_expired=1 where id in (#{id_batch.join(',')})"
        end
      end
    end
    
    
    ## -------- ( setting-based content/templating ) ----------
    def content_templated?
      c = setting_card('content') and c.name.tag_name != '*default'
    end        
    
    private
    # FIXME: remove after adjusting expire_templatee_references to content_settings
    def hard_templatee_wql
      return nil unless template? and hard_template?
      wql =
        case
        when right_template?
          trunk.simple? ? {:right=>trunk.id} : {:left=>{:type=>trunk.trunk.name},:right=>trunk.tag.id}
        when type_template?
          trunk.simple? ? {:type=>trunk.name} : {:left=>{:type=>trunk.trunk.name},:right=>{:type=>trunk.tag.name}}
        end
    end
      
  end
end
