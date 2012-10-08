module Wagn::Model::Templating  

  def template?()       cardname.template_name?                 end
  def hard_template?()  !!(name =~ /\+\*content$/)              end
  def type_template?()  template? && !!(name =~ /\+\*type\+/)   end

  def template
    # currently applicable templating card.
    # note that a *default template is never returned for an existing card.
    @template ||= begin
      @virtual = false
      if new_card?
        default_card = rule_card :default, :skip_modules=>true

        dup_card = self.dup
#        dup_card.type_id_without_tracking = default_card.type_id
        dup_card.type_id_without_tracking = default_card ? default_card.type_id : Card::DefaultTypeID


        if content_card = dup_card.content_rule_card
          @virtual = true
          content_card
        else
          default_card
        end
      else
        content_rule_card
      end
    end
  end

  def hard_template
    template if template && template.hard_template?
  end
  
  def virtual?
    return false unless new_card?
    if @virtual.nil?
      cardname.simple? ? @virtual=false : template
    end
    @virtual
  end

  def content_rule_card
    card = rule_card :content, :skip_modules=>true
    crc = card && card.content == '_self' ? nil : card
  end

  def hard_templatee_names
    wql = hard_templatee_wql(:name)
    #warn (Rails.logger.warn "ht_wql #{wql.inspect}")
    if wql
      Session.as_bot do
        Wql.new(wql).run
      end
    else
      []
    end
  end    

  # FIXME: content settings -- do we really need the reference expiration system?
  #
  # I kind of think so.  otherwise how do we handled patterned references in hard-templated cards?  
  # I'll leave the FIXME here until the need is well documented.  -efm
  #
  # ps.  I think this code should be wiki references.
  def expire_templatee_references
    wql=hard_templatee_wql(:condition)
    #warn "expire_t_refs #{name}, #{wql.inspect}"
    if wql
      condition = Session.as_bot { Wql::CardSpec.build(wql).to_sql }
      card_ids_to_update = connection.select_rows("select id from cards t where #{condition}").map(&:first)
      card_ids_to_update.each_slice(100) do |id_batch|
        connection.execute "update cards set references_expired=1 where id in (#{id_batch.join(',')})"
      end
    end
  end


  private

  def hard_templatee_wql return_field
    #warn "htwql #{name} #{hard_template?}, #{cardname.trunk_name}, #{Card.fetch(cardname.trunk_name)}"
    if hard_template? and c=Card.fetch(cardname.trunk_name) and c.type_id == Card::SetID
      c.get_spec.merge :return => return_field
    end
  end

end
