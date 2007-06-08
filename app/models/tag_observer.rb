class TagObserver < ActiveRecord::Observer
  def before_create(tag)
    tag.card_count = 0
    tag.datatype = 'RichText' # legacy-- this will go away when we stop supporting cohabitation of 0.4.x databases
    tag.datatype_key ||= 'RichText'
    tag.plus_datatype_key ||= tag.datatype_key
  end
  
  def after_create(tag)
    tag.current_revision = TagRevision.create!( :tag_id=>tag.id, :name=>tag.name)
    tag.save!    
  end
  
  def before_destroy(tag)    
    #tag.update_attribute(:current_revision_id, nil)
    # ^- this code was throwing "Can't modify frozen hash" while working on pa_dev wiki.. weird.
    Tag.connection.execute("update tags set current_revision_id=null where id=#{tag.id}")

  end

=begin  
  def after_save(tag)
    if tag.just_renamed? and tag.root_card
      root_card, dependents = tag.root_card, tag.root_card.dependents
      root_card.update_attribute( :name, tag.name )
      dependents.each do |card|
        card.update_attribute(:name, card.title_tag_names.join(JOINT))
      end
      if tag.update_links
        (dependents + [root_card]).plot(:linkers).flatten.uniq.each do |linker|
          WagBot.instance.revise_card_links( linker, tag.previous_name, tag.name )
        end
      end
      RecentChange.log( 'renamed', tag.root_card ) if tag.revisions.size > 1
    end
  end
=end  
  
end
