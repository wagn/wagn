module Wagn::Model::CardAttachment
  def update_attachment
    if attachment_id and !attachment_id.blank?
      attachment_model.find( attachment_id ).update_attribute :revision_id, current_revision_id
    end
  end

  def attachment
    attachment_model.find_by_revision_id( current_revision_id )
  end
end

