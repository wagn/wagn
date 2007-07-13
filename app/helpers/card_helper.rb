module CardHelper

  def reader_options_for( card )
    card.writer ?  options_from_roles( card.writer.superset_roles ) :
      [['','-- Select -- ']] + options_from_roles( Role.find_configurables )
  end

  def writer_options_for( card )
    card.reader ?  options_from_roles( card.reader.subset_roles ) :
      [['','-- Select -- ']] + options_from_roles( Role.find_configurables )
  end
  
  def options_from_roles( roles )
    return [] unless user=User.current_user
    roles.select do |r| 
      r.users.include?(user) 
    end.collect {|c| [c.id, c.cardname] }.sort {|a,b| a.last<=>b.last}
  end
  
  
  def datatype_options
    Datatype.find_all.reject do |s|
      (s.registered_id == 'Ruby' and !System.enable_ruby_cards) or
      (s.registered_id == 'Server' and ! (System.enable_server_cards and System.ok?( :edit_server_cards ))) or
      (s.registered_id == 'Discussion' and !System.always_ok?)
    end.map { |s| [s.registered_id, s.label] } 
  end
  
  
  def datatype_select
    collection_select( :tag, :datatype_key, datatype_options, :first, :last, {}, :onChange=>'this.form.onsubmit()')
  end
  
  # navigation for revisions -
  # --------------------------------------------------
  def revision_link( text, revision, name, accesskey='', mode=nil )
    link_to_function( text, card_function(params[:element], 'changes', revision, "'#{mode || params[:mode] || 'true'}'"))
  end
  
  
  def revision_menu
    revision_menu_items.flatten.map do |item|
      "<span>#{item}</span>"
    end.join('')
  end
  
  def revision_menu_items
    menu = []
    menu << forward
    menu << back_for_revision #if @revision_number > 1
    #menu << current_revision
    menu << see_or_hide_changes_for_revision #if @revision_number > 1
    menu << rollback
    menu
  end
  
  def forward
    if @revision_number < @card.revisions.length
      revision_link('Newer', @revision_number +1, 'to_next_revision', 'F' ) + 
        " <small>(#{@revision.card.revisions.length - @revision_number})</small> "
    else
      'Newer <small>(0)</small>'
    end
  end
    
  def back_for_revision
    if @revision_number > 1
      revision_link('Older',@revision_number - 1, 'to_previous_revision') + 
        " <small>(#{@revision_number - 1})</small>"
    else
      'Older <small>(0)</small>'
    end
  end

  def see_or_hide_changes_for_revision
    revision_link(@show_diff ? 'Hide changes' : 'Show changes', 
      @revision_number, 'see_changes', 'C', (@show_diff ? 'false' : 'true'))
  end

 
  def autosave_revision
     revision_link("Autosaved Draft", @card.revisions.count, 'to autosave')
  end
  
  def rollback
    link_to_function( 'Save as current', card_function( params[:element], :rollback, @revision_number ) )
    #link_to_card('Rollback', :action=>'rollback', :rev => @revision_number, 
    #  :class => 'navlink', :name => 'rollback')
  end
  

  
end

