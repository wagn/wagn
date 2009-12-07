module Cardlib
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
          
      if existing_card = Card.find_by_key(newname.to_key)  and existing_card != self
        if existing_card.trash  
          existing_card.update_attributes! :name=>existing_card.name+"*trash", :confirm_rename=>true
        else                             
          # note -- this happens when changing to a name variant.  any special handling needed?
        end
      end
            
      if type=='Cardtype'
        ::Cardtype.reset_cache
      end
            
      if newname.junction?
        if newname.to_key != oldname.to_key
          # move the current card out of the way, in case the new name will require
          # re-creating a card with the current name, ie.  A -> A+B     
          tmp_name = "tmp:" + UUID.new.generate      
          connection.update %{update cards set #{quoted_comma_pair_list(connection, {:name=>"'#{tmp_name}'",:key=>"'#{tmp_name}'"})} where id=#{id}}
        end
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
      on_type_change # FIXME this should be a callback
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
        perms << Permission.new(:task=>'create', :party=>old_create_party, :card_id=>self.id)
      end
      self.permissions_without_tracking = perms.reject {|p| p.party==nil }
      perms.each do |p| 
        set_reader( p.party ) if p.task == 'read'
      end      
#=begin
      if template? and trunk.type == 'Cardtype' and create_party = who_can(:create)
        ::User.as :wagbot do
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
      return true unless @name_changed
      ActiveRecord::Base.logger.info("----------------------- CASCADE #{self.name}  -------------------------------------")  
      
      deps = self.dependents
                                            
      deps.each do |dep|
        ActiveRecord::Base.logger.info("---------------------- DEP #{dep.name}  -------------------------------------")  
        cxn = ActiveRecord::Base.connection
        depname = dep.name.replace_part @old_name, name
        depkey = depname.to_key    
        # here we specifically want NOT to invoke recursive cascades on these cards, have to go this 
        # low level to avoid callbacks.                                                               
        Card.update_all("name=#{cxn.quote(depname)}, #{cxn.quote_column_name("key")}=#{cxn.quote(depkey)}", "id = #{dep.id}")
        dep.expire(dep)
      end 

      if !update_referencers || update_referencers == 'false'  # FIXME doing the string check because the radio button is sending an actual "false" string
        #warn "no updating.."
        ([self]+deps).each do |dep|
          ActiveRecord::Base.logger.info("--------------- NOUPDATE REFERRER #{dep.name}  ---------------------------")
          WikiReference.update_on_destroy(dep, @old_name) 
        end
      else
        ([self]+deps).map(&:referencers).flatten.uniq.each do |card|
          ActiveRecord::Base.logger.info("------------------ UPDATE REFERRER #{card.name}  ------------------------")
          User.as(:wagbot) do      
            card.content = Renderer.new.replace_references( card, @old_name, name )
            card.save! unless card==self
          end
        end
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