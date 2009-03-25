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
            page << "warn('submitting after file upload');"
            page << %{e = $("#{current_object.attachment_uuid}"); }
            page << %{e.value='#{current_object.id}';}
            page << %{e.form.onsubmit()}              
          end
        end
      } 
    end
  end
end
