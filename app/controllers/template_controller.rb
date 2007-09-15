class TemplateController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok
  before_filter :get_tmpl, :except=>[:create]
  
  
  def create
    type = @card.type=='Cardtype' ? @card.codename : 'Basic'
    @tmpl = Card.create :name=>@card.name+"+*template", :type=>type
    return render_errors(@tmpl) unless @tmpl.errors.empty?
    render_update_slot render_to_string( :action=>'edit' )
  end

  def edit 
    @tmpl = handle_cardtype_update(@tmpl)
  end

  def update
    @tmpl.update_attributes params[:card]
    @notice = 'Template updated'
    render_update_slot render_to_string( :template=>'/card/options'  )
  end
       
  def remove
    @tmpl.destroy!
    @notice = 'Template removed'
    render_update_slot render_to_string( :tmpl=>'/card/options')
  end     
  
  private
  def get_tmpl                        
    # Unfortunately @template is aready used by rails
    @tmpl = Card[@card.name+"+*template"] 
  end
  
end
