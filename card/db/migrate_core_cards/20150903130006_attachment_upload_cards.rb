# -*- encoding : utf-8 -*-

class AttachmentUploadCards < Card::CoreMigration
  def up
    Card.create! name: '*new file', type: 'File', codename: 'new_file'
    Card.create! name: '*new image', type: 'Image', codename: 'new_image'

    if (js_output = Card['*all+*script+*machine output'])
      #perhaps too narrow?
      js_output.delete!
    end
  end
end
