class FileController < ApplicationController
  layout 'simple'
  before_filter :load_card
  before_filter :edit_ok, :only=>[:edit]
  before_filter :create_ok, :only=>[:new]

  def new
    render :action=>'edit'
  end

  def denied  
    # FIXME: i think this may still error if parts of @card aren't defined
    render :template=>'/card/denied'
  end
  
  def upload
    raise "must have cardname" if @card.name.empty?
    file = params[:file]
    dir = @card.type.underscore
    x=file.original_filename.split('.')
    ext, filename = x.pop, x.join('.')
    name = @card.key.gsub('+', '~')
    #name = @card.name.empty? ? filename : @card.name.gsub(/^(.*)\.\w+$/,'\1')
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
  
  def load_card
    @card = Card.new params[:card]
  end
end
