require 'haml'

REVISIONS_PER_PAGE = 2
# has to be called always and before :set_name and :process_subcards
def create_act_and_action
  #@current_act = (@supercard ? @supercard.current_act : Card::Act.create(:ip_address=>Env.ip)) #acts.build(:ip_address=>Env.ip
  #@current_action = actions.build(:action_type=>@action, :card_act_id=>@current_act.id)
  
  @current_act = (@supercard ? @supercard.current_act : acts.build(:ip_address=>Env.ip))
  @current_action = actions.build(:action_type=>@action)
  @current_action.act = @current_act

  if (@supercard and @supercard !=self)
    @current_action.super_action = @supercard.current_action
  end
end

event(:create_act_and_action_for_save,   :before=>:process_subcards, :on=>:save)   { create_act_and_action }
event(:create_act_and_action_for_delete, :after =>:approve,          :on=>:delete) { create_act_and_action }


event :complete_act, :after=>:extend do
  if not @supercard and @current_act.actions.empty?
     @current_act.delete
  end
end


event :rollback, :after=>:extend, :on=>:update, :when=>proc{ |c| Env.params['action_ids'] } do
  if !Env.action_ids.class == Array
    #TODO Error handling? params 
  else
    actions = action_ids.map do |a_id|
      Action.find(a_id) || nil
    end.compact
    
    revision = { :subcards => {}}
    actions.each do |action|
      if action.card_id == id
        revision.merge!(revision(action)) 
      else
        revision[:subcards].merge!(revision(action))
      end
    end
    
    Env.params['action_ids'] = nil
    update_attributes! revision
    actions.each do |action|
      action.card.attachment_symlink_to action.id
    end
  end
end


def intrusive_acts  # all acts with actions on self and on cards included in self
  @intrusive_acts ||= begin
    Act.joins(:actions).where('card_actions.card_id IN (:card_ids)', {:card_ids => (included_card_ids << id)}).uniq.order(:id).reverse_order
    #i_acts = (included_cards << self).map{|c| c.actions.map(&:act) }.flatten.uniq
    #i_acts.uniq.sort{ |a,b| b.acted_at <=> a.acted_at }
  end
end

def included_card_ids
  Card::Reference.select(:referee_id).where( :ref_type => 'I', :referer_id=>id ).map(&:referee_id).compact.uniq
  #@included_cards ||= Card.search(:referred_to_by => name)
end 
  


format :html do
  view :history do |args|
    frame args.merge( :content=>true, :subheader=>_render_revision_subheader ) do
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
      # %span.revision-info{:style=>"text-align: left;"}
      #   Revisions for
      #   = "#{card.name}"
      %{
.history-header  
  = paginate intr, :html=> {:remote=>true, :class=>'slotter'}
  %span.history-legend{:style=>"text-align:right;"}
    %span.traffic-light.diff-green
      &nbsp;
    %span
      = Card::Diff.render_added_chunk("Added")
      |
    %span.traffic-light.diff-red
      &nbsp;
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
    current_rev_nr = params['current_rev_nr'] || args[:current_rev_nr] || card.intrusive_acts.size
    hide_diff = (params["hide_diff"]=="true") || args[:hide_diff]
    if (act_view == :expanded)
      toggled_view = :act_summary
    else
      toggled_view = :act_expanded
    end
    wrap( args.merge(:slot_class=>"revision-#{act.id}") ) do
      render_haml :card=>card, :act=>act, :act_view=>act_view, 
                  :current_rev_nr=>current_rev_nr, :rev_nr=>rev_nr, 
                  :toggled_view=>toggled_view,
                  :hide_diff=> hide_diff do 
        %{
.act{:style=>"clear:both;"}
  .head
    .nr
      = "##{rev_nr}"
    .title
      .actor
        = act.actor.name
      .time.timeago
        = time_ago_in_words(act.acted_at)
        ago
        - if current_rev_nr == rev_nr
          |
          %em 
            Current
        - elsif act_view == :expanded
          |
          %em
            = rollback_link act.relevant_actions_for(card)
          |
          = link_to_view (hide_diff ? "Show" : "Hide") + " changes", :act_expanded, 
              :path_opts=>{:hide_diff=>!hide_diff, :act_id=>act.id, :act_view=>act_view, :rev_nr=>rev_nr, :current_rev_nr=>current_rev_nr}, 
              :class=>'slotter', :remote=>true
  .toggle
    = link_to '', path(:view=>toggled_view, :act_id=>act.id, :act_view=>act_view, :rev_nr=>rev_nr, :current_rev_nr=>current_rev_nr), 
              :class=>"slotter revision-#{act.id} #{ act_view==:expanded ? "arrow-down" : "arrow-right"}", 
              :remote=>true
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
    render_haml :action => action, 
                :action_view=>action_view, 
                :hide_diff=>Env.params["hide_diff"]=="true" || args[:hide_diff] do
      %{
.action
  .summary
    .ampel   
      .traffic-light{:class=> ("diff-red" if action.red?) }
        &nbsp;
      .traffic-light{:class=> ("diff-green" if action.green?) }
        &nbsp;
    .name-diff{:onClick=>"self.location.href='#{wagn_path(action.card)}?view=history'"}
      = name_changes action, hide_diff
    -if action.new_type?
      .type-diff
        = type_changes action, hide_diff
    -if action.new_content?
      .arrow
        %i.fa.fa-arrow-right
      .content-diff{:style=>("clear:left; padding: 10px 10px 10px 10px;" if action_view == :expanded)}
        = content_changes action, action_view, hide_diff
        }
    end
  end

  
  def name_changes action, hide_diff=false
    old_name = (name = action.old_values[:name] and showname(name))
                
    if action.new_name?
      new_name = showname(action.new_values[:name])
      if hide_diff 
        new_name
      else
        Card::Diff::DiffBuilder.new(old_name,new_name).complete
      end
    else
      old_name
    end
  end
  
  def type_changes action, hide_diff=false
    change = hide_diff ? action.edit_info[:new_type] : action.diff[:type]
    "(#{change})"
  end
  
  def content_changes action, diff_type, hide_diff=false
    if hide_diff 
      action.new_values[:new_content]
    else 
      action.content_diff(diff_type)
    end
  end

  def rollback_link action_ids
    if card.ok?(:update) 
      link_to 'Save as current', path(:action=>:update, :view=>:open, :action_ids=>action_ids,),
        :class=>'slotter',:slotSelector=>'.card-slot.card-frame', :remote=>true, :method=>:post
    end
  end

  # old stuff
  

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


  #
  def render_haml locals={}, &block
    Haml::Engine.new(block.call).render(binding, locals)
  end


end