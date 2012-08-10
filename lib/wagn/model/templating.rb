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
        default_card = rule_card( 'default' )
        dup_card = self.dup
        dup_card.typecode_without_tracking = default_card.typecode

        if content_card = dup_card.rule_card( 'content' )
          @virtual = true
          content_card
        else
          default_card
        end
      else
        rule_card 'content'
      end
    end
  end

  def hard_template()
    template if template && template.hard_template?
  end
  
  def virtual?
    if @virtual.nil?
      cardname.simple? ? @virtual=false : template
    end
    @virtual
  end

  def hard_templatee_names
    if wql = hard_templatee_wql(:name)
      User.as(:wagbot)  {  Wql.new(wql).run  }
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
    if wql = hard_templatee_wql(:condition)
      condition = User.as(:wagbot) { Wql::CardSpec.build(wql).to_sql }
      card_ids_to_update = connection.select_rows("select id from cards t where #{condition}").map(&:first)
      card_ids_to_update.each_slice(100) do |id_batch|
        connection.execute "update cards set references_expired=1 where id in (#{id_batch.join(',')})"
      end
    end
  end

  private

  def hard_templatee_wql return_field
    if hard_template? and c=Card.fetch(cardname.trunk_name) and c.typecode == 'Set'
      c.get_spec.merge :return => return_field
    end
  end

end
