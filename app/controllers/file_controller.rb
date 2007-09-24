class FileController < ApplicationController
  layout 'simple'
  before_filter :load_card, :edit_ok
  
  def upload
    file = params[:file]
    dir = @card.type.underscore
    x=file.original_filename.split('.')
    ext, filename = x.pop, x.join('.')
    name = @card.name.empty? ? filename : @card.name.gsub(/^(.*)\.\w+$/,'\1')
    File.open("#{RAILS_ROOT}/public/#{dir}/#{name}.#{ext}", "wb") do |f|
      f.write( file.read )
    end

#    slot = WagnHelper::Slot.new(@card,@context,'file')
    responds_to_parent do 
      render :update do |page|
        # FIXME-slot
        page << "warn('submitting after file upload');"
        page << %{e = $$(".upload-content")[0]; }
        page << %{e.value='#{name}.#{ext}';}
        page << %{e.form.onsubmit()}

      end
    end
    #render :action=>'view'
  end
end
