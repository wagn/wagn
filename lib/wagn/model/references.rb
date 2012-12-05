module Wagn
 module Model::References
  include Card::ReferenceTypes

  def name_referencers(rname = key)
    Card.find_by_sql(
      "SELECT DISTINCT c.* FROM cards c JOIN card_references r ON c.id = r.card_id "+
      "WHERE (r.referenced_name = #{ActiveRecord::Base.connection.quote(rname.to_name.key)})"
    )
  end

  def extended_referencers
    #fixme .. we really just need a number here.
    (dependents + [self]).plot(:referencers).flatten.uniq
  end

  def referencers
    Card::Reference.where( :referenced_card_id => id ).map(&:card_id ).map &Card.method( :fetch )
  end

  def referencees
    Card::Reference.where( :card_id => id ).map(&:referenced_name ).map &Card.method( :fetch )
  end

  def transcluders
    Card::Reference.where( :referenced_card_id => id, :ref_type => TRANSCLUDE ).map(&:card_id ).map &Card.method( :fetch )
  end

  protected

  def update_references_on_create
    Card::Reference.update_on_create self

    # FIXME: bogus blank default content is set on hard_templated cards...
    Account.as_bot do
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
      after_create :update_references_on_create
      after_destroy :update_references_on_destroy
      after_update :update_references_on_update
    end

  end
 end
end
