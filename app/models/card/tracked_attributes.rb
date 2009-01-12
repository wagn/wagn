module CardLib
  module TrackedAttributes 
     
    def set_tracked_attributes  
      updates.each_pair do |attr, value| 
        if send("set_#{attr}", value )
          updates.clear attr
        end
        #warn "SET CHANGED #{attr.to_sym.inspect}"    
        @changed ||={}; @changed[attr.to_sym]=true 
      end
    end
    
    
    # this method conflicts with ActiveRecord since Rails 2.1.0
    # the only references I see are in cache_spec, so removing for now
=begin    
    def changed?(field) 
      #return false
      #if updates.emtpy?
      @changed ||={}; 
      #warn "GET CHAGNED #{field.inspect}"    
      !!(@changed[field] && !updates.for?(field))
    end
=end
    
    protected 
    def set_name(newname)
    
      oldname = self.name_without_tracking
      self.name_without_tracking = newname 
      return if new_record?
      return if oldname==newname
          
      if trash = Card.find_by_key(newname.to_key)
        if trash.trash  
          trash.update_attributes! :name=>trash.name+"*trash", :confirm_rename=>true
        else
          # note -- this happens when changing to a name variant.  any special handling needed?
        end
      end
            
      if type=='Cardtype'
        ::Cardtype.reset_cache
      end
            
      if newname.junction?
        # move the current card out of the way, in case the new name will require
        # re-creating a card with the current name, ie.  A -> A+B
        connection.update %{update cards set #{quoted_comma_pair_list(connection, {:name=>"''",:key=>"''"})} where id=#{id}}
        self.trunk = Card.find_or_create :name=>newname.parent_name
        self.tag = Card.find_or_create :name=>newname.tag_name
      else
        self.trunk = self.tag = nil
      end         
      @name_changed = true          
      @old_name = oldname
      @search_content_changed=true 
      if cc=CachedCard.find(@old_name.to_key) then cc.expire_all end  # clear cache of old name.
      
    end

    def set_type(new_type)
      #warn "set type called on #{name} to #{new_type}"
      self.type_without_tracking = new_type 
      return if new_record?    
      callback(:before_destroy)  # before destroy takes out extensions, which are cardtype specific.
      #callback(:after_destroy)  # after destroy takes out links, which we want to keep
      templatees = hard_templatees
      if !templatees.empty?
        #warn "going through hard templatees"  
        templatees.each do |tee|
          tee.allow_type_change = "HELLS YEAH"  #FIXME? this is a hacky way around the standard validation
          tee.type = new_type
          tee.save!
        end
      end
      newcard = self.clone_to_type(new_type)
      newcard.send(:callback, :before_validation_on_create)
      newcard.send(:callback, :before_create)
      #newcard.send(:callback, :after_create)
      self.extension = newcard.extension
      self.set_permissions self.permissions.collect{|x| x}
    end
    
    def set_content(new_content)  
      return false unless self.id           
      new_content ||= '' 
      
      # FIXME?: this code written under influence. may require adjustment
      new_content =  WikiContent.clean_html!(new_content) if clean_html?
      
      clear_drafts if current_revision_id
      self.current_revision = Revision.create :card_id=>self.id, :content=>new_content
      @search_content_changed = true
    end
             
    def set_comment(new_comment)    
      set_content( content + new_comment )
    end
    
    def set_permissions(perms)
      self.updates.clear(:permissions)
      if type=='Cardtype' and !perms.detect{|p| p.task=='create'}
        old_create_party = self.who_can(:create) || Card::Basic.new.cardtype.who_can(:create) 
        perms << Permission.new(:task=>'create', :party=>old_create_party)
      end
      self.permissions_without_tracking = perms.reject {|p| p.party==nil }
      perms.each do |p| 
        set_reader( p.party ) if p.task == 'read'
      end      
#=begin
      if template? and trunk.type == 'Cardtype' and create_party = who_can(:create)
        ::User.as :admin do
          trunk.permit(:create, create_party)
          trunk.save!
          if trunk.codename == 'Basic'
            Card::Basic.permission_dependent_cardtypes.each do |ct|
              #warn "updating cardtype: #{ct.name}"
              ct.permit(:create, create_party)
              ct.save
            end
          end
        end
      end
#=end    
      return true
    end
   
    def set_reader(party)
      self.reader = party
      if !party.anonymous?  
        junctions.each do |dep|
          unless authenticated?(party) and !dep.who_can(:read).anonymous?
            dep.permit :read, party  
            dep.save!
          end
        end
      end
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
      return true unless @name_changed
      # update the name cache all down the tree
      junctions.each do |card|
        dep_name = card.trunk.name + JOINT + card.tag.name
        #warn "  dep #{card.id} (#{card.name})= #{dep_name}"
        card.name = dep_name
        card.update_link_ins = update_link_ins
        card.confirm_rename = confirm_rename
        card.save! #FIXME -- not sure this should be a ! (?), but probably needs handling if not...
      end
      
      #warn "UPDATE LINK INS:  #{update_link_ins}  #{update_link_ins == false}  #{update_link_ins == 'false'}"
       
      # update references (unless we're asked not to)
      if !update_link_ins or update_link_ins == 'false'  # FIXME -- doing the string check because the radio button is sending an actual "false" string
        #warn "no updating.."
        WikiReference.update_on_destroy(self, @old_name) 
      else
        link_in_cards.each do |linker|
          #warn "updating #{linker.name}"
          WagBot.instance.revise_card_links( linker, @old_name, name )
        end        
        # FIXME: do update transclusions as well?
        # don't do update_on_destroy for old links-- those should have been repointed
        # to the new card.
      end
      WikiReference.update_on_create( self )
      @name_changed = false   
      true
    end
   
    
   
    def self.append_features(base)
      super 
      base.after_create :set_initial_content 
      base.before_save.unshift Proc.new{|rec| rec.set_tracked_attributes }
      #puts "AFTER CREATE: #{base.after_create}"
      #base.before_save = base.before_save                           
      base.after_save :cascade_name_changes   
      base.class_eval do 
        attr_accessor :on_create_skip_revision,
           :on_update_allow_duplicate_revisions
        #
        #puts "CALLING ALIAS METHOD CHAIN"
        #alias_method_chain :save, :tracking
        #alias_method_chain :save!, :tracking
        
      end
    end    
    
  end
end