
REVISIONS_PER_PAGE = 10
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
      %{
.history-header  
  = paginate intr, :html=> {:remote=>true, :class=>'slotter'}
  %span.history-legend{:style=>"text-align:right;"}
    %i.fa.fa-circle.diff-green
    %span
      = Card::Diff.render_added_chunk("Added")
      |
    %i.fa.fa-circle.diff-red
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
    wrap( args.merge(:slot_class=>"revision-#{act.id}") ) do
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
        = link_to act.actor.name, wagn_url( act.actor )
      .time.timeago
        = time_ago_in_words(act.acted_at)
        ago
        - if current_rev_nr == rev_nr
          |
          %em.current
            Current
        - elsif act_view == :expanded
          = rollback_link act.relevant_actions_for(card)
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
    render_haml :action => action, 
                :action_view=>action_view, 
                :hide_diff=>Env.params["hide_diff"]=="true" || args[:hide_diff] do
      %{
.action
  .summary
    %span.ampel   
      %i.fa.fa-circle{:class=>(action.red? ? 'diff-red' : 'diff-invisible')}
      %i.fa.fa-circle{:class=>(action.green? ? 'diff-green' : 'diff-invisible')}
    -if action.card == card
      %span.name-diff
        = name_changes(action, hide_diff)    
    -else
      =  link_to path(:view=>:related, :related=>{:view=>"history",:name=>action.card.name}), :class=>'slotter name-diff', 
                   :slotSelector=>".card-slot.card-frame", :remote=>true do
        - name_changes(action, hide_diff)    
    -if action.new_type?
      %span.type-diff
        = type_changes action, hide_diff
    -if action.new_content?
      %i.fa.fa-arrow-right.arrow
      -if action_view == :summary 
        %span.content-diff
          = content_changes action, action_view, hide_diff
  -if action.new_content? and action_view == :expanded
    .expanded
      %span.content-diff
        = content_changes action, action_view, hide_diff
        }
    end
  end

  
  def name_changes action, hide_diff=false
    old_name = (name = action.old_values[:name] and showname(name))
                
    if action.new_name?
      new_name = showname(action.new_values[:name]).to_s
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
    change = hide_diff ? action.new_values[:cardtype] : action.diff[:cardtype]
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
      "| " + link_to('Save as current', path(:action=>:update, :view=>:open, :action_ids=>action_ids,),
        :class=>'slotter',:slotSelector=>'.card-slot.card-frame', :remote=>true, :method=>:post)
    end
  end

  def fold_or_unfold_link args
    if (args[:act_view] == :expanded)
      toggled_view = :act_summary
    else
      toggled_view = :act_expanded
    end
    link_to '', path(args.merge(:view=>toggled_view)), 
              :class=>"slotter revision-#{args[:act_id]} #{ args[:act_view]==:expanded ? "arrow-down" : "arrow-right"}", 
              :remote=>true
  end
  
  def show_or_hide_changes_link hide_diff, args
    "| " +  link_to_view( (hide_diff ? "Show" : "Hide") + " changes", :act_expanded, 
      :path_opts=>args.merge(:hide_diff=>!hide_diff), 
      :class=>'slotter', :remote=>true )
  end
  
  def render_haml locals={}, &block
    Haml::Engine.new(block.call).render(binding, locals)
  end
  
  
  # old stuff
  

  def revision_link text, revision, name, accesskey='', mode=nil
    link_to text, path(:view=>:history, :rev=>revision, :mode=>(mode || params[:mode] || true) ),
      :class=>"slotter", :remote=>true, :rel=>'nofollow'
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
end