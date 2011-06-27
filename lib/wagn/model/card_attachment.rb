module Wagn::Model::CardAttachment
  def self.included(base)
    #Rails.logger.info "add act methods for attachements #{base} #{self}"
    base.extend(ActMethods)
  end

  module ActMethods
    def card_attachment(klass)
      #extend ClassMethods unless (class << self; included_modules; end).include?(ClassMethods)
      include InstanceMethods unless included_modules.include?(InstanceMethods)
    
      mattr_accessor :attachment_model
      attr_accessor :attachment_id
      #Rails.logger.info "card_attachement(#{klass}) #{self}"
      #after_save :update_attachment moved to Card (with null update to override)

      self.attachment_model = klass
    end
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

