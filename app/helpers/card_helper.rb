module CardHelper

  def reader_options_for( card )
#   fixme-perm card.permission
#    card.writer ?  options_from_roles( card.writer.superset_roles ) :
#      [['','-- Select -- ']] + options_from_roles( Role.find_configurables )
  end

  def writer_options_for( card )
    card.reader ?  options_from_roles( (card.reader||Role.find_by_codename('anon')).subset_roles ) :
      [['','-- Select -- ']] + options_from_roles( Role.find_configurables )
  end                                
  
  def appender_options_for( card )
     [['','Nobody']] + (card.appender ?  options_from_roles( (card.reader||Role.find_by_codename('anon')).subset_roles ) :
      options_from_roles( Role.find_configurables ))
  end                                
  
  def options_from_roles( roles )
    return [] unless user=User.current_user
    roles.select do |r| 
      r.users.include?(user) 
    end.collect {|c| [c.id, c.cardname] }.sort {|a,b| a.last<=>b.last}
  end
  
  # navigation for revisions -
  # --------------------------------------------------
  def revision_link( text, revision, name, accesskey='', mode=nil )
    link_to_remote text, 
      :url=>{ :action=>'revision', :id=>@card.id, 
        :rev=>revision, :context=>@context, :mode=>(mode || params[:mode] || true)
      },
     :update=>slot_id(@card, @context)
  end

  def rollback
    link_to_remote 'Save as current', 
      :url => { :action=>'rollback', :id=>@card.id, :rev=>@revision_number },
      :update=>slot_id(@card, @context)
  end
  
  def revision_menu
    revision_menu_items.flatten.map do |item|
      "<span>#{item}</span>"
    end.join('')
  end
  
  def revision_menu_items
    menu = []
    menu << forward
    menu << back_for_revision
    menu << see_or_hide_changes_for_revision 
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
  
end

