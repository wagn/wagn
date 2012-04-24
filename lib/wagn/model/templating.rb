module Wagn::Model::Templating  

  def template?()       cardname.template_name?        end
  def hard_template?()  !!(name =~ /\+\*content$/)     end
  def soft_template?()  !!(name =~ /\+\*default$/)     end
  def type_template?()  template? && !!(name =~ /\+\*type\+/)  end
  def right_template?() template? && !!(name =~ /\+\*right\+/) end

  def template reset=false, skip_mods=false
    @template = reset || !@template ? get_template( skip_mods ) : @template
  end
  
  def get_template(skip_modules=false)
    t = rule_card(:content, :default, :skip_modules=>skip_modules)
    @virtual = (new_card? && t && t.hard_template?)
    t
  end
  
  def right_template()   (template && template.right_template?) ? template : nil  end
  def hard_template()    (template && template.hard_template?)  ? template : nil  end

  def templated_content
    return unless template && template.hard_template?
    template.content
  end
  
  def virtual?
    return false unless new_card?
    if @virtual.nil?
      cardname.simple? ? @virtual=false : get_template
    end
    @virtual
  end

  def hard_templatee_names
    if wql = hard_templatee_wql(:name)
      Card.as Card::WagbotID do
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
    if wql=hard_templatee_wql(:condition)
      condition = Card.as(Card::WagbotID) { Wql::CardSpec.build(wql).to_sql }
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
