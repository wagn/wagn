module Wagn::Model::References

  def name_referencers(rname = key)
    Card.find_by_sql(
      "SELECT DISTINCT c.* FROM cards c JOIN card_references r ON c.id = r.card_id "+
      "WHERE (r.referenced_name = #{ActiveRecord::Base.connection.quote(rname.to_cardname.key)})"
    )
  end

  def extended_referencers
    (dependents + [self]).plot(:referencers).flatten.uniq
  end

  protected

  def update_references_on_create
    Card::Reference.update_on_create(self)

    # FIXME: bogus blank default content is set on hard_templated cards...
    Session.as_bot do
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



  def self.included(base)
    super
    base.class_eval do

      has_many :in_references,:class_name=>'Card::Reference', :foreign_key=>'referenced_card_id'
      has_many :out_references,:class_name=>'Card::Reference', :foreign_key=>'card_id', :dependent=>:destroy

      has_many :in_transclusions, :class_name=>'Card::Reference', :foreign_key=>'referenced_card_id',:conditions=>["link_type in (?,?)",Card::Reference::TRANSCLUSION, Card::Reference::WANTED_TRANSCLUSION]
      has_many :out_transclusions,:class_name=>'Card::Reference', :foreign_key=>'card_id',           :conditions=>["link_type in (?,?)",Card::Reference::TRANSCLUSION, Card::Reference::WANTED_TRANSCLUSION]

      has_many :referencers, :through=>:in_references
      has_many :transcluders, :through=>:in_transclusions, :source=>:referencer

      has_many :referencees, :through=>:out_references
      has_many :transcludees, :through=>:out_transclusions, :source=>:referencee # used in tests only

      after_create :update_references_on_create
      after_destroy :update_references_on_destroy
      after_update :update_references_on_update

    end

  end
end
