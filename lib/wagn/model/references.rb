module Wagn
 module Model::References
  include Card::ReferenceTypes

  def name_referencers ref_name=nil
    ref_name = ref_name.nil? ? key : ref_name.to_name.key
    
    #warn "name refs for #{ref_name.inspect}"
    r=Card.all( :joins => :out_references, :conditions => { :card_references => { :referee_key => ref_name } } )
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
    refs.map(&:referer_id).map( &Card.method(:fetch) )
  end

  def includers
    return [] unless refs = includes
    #warn "clders #{inspect} :: #{refs.inspect}"
    refs.map(&:referer_id).map( &Card.method(:fetch) )
  end

=begin
  def existing_referencers
    return [] unless refs = references
    #warn "e ncers #{inspect} :: #{refs.inspect}"
    refs.map(&:referee_key).map( &Card.method(:fetch) ).compact
  end

  def existing_includers
    return [] unless refs = includes
    #warn "e clders #{inspect} :: #{refs.inspect}"
    refs.map(&:referee_key).map( &Card.method(:fetch) ).compact
  end
=end

  # ---------- Referencing cards --------------

  def referencees
    return [] unless refs = out_references
    #warn "cees #{inspect} :: #{refs.inspect}"
    refs. map { |ref| Card.fetch ref.referee_key, :new=>{} }
  end

  def includees
    return [] unless refs = out_includes
    #warn "cldees #{inspect} :: #{refs.inspect}"
    refs.map { |ref| Card.fetch ref.referee_key, :new=>{} }
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
      has_many :references,  :class_name => :Reference, :foreign_key => :referee_id
      has_many :includes, :class_name => :Reference, :foreign_key => :referee_id,
        :conditions => { :link_type => INCLUDE }

      has_many :out_references,  :class_name => :Reference, :foreign_key => :referer_id
      has_many :out_includes, :class_name => :Reference, :foreign_key => :referer_id, :conditions => { :link_type => INCLUDE }

      after_create  :update_references_on_create
      after_destroy :update_references_on_destroy
      after_update  :update_references_on_update
    end

  end
 end
end
