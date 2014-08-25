event :remember_changes, :before=>:store do
  @current_changes = self.changes
end

event :store_act, :after=>:store do
  current_act = @supercard ? @supercard.current_act : self.acts.create_with_ip(request)
end

event :update_history, :after=>:store_act do
  super_action = current_act.action.first.send_if(:id)
  create_action current_act, super_action
end


def create_action act, super_action
  Card::TRACKED_FIELDS.each do |field|
    if changed_attributes.member? field
      actions.create(:action_type=>@action, :card_act_id=>act, :super_action_id=>super_action) do |action|
        action.changes.create :field => field, :value => self[:field]
      end
    end
  end
end


format :html do

  view :history do |args|
    load_revisions
    if @revision
      frame args.merge( :content=>true, :subheader=>_render_revision_subheader ) do
        _render_diff
      end
    end
  end

  view :diff do |args|
    load_revisions
    if @show_diff and @previous_revision
      diff @previous_revision.content, @revision.content
    else
      @revision.content
    end
  end
  
  view :revision_subheader do |args|
    %{
      <div class="revision-header">
        <span class="revision-title">#{ @revision.title }</span>
        posted by #{ link_to_page @revision.creator.name }
        on #{ format_date(@revision.created_at) } #{
        if !card.drafts.empty?
          %{<div class="autosave-alert">
            This card has an #{ autosave_revision }
          </div>}
        end}#{
        if @show_diff and @revision_number > 1  #ENGLISH
          %{<div class="revision-diff-header">
            <small>
              Showing changes from revision ##{ @revision_number - 1 }:
              <ins class="diffins">Added</ins> | <del class="diffmod">Deleted</del>
            </small>
          </div>}
        end}
      </div>
      <div class="revision-navigation">#{ revision_menu }</div>
    }
  end
  
  def load_revisions
    unless @revision_number
      @revision_number = (params[:rev] || (card.revisions.count - card.drafts.length)).to_i
      @revision = card.revisions[@revision_number - 1]
      @previous_revision = @revision ? card.previous_revision( @revision.id ) : nil
      @show_diff = (params[:mode] != 'false')
    end
  end

  def revision_link text, revision, name, accesskey='', mode=nil
    link_to text, path(:view=>:history, :rev=>revision, :mode=>(mode || params[:mode] || true) ),
      :class=>"slotter", :remote=>true, :rel=>'nofollow'
  end

  def rollback to_rev=nil
    to_rev ||= @revision_number
    if card.ok?(:update) && !(card.current_revision==@revision)
      link_to 'Save as current', path(:action=>:rollback, :rev=>to_rev),
        :class=>'slotter', :remote=>true
    end
  end

  def revision_menu
    revision_menu_items.flatten.map do |item|
      "<span>#{item}</span>"
    end.join('')
  end

  def revision_menu_items
    items = [back_for_revision, forward, see_or_hide_changes_for_revision]
    items << rollback unless card.recaptcha_on?
    items
  end

  def forward
    if @revision_number < card.revisions.count
      revision_link('Newer', @revision_number +1, 'to_next_revision', 'F' ) +
        raw(" <small>(#{card.revisions.count - @revision_number})</small>")
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
     revision_link("Autosaved Draft", card.revisions.count, 'to autosave')
  end

end