module Card
  class Import < HTML
    before_validation_on_create :import_content
    
    def import_content
      DiffPatch
      messages = CardMerger.load( self.content )
      self.content = "#{messages.join("<br/>")}"
    end
  end
end