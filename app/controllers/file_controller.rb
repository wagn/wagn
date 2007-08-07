class FileController < ApplicationController
  layout 'application' 
  
  def form
  end

  def upload
    #content_type = file.content_type
    file = params[:file]
    dir = params[:card][:type].underscore
    card_name = params[:card][:name]
    ext = file.original_filename.gsub(/.*\.(\w+)$/, '\1')
    
    file_name = card_name + "." + ext
    
    File.open("#{RAILS_ROOT}/public/#{dir}/#{file_name}", "wb") do |f|
      f.write( file.read )
    end
    
    element_id = params[:element]
    responds_to_parent do 
      render :update do |page|
        page.wagn.card.find("#{element_id}").content("#{file_name}")
        page.wagn.card.find("#{element_id}").continue_save()
      end
    end
  end
end
