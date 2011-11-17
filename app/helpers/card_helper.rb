module CardHelper

  def party_name(party)
    party ? party.card.cardname : 'Nobody'.to_cardname #CODENAME
  end

  # navigation for revisions -
  # --------------------------------------------------
  def revision_link( text, revision, name, accesskey='', mode=nil )
   link_to text, {
      :action=>'changes', 
      :id=>@card.id, 
      :rev=>revision,
      :mode=>(mode || params[:mode] || true)
    }, :class=>'standard-slotter', :remote=>true 
  end

  def rollback
    if @card.ok?(:update) && !(@card.current_revision==@revision)
      link_to 'Save as current', { 
        :action=>'rollback',
        :id=>@card.id,
        :rev=>@revision_number,
      }, :class=>'standard-slotter', :remote=>true
    end
  end

  def revision_menu
    revision_menu_items.flatten.map do |item|
      "<span>#{item}</span>"
    end.join('')
  end

  def revision_menu_items
    [back_for_revision, forward, see_or_hide_changes_for_revision, rollback]
  end

  def forward
    if @revision_number < @card.revisions.length
      revision_link('Newer', @revision_number +1, 'to_next_revision', 'F' ) +
        raw(" <small>(#{raw(@revision.card.revisions.length - @revision_number)})</small> ")
    else
      'Newer <small>(0)</small>'
    end
  end

  def back_for_revision
    if @revision_number > 1
      revision_link('Older',@revision_number - 1, 'to_previous_revision') +
        raw("<small>(#{@revision_number - 1})</small>")
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

