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

      if was_name = chunk.reference_name and new_reference_name = was_name.replace_part(old_name, new_name)
        #warn "replace ref test: #{was_name}, #{new_reference_name} oo:#{old_name}, #{new_name}"

        #Chunks::Link===chunk and link_bound = was_name == chunk.link_text

        #warn "replace ref #{was_name} lb:#{chunk.link_text.inspect}, curref:#{chunk.reference_name.inspect}, nfre:#{new_reference_name.inspect}, oo:#{old_name}, #{new_name}"
        chunk.reference_name = chunk.replace_reference old_name, new_name
        Card::Reference.where( :referee_key => was_name.key ).update_all :referee_key => new_reference_name.key

        #chunk.link_text=chunk.reference_name.to_s if link_bound
      else
Rails.logger.warn "rref? #{was_name} :#{inspect}"
      end
    end

    obj_content.to_s
  end

  def update_references rendered_content = nil, refresh = false

  raise "???" if rendered_content =~ /^\+/
    Rails.logger.warn "update references...card name: #{inspect}, rr: #{rendered_content}, refresh: #{refresh}"
    #warn "update references...card name: #{inspect}, rr:#{rendered_content.inspect}, refresh: #{refresh.inspect}"
    raise "update references should not be called on new cards" if id.nil?

    Card::Reference.delete_all_from self

    # FIXME: why not like this: references_expired = nil # do we have to make sure this is saved?
    #Card.update( id, :references_expired=>nil )
    #  or just this and save it elsewhere?
    #references_expired=nil
    connection.execute("update cards set references_expired=NULL where id=#{id}")
    expire if refresh

    rendered_content ||= ObjectContent.new(content, {:card=>self} )
    Rails.logger.warn "up references:#{inspect}, rr:#{rendered_content.inspect}, refresh: #{refresh.inspect}"
      
    rendered_content.find_chunks(Chunks::Reference).each do |chunk|
    referee_name = chunk.reference_name
    referee_id = chunk.reference_id if referee_name
      Rails.logger.warn "chk repl #{referee_name.inspect} #{referee_id.inspect}, #{chunk.reference_id} chin:#{chunk.inspect} in:#{inspect}"
      if referee_name = chunk.reference_name # name is referenced (not true of commented inclusions)
        referee_id = chunk.reference_id   
        if id != referee_id               # not self reference
          
          update_references chunk.link_text if ObjectContent === chunk.link_text
          
          Card::Reference.create!(
            :referer_id  => id,
            :referee_id  => referee_id,
            :referee_key => referee_name.key,
            :ref_type    => Chunks::Link===chunk      ? 'L' : 'I',
            :present     => chunk.reference_card.nil? ?  0  :  1
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
    Rails.logger.warn "refs #{refs.inspect}"
    refs.map { |ref| Card.fetch ref.referee_key, :new=>{} }.compact
  end

  def self.included base

    super

    base.class_eval do
      # ---------- Reference associations -----------
      has_many :references,     :class_name => :Reference, :foreign_key => :referee_id
      has_many :includes,       :class_name => :Reference, :foreign_key => :referee_id, :conditions => { :ref_type => 'I' }

      has_many :out_references, :class_name => :Reference, :foreign_key => :referer_id
      has_many :out_includes,   :class_name => :Reference, :foreign_key => :referer_id, :conditions => { :ref_type => 'I' }

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
