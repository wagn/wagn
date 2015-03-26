REVISIONS_PER_PAGE = Card.config.revisions_per_page

# must be called on all actions and before :set_name, :process_subcards and :validate_delete_children
def create_act_and_action
  @current_act = if @supercard
    @supercard.current_act || @supercard.acts.build(:ip_address=>Env.ip)
  else
    acts.build(:ip_address=>Env.ip)
  end

  @current_action = actions.build(:action_type=>@action, :draft=>(Env.params['draft'] == 'true') )
  @current_action.act = @current_act

  if (@supercard and @supercard !=self)
    @current_action.super_action = @supercard.current_action
  end
end



event(:create_act_and_action_for_save,   :before=>:process_subcards, :on=>:save)   { create_act_and_action }
event(:create_act_and_action_for_delete, :before =>:validate_delete_children, :on=>:delete) { create_act_and_action }


event :remove_empty_act, :after=>:extend do
  # if not @supercard and not @current_act.actions.empty?
  #   @current_act.save
  # end
  @current_act.reload
  if not @supercard and @current_act.actions.empty?
     @current_act.delete
     @current_act = nil
   end
end



event :rollback_actions, :before=>:approve, :on=>:update, :when=>proc{ |c| Env and Env.params['action_ids'] and Env.params['action_ids'].class == Array} do
  revision = { :subcards => {}}
  rollback_actions = Env.params['action_ids'].map do |a_id|
    Action.fetch(a_id) || nil
  end
  rollback_actions.each do |action|
    if action.card_id == id
      revision.merge!(revision(action))
    else
      revision[:subcards][action.card.name] = revision(action)
    end
  end
  Env.params['action_ids'] = nil
  update_attributes! revision
  rollback_actions.each do |action|
    action.card.attachment_symlink_to action.id
  end
  clear_drafts
  abort :success
end



def intrusive_family_acts args={}   # all acts with actions on self and on cards that are descendants of self and included in self
  @intrusive_family_acts ||= begin
    Act.find_all_with_actions_on( (included_descendant_card_ids << id), args)
  end
end

def intrusive_acts  args={:with_drafts=>true} # all acts with actions on self and on cards included in self
  @intrusive_acts ||= begin
    Act.find_all_with_actions_on( (included_card_ids << id), args)
  end
end

def current_rev_nr
  @current_rev_nr ||= begin
    @intrusive_acts.first.actions.last.draft ? @intrusive_acts.size - 1 : @intrusive_acts.size
  end
end

def included_card_ids
  Card::Reference.select(:referee_id).where( :ref_type => 'I', :referer_id=>id ).pluck('referee_id').compact.uniq
end

def descendant_card_ids parent_ids=[id]
  more_ids = Card.where('left_id IN (?)', parent_ids).pluck('id')

  if !more_ids.empty?
    more_ids += descendant_card_ids more_ids
  end
  more_ids
end

def included_descendant_card_ids
  included_card_ids & descendant_card_ids
end

