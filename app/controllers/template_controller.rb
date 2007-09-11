class TemplateController < ApplicationController
  helper :wagn, :card 
  cache_sweeper :card_sweeper
  before_filter :load_card, :edit_ok
  before_filter :get_tmpl, :except=>[:create]
  
  
  def create
    type = @card.type=='Cardtype' ? @card.codename : 'Basic'
    @tmpl = Card.create :name=>@card.name+"+*template", :type=>type
    return render_errors(@tmpl) unless @tmpl.errors.empty?
    edit_screen = render_to_string :action=>'edit'
    render :update do |page|
      page.replace_html slot.id, edit_screen
    end
  end

  def edit 
    @tmpl = handle_cardtype_update(@tmpl)
  end

  def update
    @tmpl.update_attributes params[:card]
    @notice = 'Template updated'
    options_screen = render_to_string :template=>'/card/options'
    render :update do |page|
      page.replace_html slot.id, options_screen
    end
  end
       
  def remove
    @tmpl.destroy!
    @notice = 'Template removed'
    options_screen = render_to_string :tmpl=>'/card/options'
    render :update do |page|
      page.replace_html slot.id, options_screen
    end
  end     
  
  private
  def get_tmpl                        
    # Unfortunately @template is aready used by rails
    @tmpl = Card[@card.name+"+*template"] 
  end
  
end
