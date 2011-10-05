class Wagn::Renderer
  define_view(:editor, :type=>'file') do |args|
    attachment_model_name = card.attachment_model.name.underscore
    attachment_uuid = (0..29).to_a.map {|x| rand(10)}
    self.skip_autosave = true
    # WEIRD: when I didn't check for new_record?, create would come up with random old attachment previews
    div( :class=>"attachment-preview", :id=>"#{attachment_uuid}-preview") do
      !card.new_card? && card.attachment ? card.attachment.preview : ''
    end +
    
    div do
      %{
        <iframe id="upload-iframe-#{ attachment_uuid }" class="upload-iframe" name="upload-iframe" height="50" width="480" 
          frameborder="0" src="/#{attachment_model_name.pluralize}/new?#{attachment_model_name}[attachment_uuid]=#{attachment_uuid}" scrolling="no">
        </iframe>
      }
    end + 
    form.hidden_field("attachment_id", :id=>attachment_uuid) +
    form.hidden_field("content", :id=>"#{attachment_uuid}-content")
    #= editor_hooks :save=>%{ //FIXME: handle the case that the upload isn't finished. }
  end

  alias_view :editor, {:type=>:file}, {:type=>:image}
end
