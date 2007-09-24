class FileController < ApplicationController
  layout 'simple'
  before_filter :load_card, :edit_ok
  
  def upload
    file = params[:file]
    dir = @card.type.underscore
    ext = file.original_filename.gsub(/.*\.(\w+)$/, '\1')
    file_name = @card.name + "." + ext
    
    File.open("#{RAILS_ROOT}/public/#{dir}/#{file_name}", "wb") do |f|
      f.write( file.read )
    end

    slot = WagnHelper::Slot.new(@card,@context,'file')
    responds_to_parent do 
      render :update do |page|
        # FIXME-slot
        page << "warn('submitting after file upload');"
        page << %{e = $$(".upload-content")[0]; }
        page << %{e.value='#{file_name}';}
        page << %{e.form.onsubmit()}
      end
    end
    #render :action=>'view'
  end
end
