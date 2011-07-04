module Wagn::Model::CardAttachment
  def self.included(base)
    super
    #Rails.logger.debug "add act methods for attachements #{base} #{self}"
    base.extend(CardMethods)
  end

  mattr_accessor :attachment_model

  module CardMethods

    def card_attachment(klass)
      include InstanceMethods unless included_modules.include?(InstanceMethods)
    
      attr_accessor :attachment_id
      #after_save :update_attachment moved to Card (with null update to override)

      Wagn::Model::CardAttachment.attachment_model = klass
    end
  end

  module InstanceMethods
    def attachment_model() Wagn::Model::CardAttachment.attachment_model end

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

