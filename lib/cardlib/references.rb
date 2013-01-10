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
    #warn "replace ref t: #{inspect},Cont:#{content}< o:#{old_name}, #{new_name}"
    obj_content = ObjectContent.new content, {:card=>self}
    obj_content.find_chunks( Chunks::Reference ).select do |chunk|

      #warn "replace ref test: #{chunk.cardname}, #{chunk.cardname.replace_part(old_name, new_name)} oo:#{old_name}, #{new_name}"
      if was_name = chunk.cardname and new_cardname = was_name.replace_part(old_name, new_name) and
          was_name != new_cardname

        Chunks::Link===chunk and link_bound = was_name == chunk.link_text

        #warn "replace ref #{was_name}, #{chunk.cardname}, #{new_cardname}, oo:#{old_name}, #{new_name}"
        chunk.cardname = chunk.replace_reference old_name, new_name
        Card::Reference.where( :referee_key => was_name.key ).update_all :referee_key => new_cardname.key

        chunk.link_text=chunk.cardname.to_s if link_bound
      end
    end

    obj_content.to_s
  end

  def update_references rendering_result = nil, refresh = false

    #warn "update references...card name: #{card.name}, rr: #{rendering_result}, refresh: #{refresh}"
    return if id.nil?

    Rails.logger.info "update refs #{inspect} #{caller*"\n"}"
    #raise "???" if caller.length > 500

    Card::Reference.delete_all :referer_id => id

    # FIXME: why not like this: references_expired = nil # do we have to make sure this is saved?
    #Card.update( id, :references_expired=>nil )
    #  or just this and save it elsewhere?
    #references_expired=nil
    Rails.logger.warn "set exp #{inspect}"
    connection.execute("update cards set references_expired=NULL where id=#{id}")
    self.references_expired = nil
    expire
    Rails.logger.warn "stil exp? exp #{inspect}"

    if rendering_result.nil?
      Rails.logger.warn "New OC from #{content.class} #{content}"
       rendering_result = ObjectContent.new(content, {:card=>self} )
    end

    rendering_result.find_chunks(Chunks::Reference).inject({}) do |hash, chunk|

      if id != ( referee_id = chunk.reference_id ) &&
              !hash.has_key?( referee_key = referee_id || chunk.refcardname.key )

        # update references from link_text
        update_references chunk.link_text if ObjectContent === chunk.link_text

        #raise '???' unless chunk.refcardname
        hash[ referee_key ] = {
          :referee_id  => referee_id,
          :referee_key => chunk.refcardname.key,
          :ref_type    => Chunks::Link===chunk      ? 'L' : 'I',
          :present     => chunk.reference_card.nil? ?  0  :  1
        }
      end

      hash
    end.each_value { |update| Card::Reference.create! update.merge( :referer_id => id ) }

  end

  # ---------- Referenced cards --------------

  def referencers
    return [] unless refs = references
    refs.map(&:referer_id).map( &Card.method(:fetch) )
  end

  def includers
    return [] unless refs = includes
    refs.map(&:referer_id).map( &Card.method(:fetch) )
  end


  # ---------- Referencing cards --------------

  def referencees
    return [] unless refs = out_references
    refs. map { |ref| Card.fetch ref.referee_key, :new=>{} }
  end

  def includees
    return [] unless refs = out_includes
    refs.map { |ref| Card.fetch ref.referee_key, :new=>{} }
  end

  def self.included base

    super

    base.class_eval do
      # ---------- Reference associations -----------
      has_many :references, :class_name => :Reference, :foreign_key => :referee_id
      has_many :includes,   :class_name => :Reference, :foreign_key => :referee_id, :conditions => { :ref_type => 'I' }

      has_many :out_references, :class_name => :Reference, :foreign_key => :referer_id
      has_many :out_includes,   :class_name => :Reference, :foreign_key => :referer_id, :conditions => { :ref_type => 'I' }

      after_create  :update_references_on_create
      after_destroy :update_references_on_destroy
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

  def update_references_on_destroy
    Card::Reference.update_on_destroy self
    expire_templatee_references
  end

end
