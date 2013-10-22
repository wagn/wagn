# -*- encoding : utf-8 -*-

event :set_tracked_attributes, :before=>:store do#, :on=>:save do
  updates.each_pair do |attrib, value|
    if send("set_#{attrib}", value )
      updates.clear attrib
    end
    @changed ||={}; @changed[attrib.to_sym]=true
  end
  #Rails.logger.debug "Card(#{name})#set_tracked_attributes end"
end


def assign_attributes args={}, options={}
  if args and newtype = args.delete(:type) || args.delete('type')
    args['type_id'] = Card.fetch_id( newtype )
  end
  reset_patterns

  super args, options
end


protected




def set_content new_content
  if self.id #have to have this to create revision
    new_content ||= ''
    new_content = Card::Content.clean! new_content if clean_html?
    clear_drafts if current_revision_id
    new_rev = Card::Revision.create :card_id=>self.id, :content=>new_content, :creator_id =>Account.current_id
    self.current_revision_id = new_rev.id
    reset_patterns_if_rule saving=true
    @name_or_content_changed = true
  else
    false
  end
end



event :set_initial_content, :after=>:store, :on=>:create do
  #Rails.logger.info "Card(#{inspect})#set_initial_content start #{content_without_tracking}"
  # set_content bails out if we call it on a new record because it needs the
  # card id to create the revision.  call it again now that we have the id.

  #Rails.logger.warn "si cont #{content} #{updates.for?(:content).inspect}, #{updates[:content]}"
  unless @from_trash
    set_content updates[:content] # if updates.for?(:content)
  
    updates.clear :content

    Card.where(:id=>id).update_all(:current_revision_id => current_revision_id)
  end
  #Rails.logger.info "set_initial_content #{content}, #{@current_revision_id}, s.#{self.current_revision_id} #{inspect}"
end


