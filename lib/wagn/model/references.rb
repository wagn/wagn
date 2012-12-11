module Wagn
 module Model::References
  include Card::ReferenceTypes

  def name_referencers ref_name=nil
    ref_name = ref_name.nil? ? key : ref_name.to_name.key
    
    #warn "name refs for #{ref_name.inspect}"
    r=Card.all( :joins => :out_references, :conditions => { :card_references => { :referenced_name => ref_name } } )
    #warn "name refs #{inspect} ::  #{r.map(&:inspect)*', '}"; r
  end

  def extended_referencers
    # FIXME .. we really just need a number here.
    (dependents + [self]).map(&:referencers).flatten.uniq
  end

  # ---------- Referenced cards --------------

  def referencers
    #warn "ncers #{inspect} :: #{references.inspect}"
    return [] unless refs = references
    #warn "ncers 2 #{inspect} :: #{refs.inspect}"
    refs.map(&:card_id).map( &Card.method(:fetch) )
  end

  def transcluders
    return [] unless refs = transcludes
    #warn "clders #{inspect} :: #{refs.inspect}"
    refs.map(&:card_id).map( &Card.method(:fetch) )
  end

  def existing_referencers
    return [] unless refs = references
    #warn "e ncers #{inspect} :: #{refs.inspect}"
    refs.map(&:referenced_name).map( &Card.method(:fetch) ).compact
  end

  def existing_transcluders
    return [] unless refs = transcludes
    #warn "e clders #{inspect} :: #{refs.inspect}"
    refs.map(&:referenced_name).map( &Card.method(:fetch) ).compact
  end

  # ---------- Referencing cards --------------

  def referencees
    return [] unless refs = out_references
    #warn "cees #{inspect} :: #{refs.inspect}"
    refs. map { |ref| Card.fetch ref.referenced_name, :new=>{} }
  end

  def transcludees
    return [] unless refs = out_transcludes
    #warn "cldees #{inspect} :: #{refs.inspect}"
    refs.map { |ref| Card.fetch ref.referenced_name, :new=>{} }
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

      # ---------- Reference associations -----------
      has_many :references,  :class_name => :Reference, :foreign_key => :referenced_card_id
      has_many :transcludes, :class_name => :Reference, :foreign_key => :referenced_card_id,
        :conditions => { :ref_type => TRANSCLUDE }

      has_many :out_references,  :class_name => :Reference, :foreign_key => :card_id
      has_many :out_transcludes, :class_name => :Reference, :foreign_key => :card_id, :conditions => { :ref_type => TRANSCLUDE }

      after_create  :update_references_on_create
      after_destroy :update_references_on_destroy
      after_update  :update_references_on_update
    end

  end
 end
end
