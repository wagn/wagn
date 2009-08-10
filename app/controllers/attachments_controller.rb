class AttachmentsController < ApplicationController   
  layout nil

  make_resourceful do
    actions :all
    
    before :new, :create do
      current_object.attachment_uuid = params[current_model_name.underscore][:attachment_uuid]     
    end

    response_for :new do |format|
      format.html { render :template=>"/attachments/new" }
    end
  
    response_for :create do |format|
      format.html {   
        respond_to_parent do 
          render :update do |page|
            content = current_object.preview
            page << %{  
              warn('submitting after file upload');
              $("#{current_object.attachment_uuid}").value = '#{current_object.id}';
              $("#{current_object.attachment_uuid}-content").value='#{content}';
              $("#{current_object.attachment_uuid}-preview").update('#{content}');
              activateSubmit('#{current_object.attachment_uuid}');
            }              
          end
        end
      } 
    end
  end
end
