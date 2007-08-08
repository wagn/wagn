# kindofahack... worksthough
User.class_eval "cattr_accessor 'wagbot'"

module WagBot
  def self.instance
    User.wagbot ||=  (User.find_by_login('wagbot') or User.find_by_login('hoozebot')).extend(WagBot)
  end
  
  def revise_card_links( card, oldlink, newlink )
    content_with_revised_links = Renderer.instance.process(card, nil) do |wiki_content|
      wiki_content.find_chunks(Chunk::Link).each do |chunk|
        link_bound = chunk.card_name == chunk.link_text          
        warn "\nBEFORE chunk.card_name: #{chunk.card_name}  sub #{oldlink} -> #{newlink}" if Card::Base.debug
        chunk.card_name.gsub!(/#{Regexp.escape(oldlink)}/,newlink)
        warn "AFTER chunk.card_name: #{chunk.card_name} " if Card::Base.debug
        #chunk.card_name = chunk.card_name.split(JOINT).plot(:strip).map do |name|
        #  name == oldlink ? newlink : name
        #end.join(JOINT)
        chunk.link_text = chunk.card_name if link_bound
      end
    end

    revise_card( card, content_with_revised_links )
  rescue
    warn "Error revising card '#{card.name}'"
  end
  
  def revise_card( card, content="" )
    warn "revising #{card.name} to '#{content}'"
    User.as(self) do 
      card.content = content
      card.save!
    end
  end
  
end
