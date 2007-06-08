class RecentChange < ActiveRecord::Base
  belongs_to :card, :class_name=>'Card::Base', :foreign_key=>'card_id'
  belongs_to :grave
  belongs_to :editor, :class_name=>'User', :foreign_key=>'editor_id'
  
  class << self
    def log( action, card, note="" )
      common_attributes = { 
        :action =>action,
        :name => card.name,
        :note => note,
        :editor => card.new_record? ? User.current_user : card.current_revision.author,
        :changed_at =>card.updated_at
      }
      if action == 'removed'
        grave = Grave.create :name=>card.name, :content=>card.content
        self.connection.update(%{
          UPDATE recent_changes SET card_id=NULL, grave_id=#{grave.id}
          WHERE card_id=#{card.id}
        })
        self.connection.update(%{
          UPDATE recent_viewings SET card_id=NULL
          WHERE card_id=#{card.id}
        })
        self.create! common_attributes.merge( :grave=>grave )
      else
        c = self.create! common_attributes.merge( :card=>card )
      end
    #rescue Exception=>e
    #  "oh well.."
    end
  end
end

