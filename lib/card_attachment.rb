module CardAttachment
  module ActMethods
    def card_attachment(klass)
      extend ClassMethods unless (class << self; included_modules; end).include?(ClassMethods)
      include InstanceMethods unless included_modules.include?(InstanceMethods)
      
      cattr_accessor :attachment_model
      attr_accessor :attachment_id
  	  after_save :update_attachment
  	                                  
  	  self.attachment_model = klass
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def update_attachment
      if attachment_id and !attachment_id.blank?
        attachment_model.find( attachment_id ).update_attribute :revision_id, current_revision_id
      end
    end

    def attachment
      attachment_model.find_by_revision_id( current_revision_id )
    end
  end
end

