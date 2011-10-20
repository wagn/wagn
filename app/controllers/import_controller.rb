class ImportController < ApplicationController
  def index
  end

  def import
    if Wagn::Import.csv( :cardtype=>params[:cardtype], :data=>params[:data] )
      flash[:notice] = "Imported. Woooo!"
      redirect_to page_setting('/recent')
    end
  end
end
