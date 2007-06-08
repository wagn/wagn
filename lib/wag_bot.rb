# kindofahack... worksthough
User.class_eval "cattr_accessor 'wagbot'"

module WagBot
  def self.instance
    User.wagbot ||=  (User.find_by_login('wagbot') or User.find_by_login('hoozebot')).extend(WagBot)
  end
  
  def revise_card_links( card, oldlink, newlink )
    revise_card( card, nil ) do |wiki_content|
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
  end
  
  def revise_card( card, content=nil, &render_block )
    content = Renderer.instance.process(card, content, update_refs=true, &render_block)
    if content != card.content
      # wow this is really bad.. I seem to have backed myself into a bit of a corner
      # with the userstamp updated_by.. :-/
      olduser, User.current_user = User.current_user, self
      card.current_revision = Revision.create!(:card_id=>card.id, :content => content, :created_by=>self)
      card.save!
      User.current_user = olduser
    end
  end
  
end
