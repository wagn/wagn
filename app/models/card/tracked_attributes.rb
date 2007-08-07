module Card
  module TrackedAttributes 
    protected 

    def set_tracked_attributes  
      updates.each_pair do |attr, value| 
        if send("set_#{attr}", value )
          updates.clear attr
        end
      end
    end
     
    def set_name(newname)
      oldname = self.name_without_tracking
      #puts("\nrename #{oldname} => #{newname} ") if self.class.debug   
      self.name_without_tracking = newname 
      self.key = newname.to_key 
      return if new_record?
      return if oldname==newname
            
      if newname.junction?
        # move the current card out of the way, in case the new name will require
        # re-creating a card with the current name, ie.  A -> A+B
        connection.update %{update cards set #{quoted_comma_pair_list(connection, {:name=>"''",:key=>"''"})} where id=#{id}}
        self.trunk = Card.find_or_create :name=>newname.parent_name
        self.tag = Card.find_or_create :name=>newname.tag_name
        newname = trunk.name + JOINT + tag.name
        #puts "Set newname=#{newname}"
      end         
      #puts "write #{id} (#{name})= #{newname}"
      @name_changed = true
      @old_name = oldname
    end

    def set_type(new_type)
      self.type_without_tracking = new_type 
      return if new_record?    
      callback(:before_destroy)
      callback(:after_destroy)
      newcard = self.clone_to_type(new_type)
      newcard.send(:callback, :before_validation_on_create)
      newcard.send(:callback, :before_create)
      #newcard.send(:callback, :after_create)
      self.extension = newcard.extension
    end    
    
    def set_content(new_content)  
      return false unless self.id           
      new_content ||= ''
      Renderer.instance.render(self, new_content, update_references=true)
      clear_drafts if current_revision_id
      self.current_revision = Revision.create :card_id=>self.id, :content=>new_content
    end
             
    def set_comment(new_comment)
      set_content( content + new_comment )
    end
    
    def set_reader(party)   
      self.reader_without_tracking = party 
      junctions.each do |dep|
        dep.set_reader party 
        dep.save
      end
    end
    
    def set_writer(party)
      self.writer_without_tracking = party
    end                                           
    
    def set_appender(party)
      self.appender_without_tracking = party
    end

    def set_initial_content  
      # set_content bails out if we call it on a new record because it needs the
      # card id to create the revision.  call it again now that we have the id.
      
      #return unless new_record?  # because create callbacks are also called in type transitions
      return if on_create_skip_revision
      set_content updates[:content]
      updates.clear :content 
      # normally the save would happen after set_content. in this case, update manually:
      connection.update(
        "update cards set current_revision_id=#{current_revision_id} where id=#{id}",
        "Card Update"
      )
    end
    
    def cascade_name_changes 
      # This happens after_save because of the way it references trunk.name and tag.name
      # which depend on the original card being saved.
      return unless @name_changed
      # update the name cache all down the tree
      junctions.each do |card|
        dep_name = card.trunk.name + JOINT + card.tag.name
        #puts "  dep #{card.id} (#{card.name})= #{dep_name}"
        card.name = dep_name
        card.save
      end
       
      # update references (unless we're asked not to)
      if on_rename_skip_reference_updates
        WikiReference.update_on_destroy(self, self.name_without_tracking) # FIXME: needs old name
      else
        (dependents + [self]).plot(:linkers).flatten.uniq.each do |linker|
          WagBot.instance.revise_card_links( linker, @old_name, name )
        end        
        # FIXME: do update transclusions as well?
        # don't do update_on_destroy for old links-- those should have been repointed
        # to the new card.
      end
      WikiReference.update_on_create( self )
      @name_changed = false
    end
   
    def self.append_features(base)
      super 
      base.after_create :set_initial_content 
      base.before_save :set_tracked_attributes  
      base.after_save :cascade_name_changes   
      base.class_eval do 
        attr_accessor :on_create_skip_revision,
           :on_update_allow_duplicate_revisions,
           :on_rename_skip_reference_updates
      end
    end    
    
  end
end