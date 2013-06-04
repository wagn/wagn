# -*- encoding : utf-8 -*-
module Cardlib::References
  def name_referencers link_name=nil
    link_name = link_name.nil? ? key : link_name.to_name.key
    Card.all :joins => :out_references, :conditions => { :card_references => { :referee_key => link_name } }
  end
  
  def extended_referencers
    # FIXME .. we really just need a number here.
    (dependents + [self]).map(&:referencers).flatten.uniq
  end

  def replace_references old_name, new_name
    obj_content = ObjectContent.new content, {:card=>self}
    
    obj_content.find_chunks( Chunks::Reference ).select do |chunk|
      if old_ref_name = chunk.referee_name and new_ref_name = old_ref_name.replace_part(old_name, new_name)
        chunk.referee_name = chunk.replace_reference old_name, new_name
        Card::Reference.where( :referee_key => old_ref_name.key ).update_all :referee_key => new_ref_name.key
      end
    end

    obj_content.to_s
  end

  def update_references rendered_content = nil, refresh = false
    raise "update references should not be called on new cards" if id.nil?

    Card::Reference.delete_all_from self

    # FIXME: why not like this: references_expired = nil # do we have to make sure this is saved?
    #Card.update( id, :references_expired=>nil )
    #  or just this and save it elsewhere?
    #references_expired=nil
    
    connection.execute("update cards set references_expired=NULL where id=#{id}")
  #  references_expired = nil
    expire if refresh

    rendered_content ||= ObjectContent.new(content, {:card=>self} )
    
    rendered_content.find_chunks(Chunks::Reference).each do |chunk|
      if referee_name = chunk.referee_name # name is referenced (not true of commented inclusions)
        referee_id = chunk.referee_id   
        if id != referee_id               # not self reference
          
          #update_references chunk.referee_name if ObjectContent === chunk.referee_name
          # for the above to work we will need to get past delete_all!
          
          Card::Reference.create!(
            :referer_id  => id,
            :referee_id  => referee_id,
            :referee_key => referee_name.key,
            :ref_type    => Chunks::Link===chunk    ? 'L' : 'I',
            :present     => chunk.referee_card.nil? ?  0  :  1
          )
        end
      end
    end
  end


  # ---------- Referenced cards --------------

  def referencers
    return [] unless refs = references
    refs.map(&:referer_id).map( &Card.method(:fetch) ).compact
  end

  def includers
    return [] unless refs = includes
    refs.map(&:referer_id).map( &Card.method(:fetch) ).compact
  end


  # ---------- Referencing cards --------------

  def referencees
    return [] unless refs = out_references
    refs.map { |ref| Card.fetch ref.referee_key, :new=>{} }.compact
  end

  def includees
    return [] unless refs = out_includes
    refs.map { |ref| Card.fetch ref.referee_key, :new=>{} }.compact
  end

  def self.included base

    super

    base.class_eval do
      # ---------- Reference associations -----------
      after_create  :update_references_on_create
#      after_destroy :update_references_on_destroy
      after_update  :update_references_on_update
    end
  end

  protected

  def update_references_on_create
    Card::Reference.update_existing_key self

    # FIXME: bogus blank default content is set on hard_templated cards...
    Account.as_bot do
      self.update_references
    end
    expire_templatee_references
    #obj_content.to_s
  end

  def update_references_on_update
    self.update_references
    expire_templatee_references
  end

  def update_references_on_delete
    Card::Reference.update_on_delete self
    expire_templatee_references
  end

end
