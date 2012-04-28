module Wagn::Model::References
  
  def name_referencers(rname = key)
    Card.find_by_sql(
      "SELECT DISTINCT c.* FROM cards c JOIN card_references r ON c.id = r.card_id "+
      "WHERE (r.referenced_name = #{ActiveRecord::Base.connection.quote(rname.to_cardname.to_key)})"
    )
  end
  
  def extended_referencers
    (dependents + [self]).plot(:referencers).flatten.uniq
  end
  
  protected   
  
  def update_references_on_create
    Card::Reference.update_on_create(self)  

    # FIXME: bogus blank default content is set on hard_templated cards...
    Card.as Card::WagbotID do
      Wagn::Renderer.new(self, :not_current=>true).update_references
    end
    expire_templatee_references
  end
  
  def update_references_on_update
    Wagn::Renderer.new(self, :not_current=>true).update_references 
    expire_templatee_references
  end

  def update_references_on_destroy
    Card::Reference.update_on_destroy(self)
    expire_templatee_references
  end

  def expire_cache
    expire self
    self.hard_templatee_names.each {|c| expire(c) } if self.hard_template?
    # FIXME really shouldn't be instantiating all the following bastards.  Just need the key.
    self.dependents.each           {|c| expire(c) }
    self.referencers.each          {|c| expire(c) }
    self.name_referencers.each     {|c| expire(c) }
    # FIXME: this will need review when we do the new defaults/templating system
    #if card.changed?(:content)
  end
  
  def expire card
    if String===card
      Card.clear_cache card
    else
      card.clear_cache
    end    
  end
  
  def self.included(base)   
    super
    base.class_eval do           
      has_many :name_references, :class_name=>'Card::Reference',
        :finder_sql=>%q{SELECT * from card_references w where w.referenced_name=#{ActiveRecord::Base.connection.quote(key)}}

      has_many :in_references,:class_name=>'Card::Reference', :foreign_key=>'referenced_card_id'
      has_many :out_references,:class_name=>'Card::Reference', :foreign_key=>'card_id', :dependent=>:destroy

      has_many :in_transclusions, :class_name=>'Card::Reference', :foreign_key=>'referenced_card_id',:conditions=>["link_type in (?,?)",Card::Reference::TRANSCLUSION, Card::Reference::WANTED_TRANSCLUSION]
      has_many :out_transclusions,:class_name=>'Card::Reference', :foreign_key=>'card_id',           :conditions=>["link_type in (?,?)",Card::Reference::TRANSCLUSION, Card::Reference::WANTED_TRANSCLUSION]

      has_many :in_links, :class_name=>'Card::Reference', :foreign_key=>'referenced_card_id',:conditions=>["link_type=?",Card::Reference::LINK]
      has_many :out_links,:class_name=>'Card::Reference', :foreign_key=>'card_id',:conditions=>["link_type=?",Card::Reference::LINK]

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
    
  end
end
