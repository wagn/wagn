module Cardlib
  module References
    module ClassMethods 
    end

    protected   
    
    def update_references_on_create  
      WikiReference.update_on_create(self)  

      # FIXME: bogus blank default content is set on hard_templated cards...
      User.as(:wagbot) {
        render_content = self.templated_content || self.content
        Renderer.new.render(self, render_content, [:raw, :update_references])   
      }
      expire_templatee_references
    end
    
    def update_references_on_update
      render_content = self.templated_content || self.content
      Renderer.new.render(self, render_content, :update_references) 
      expire_templatee_references
    end

    def update_references_on_destroy
      WikiReference.update_on_destroy(self)
      expire_templatee_references
    end

    def expire_cache
      expire(self)
      self.hard_templatees.each {|c| expire(c) }
      self.dependents.each {|c| expire(c) }
      self.referencers.each {|c| expire(c) }
      self.name_referencers.each{|c| expire(c)}
      # FIXME: this will need review when we do the new defaults/templating system
      #if card.changed?(:content)

      # this seems like oodles of unnecessary instantiations to me -efm
    end
    
    def expire(card)
      Wagn::Cache.expire_card card.key
    end
    
    def self.included(base)   
      super
      base.extend(ClassMethods)
      base.class_eval do           
        has_many :name_references, :class_name=>'WikiReference',
          :finder_sql=>%q{SELECT * from wiki_references w where w.referenced_name=#{ActiveRecord::Base.connection.quote(key)}}

        has_many :in_references,:class_name=>'WikiReference', :foreign_key=>'referenced_card_id'
        has_many :out_references,:class_name=>'WikiReference', :foreign_key=>'card_id', :dependent=>:destroy

        has_many :in_transclusions, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type in (?,?)",WikiReference::TRANSCLUSION, WikiReference::WANTED_TRANSCLUSION]
        has_many :out_transclusions,:class_name=>'WikiReference', :foreign_key=>'card_id',           :conditions=>["link_type in (?,?)",WikiReference::TRANSCLUSION, WikiReference::WANTED_TRANSCLUSION]

        has_many :in_links, :class_name=>'WikiReference', :foreign_key=>'referenced_card_id',:conditions=>["link_type=?",WikiReference::LINK]
        has_many :out_links,:class_name=>'WikiReference', :foreign_key=>'card_id',:conditions=>["link_type=?",WikiReference::LINK]

        has_many :referencers, :through=>:in_references
        has_many :referencees, :through=>:out_references

        has_many :transcluders, :through=>:in_transclusions, :source=>:referencer
        has_many :transcludees, :through=>:out_transclusions, :source=>:referencee

        has_many :linkers, :through=>:in_links, :source=>:referencer
        has_many :linkees, :through=>:out_links, :source=>:referencee
        
        
        after_create :update_references_on_create
        after_destroy :update_references_on_destroy
        after_update :update_references_on_update
        
        after_save :expire_cache
      end
      
      def name_referencers(rname = key)
        Card.find_by_sql(
          "SELECT DISTINCT c.* FROM cards c JOIN wiki_references r ON c.id = r.card_id "+
          "WHERE (r.referenced_name = #{ActiveRecord::Base.connection.quote(rname.to_key)})"
        )
      end
    end
  end
end
