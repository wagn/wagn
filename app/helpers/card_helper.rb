module CardHelper

  def party_name(party)
    party ? party.card.name : 'Nobody'
  end

  def permission_options_for(card,task,party)
    container = []
    container<< ['No one',''] if task == :comment
    possible_roles = System.ok?(:set_card_permissions) ? Role.find(:all) : [] #User.current_user
    container+= container_from_roles( possible_roles )

    selected =
      case party.class.to_s
      when 'NilClass' ; ''
      else            ; party.id
      end

#    warn "party class = #{party.class}; selected = #{selected}"

    options_for_select container, selected
  end

  def selected_from(party)
    c = party.class
    case c
    when NilClass; ''
    else; party.id
    end
  end

  def container_from_roles( roles )
    #user = User.current_user
    roles.collect {|c| [c.cardname, c.id] }.sort {|a,b| a.last<=>b.last}
  end

  # navigation for revisions -
  # --------------------------------------------------
  def revision_link( text, revision, name, accesskey='', mode=nil )
    link_to_remote text,
      :url=>{ :action=>'changes', :id=>@card.id,
        :rev=>revision, :context=>@context, :mode=>(mode || params[:mode] || true)
      },
     :update=>'javascript:getSlotSpan(this)'
  end

  def rollback
    if @card.ok?(:update) && !(@card.current_revision==@revision)
      link_to_remote 'Save as current',
        :url => { :action=>'rollback', :id=>@card.id, :rev=>@revision_number, :context=>@context }
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

