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

protected

def set_name newname
  @old_name = self.name_without_tracking
  return if @old_name == newname.to_s
  #Rails.logger.warn "rename . #{inspect}, N:#{newname}, O:#{@old_name}"

  @cardname, name_without_tracking = if Card::Name===newname
    [ newname, newname.to_s]
  else
    [ newname.to_name, newname]
  end
  write_attribute :key, k=cardname.key
  write_attribute :name, name_without_tracking # what does this do?  Not sure, maybe comment it out and see

  reset_patterns_if_rule saving=true# reset the new name

  Card.expire cardname

  if @cardname.junction?
    [:left, :right].each do |side|
      sidename = @cardname.send "#{side}_name"
      #Rails.logger.warn "sidename #{newname}, #{@old_name}, #{sidename}"
      sidecard = Card[sidename]
      old_name_in_way = (sidecard && sidecard.id==self.id) # eg, renaming A to A+B
      suspend_name(sidename) if old_name_in_way
      self.send "#{side}_id=", begin
        if !sidecard || old_name_in_way
          Card.create! :name=>sidename
        else
          sidecard
        end.id
      end
    end
  else
    self.left_id = self.right_id = nil
  end

  return if new_card?
  if existing_card = Card.find_by_key(@cardname.key) and existing_card != self
    if existing_card.trash
      existing_card.name = tr_name = existing_card.name+'*trash'
      existing_card.instance_variable_set :@cardname, tr_name.to_name
      existing_card.set_tracked_attributes
      #Rails.logger.debug "trash renamed collision: #{tr_name}, #{existing_card.name}, #{existing_card.cardname.key}"
      existing_card.save!
    #else note -- else case happens when changing to a name variant.  any special handling needed?
    end
  end

  Card.expire @old_name
  @name_changed = true
  @name_or_content_changed=true
end

def suspend_name(name)
  # move the current card out of the way, in case the new name will require
  # re-creating a card with the current name, ie.  A -> A+B
  Card.expire name
  tmp_name = "tmp:" + UUID.new.generate
  Card.where(:id=>self.id).update_all(:name=>tmp_name, :key=>tmp_name)
end

def set_type_id new_type_id
  self.type_id_without_tracking= new_type_id
  if assigns_type? # certain *structure templates
    update_templatees :type_id => new_type_id
  end
  if real?
    on_type_change # FIXME this should be a callback
    reset_patterns
    include_set_modules # dislike doing this prior to save, but I think it's done to catch set-specific behavior??
    # do we need to "undo" loaded modules?  Maybe reload defaults?
  end
  true
end

def set_content new_content
  #Rails.logger.info "setting content for #{name}: (#{self.id})"
  if self.id #have to have this to create revision
    new_content ||= ''
    new_content = CleanHtml.clean! new_content if clean_html?
    clear_drafts if current_revision_id
    new_rev = Card::Revision.create :card_id=>self.id, :content=>new_content, :creator_id =>Account.current_id
    self.current_revision_id = new_rev.id
    reset_patterns_if_rule saving=true
    @name_or_content_changed = true
  else
    false
  end
end

def set_comment new_comment
  #seems hacky to do this as tracked attribute.  following complexity comes from set_content complexity.  sigh.

  commented = %{
    #{ content }
    #{ '<hr>' unless content.blank? }
    #{ new_comment.to_html }
    <div class="w-comment-author">--#{
      if Account.logged_in?
        "[[#{Account.current.name}]]"
      else
        Wagn::Conf[:controller].session[:comment_author] = comment_author if Wagn::Conf[:controller]
        "#{ comment_author } (Not signed in)"
      end
    }.....#{Time.now}</div>
  }

  if new_card?
    self.content = commented
  else
    set_content commented
  end
  true
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

event :cascade_name_changes, :after=>:store do
  if @name_changed
    Rails.logger.debug "-------------------#{@old_name}- CASCADE #{self.name} -------------------------------------"

    self.update_referencers = false if self.update_referencers == 'false' #handle strings from cgi
    Card::Reference.update_on_rename self, name, self.update_referencers

    deps = self.dependents
    #warn "-------------------#{@old_name}---- CASCADE #{self.name} -> deps: #{deps.map(&:name)*", "} -----------------------"

    @dependents = nil #reset

    deps.each do |dep|
      # here we specifically want NOT to invoke recursive cascades on these cards, have to go this low level to avoid callbacks.
      Card.expire dep.name #old name
      newname = dep.cardname.replace_part @old_name, name
      Card.where( :id=> dep.id ).update_all :name => newname.to_s, :key => newname.key
      Card::Reference.update_on_rename dep, newname, update_referencers
      Card.expire newname
    end

    if update_referencers
      Account.as_bot do
        [self.name_referencers(@old_name)+(deps.map &:referencers)].flatten.uniq.each do |card|
          # FIXME  using "name_referencers" instead of plain "referencers" for self because there are cases where trunk and tag
          # have already been saved via association by this point and therefore referencers misses things
          # eg.  X includes Y, and Y is renamed to X+Z.  When X+Z is saved, X is first updated as a trunk before X+Z gets to this point.
          # so at this time X is still including Y, which does not exist.  therefore #referencers doesn't find it, but name_referencers(old_name) does.
          # some even more complicated scenario probably breaks on the dependents, so this probably needs a more thoughtful refactor
          # aligning the dependent saving with the name cascading

          Rails.logger.debug "------------------ UPDATE REFERER #{card.name}  ------------------------"
          unless card == self or card.hard_template
            card = card.refresh
            card.content = card.replace_references @old_name, name
            card.save!
          end
        end
      end
    end
    @name_changed = false
  end
  true
end