format :html do
  view :history do |args|
    frame args.merge(:body_class=>"history-slot list-group", :content=>true, :subheader=>_render_revision_subheader ) do
      _render_revisions
    end
  end

  view :revisions do |args|
    page = params['page'] || 1
    count = card.intrusive_acts.size+1-(page.to_i-1)*REVISIONS_PER_PAGE
    card.intrusive_acts.page(page).per(REVISIONS_PER_PAGE).map do |act|
      count -= 1
      render_act_summary args.merge(:act=>act,:rev_nr=>count)
    end.join
  end

  view :revision_subheader do |args|
    intr = card.intrusive_acts.page(params['page']).per(REVISIONS_PER_PAGE)
    render_haml :intr=>intr do
      %{
.history-header
  %span.slotter
    = paginate intr, :remote=>true, :theme=>'twitter-bootstrap-3'
  %div.history-legend
    %span.glyphicon.glyphicon-plus-sign.diff-green
    %span
      = Card::Diff.render_added_chunk("Added")
      |
    %span.glyphicon.glyphicon-minus-sign.diff-red
    %span
      = Card::Diff.render_deleted_chunk("Deleted")
      }
    end
  end

  view :act_summary do |args|
    render_act :summary, args
  end

  view :act_expanded do |args|
    render_act :expanded, args
  end

  def render_act act_view, args
    act = (params['act_id'] and Card::Act.find(params['act_id'])) || args[:act]
    rev_nr = params['rev_nr'] || args[:rev_nr]
    current_rev_nr = params['current_rev_nr'] || args[:current_rev_nr] || card.current_rev_nr
    hide_diff = (params["hide_diff"]=="true") || args[:hide_diff]
    wrap( args.merge(:slot_class=>"revision-#{act.id} history-slot list-group-item") ) do
      render_haml :card=>card, :act=>act, :act_view=>act_view,
                  :current_rev_nr=>current_rev_nr, :rev_nr=>rev_nr,
                  :hide_diff=> hide_diff do
        %{
.act{:style=>"clear:both;"}
  .head
    .nr
      = "##{rev_nr}"
    .title
      .actor
        = link_to act.actor.name, card_url( act.actor.cardname.url_key )
      .time.timeago
        = time_ago_in_words(act.acted_at)
        ago
        - if act.actions.last.draft
          |
          %em.info
            Autosave
        - if current_rev_nr == rev_nr
          %em.label.label-info
            Current
        - elsif act_view == :expanded
          = rollback_link act.relevant_actions_for(card, act.actions.last.draft)
          = show_or_hide_changes_link hide_diff, :act_id=>act.id, :act_view=>act_view, :rev_nr=>rev_nr, :current_rev_nr=>current_rev_nr
  .toggle
    = fold_or_unfold_link :act_id=>act.id, :act_view=>act_view, :rev_nr=>rev_nr, :current_rev_nr=>current_rev_nr

  .action-container{:style=>("clear: left;" if act_view == :expanded)}
    - act.relevant_actions_for(card).each do |action|
      = send("_render_action_#{ act_view }", :action=>action )
      }
      end
    end
  end

  view :action_summary do |args|
    render_action :summary, args
  end

  view :action_expanded do |args|
    render_action :expanded, args
  end

  def render_action action_view, args
    action = args[:action] || card.last_action
    hide_diff = Env.params["hide_diff"]=="true" || args[:hide_diff]
    name_diff =
      if action.card == card
        name_changes(action, hide_diff)
      else
        link_to name_changes(action, hide_diff),
                path(:view=>:related, :related=>{:view=>"history",:name=>action.card.name}),
                :class=>'slotter label-label-default',
                :slotSelector=>".card-slot.card-frame",
                :remote=>true
      end

    type_diff =
        action.new_type? &&
        type_changes(action, hide_diff)

    content_diff =
        action.new_content? &&
        action.card.format.render_content_changes(:action=>action, :diff_type=>action_view, :hide_diff=>hide_diff)

    render_haml :action => action,
                :action_view => action_view,
                :name_diff => name_diff,
                :type_diff => type_diff,
                :content_diff => content_diff do
      %{
.action
  .summary
    %span.ampel
      = glyphicon 'minus-sign', (action.red? ? 'diff-red' : 'diff-invisible')
      = glyphicon 'plus-sign', (action.green? ? 'diff-green' : 'diff-invisible')
    = wrap_diff :name, name_diff
    = wrap_diff :type, type_diff if type_diff
    -if content_diff
      = glyphicon 'arrow-right', 'arrow'
      -if action_view == :summary
        = wrap_diff :content, content_diff
  -if content_diff and action_view == :expanded
    .expanded
      = wrap_diff :content, content_diff
       }
    end
  end

  def wrap_diff field, content
    if content.present?
      %{
         <span class="#{field}-diff#{ ' label label-default' if field == :name }">
         #{content}
         </span>
      }
    else
      ''
    end
  end


  def name_changes action, hide_diff=false
    old_name = (name = action.old_values[:name] and showname(name).to_s)
    if action.new_name?
      new_name = showname(action.new_values[:name]).to_s
      if hide_diff
        new_name
      else
        Card::Diff.complete(old_name,new_name)
      end
    else
      old_name
    end
  end

  def type_changes action, hide_diff=false
    change = hide_diff ? action.new_values[:cardtype] : action.cardtype_diff
    "(#{change})"
  end


  view :content_changes do |args|
    if args[:hide_diff]
      args[:action].new_values[:content]
    else
      args[:action].content_diff(args[:diff_type])
    end
  end

  def rollback_link action_ids
    if card.ok?(:update)
      "| " + link_to('Save as current', path(:action=>:update, :view=>:open, :action_ids=>action_ids),
        :class=>'slotter',:slotSelector=>'.card-slot.card-frame', :remote=>true, :method=>:post, :rel=>'nofollow')
    end
  end

  def fold_or_unfold_link args
    if (args[:act_view] == :expanded)
      toggled_view = :act_summary
    else
      toggled_view = :act_expanded
    end
    link_to '', args.merge(:view=>toggled_view),
              :class=>"slotter revision-#{args[:act_id]} #{ args[:act_view]==:expanded ? "arrow-down" : "arrow-right"}",
              :remote=>true
  end

  def show_or_hide_changes_link hide_diff, args
    "| " +  view_link( (hide_diff ? "Show" : "Hide") + " changes", :act_expanded,
      :path_opts=>args.merge(:hide_diff=>!hide_diff),
      :class=>'slotter', :remote=>true )
  end
end

def diff_args
  {:format=>:text}
end


