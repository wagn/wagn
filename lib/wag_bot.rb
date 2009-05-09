=begin

It looks like the only thing the "WagBot" is currently used for is as author of the "automatic"
revisions that may happen when a card is renamed.  (cards linking to it are revised to update the links)

I'm not clear on the rationale.  possibilities include:
1. we want links updated even on cards that the original user wouldn't have permission to edit, but the Wagbot does.
2. we want to flag the "automatic" updates somehow so as not to show them in recent changes or otherwise filter them.

I guess if we didn't have the Wagbot we'd have to figure out what to do in the case where a card name is changed and links exist
that the current user doesn't have permission to edit.  we could temporarily raise their permissions level.  Something about the Wagbot construct seems ugly to me.  maybe just the name.

=end

module WagBot 
  def self.instance
    (User.find_by_login('wagbot') or User.find_by_login('hoozebot')).extend(WagBot)
  end

  # FIXME: I think this method should be somewhere else, maybe card::base, and then in the 
  # update-links-on-rename do User.as(wagbot){ card.revise_links(old, new) }  --LWH
  def revise_card_links( card, oldlink, newlink )  
    content_with_revised_links = Renderer.instance.process(card, nil) do |wiki_content|
      wiki_content.find_chunks(Chunk::Link).each do |chunk|
        link_bound = chunk.card_name == chunk.link_text          
        ActiveRecord::Base.logger.info "\n-----BEFORE chunk.card_name: #{chunk.card_name}  sub #{oldlink} -> #{newlink}" if Card::Base.debug
        if chunk.card_name.to_key == oldlink.to_key
          chunk.card_name.replace newlink
        end
        #chunk.card_name.gsub!(/#{Regexp.escape(oldlink)}/,newlink)
        ActiveRecord::Base.logger.info "-----AFTER chunk.card_name: #{chunk.card_name} " if Card::Base.debug
        chunk.link_text = chunk.card_name if link_bound
      end
      
      wiki_content.find_chunks(Chunk::Transclude).each do |chunk|
        ActiveRecord::Base.logger.info "\n-----BEFORE chunk.card_name: #{chunk.card_name}  sub #{oldlink} -> #{newlink}" if Card::Base.debug
        if chunk.card_name.to_key == oldlink.to_key
          chunk.card_name.replace newlink
        end
        ActiveRecord::Base.logger.info "-----AFTER chunk.card_name: #{chunk.card_name} " if Card::Base.debug
      end
    end

    revise_card( card, content_with_revised_links )
  #rescue
  #  warn "Error revising card '#{card.name}'"
  end
  
  def revise_card( card, content="" )
    #warn "revising #{card.name} to '#{content}'"
    User.as(self) do 
      card.content = content
      card.save!
    end
  end
  
end
