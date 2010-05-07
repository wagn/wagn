module Card
  class Import < HTML
    before_validation_on_create :import_content
    
    def import_content
      DiffPatch
      cardnames = CardMerger.load( self.content )
      self.content = "updated #{cardnames.join(", ")}"
    end
  end
end