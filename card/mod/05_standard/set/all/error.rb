

format do
  view :closed_missing, :perms=>:none, :closed=>true do |args|
    ''
  end
  
  view :missing, :perms=>:none do |args|
    ''
  end

  view :not_found, :perms=>:none, :error_code=>404 do |args|
    %{ Could not find #{card.name.present? ? %{"#{card.name}"} : 'the card requested'}. }
  end

  view :server_error, :perms=>:none, :error_code=>500 do |args|
    %{ Wagn Hitch!  Server Error. Yuck, sorry about that.\n}+
    %{ To tell us more and follow the fix, add a support ticket at http://wagn.org/new/Support_Ticket }
  end

  view :denial, :perms=>:none, :error_code=>403 do |args|
    focal? ? 'Permission Denied' : ''
  end

  view :bad_address, :perms=>:none, :error_code=>404 do |args|
    %{ 404: Bad Address }
  end

  view :too_deep, :perms=>:none, :closed=>true do |args|
    %{ Man, you're too deep.  (Too many levels of inclusions at a time) }
  end

  view :too_slow, :perms=>:none, :closed=>true do |args|
    %{ Timed out! #{ showname } took too long to load. }
  end 
end


format :html do
  def view_for_unknown view, args
    case
    when focal? && ok?( :create )   ;  :new
    when commentable?( view, args ) ;  view
    else                               super
    end
  end
  
  def commentable? view, args
    self.class.tagged view, :comment                                   and 
    show_view? :comment_box, args.merge( :default_visibility=>:hide )  and #developer or wagneer has overridden default
    ok? :comment
  end
  
  def rendering_error exception, view
    details = if Auth.always_ok?
                card_link(error_cardname, :class=>'render-error-link') +
                    alert('warning', :dismissible=>true, :alert_class=>"render-error-message errors-view admin-error-message") do
                      %{
                        <h3>Error message (visible to admin only)</h3>
                        <p><strong>#{ exception.message }</strong></p>
                        <div>
                          #{exception.backtrace * "<br>\n"}
                        </div>
                        </div>
                      }
                  end
              else
                error_cardname
              end
                 
    content_tag :span, :class=>'render-error alert alert-danger' do
      [
        'error rendering',
        details,
        "(#{view} view)"
      ].join "\n"
    end
  end

  def unsupported_view view
    "<strong>view <em>#{view}</em> not supported for <em>#{error_cardname}</em></strong>"
  end
  
  view :message, :perms=>:none, :tags=>:unknown_ok do |args|
    frame args do
      params[:message]
    end
  end


  view :missing do |args|
    return '' unless card.ok? :create  # should this be moved into ok_view?

    opts = { :remote=>true, :class=>"slotter missing-#{ args[:denied_view] || args[:home_view]}" }
    opts[:path_opts] = { :type=> args[:type] } if args[:type]

    wrap args do
      view_link "Add #{ fancy_title args[:title] }", :new, opts
    end
  end

  view :closed_missing, :perms=>:none do |args|
    %{<span class="faint"> #{ showname } </span>}
  end
  
  
  
  view :conflict, :error_code=>409 do |args|
    # FIXME: hack to get the conflicted update as a proper act for the diff view
    card.current_act.save
    action = card.actions.last  # the unsaved action with the new changes
    action.card_act_id = card.current_act.id
    action.draft = true
    action.save
    card.store_changes  # deletes action if there are no changes 

    # as a consequence card.current_act.actions can be empty when both users made exactly the same changes
    # but an act is always supposed to have at least one action, so we have to delete the act to avoid bad things
    card.current_act.reload
    if card.current_act.actions.empty?
      card.current_act.delete
      card.current_act = nil
    end

    wrap args.merge( :slot_class=>'error-view' ) do  #ENGLISH below
      alert 'warning' do
        %{<strong>Conflict!</strong><span class="new-current-revision-id">#{card.last_action_id}</span>
          <div>#{ card_link card.last_action.act.actor.cardname } has also been making changes.</div>
          <div>Please examine below, resolve above, and re-submit.</div>
          #{ wrap do |args|
              if card.current_act
                _render_act_expanded :act=>card.current_act, :current_rev_nr => 0
              else
                "No difference between your changes and #{card.last_action.act.actor.name}'s version."
              end
            end
           } 
        }
      end
    end
  end
  
  view :errors, :perms=>:none do |args|
    if card.errors.any?
      title = %{ Problems #{%{ with #{card.name} } unless card.name.blank?} }
      frame args.merge(:slot_class=>"panel panel-warning", :title=>title, :hide=>'menu' ) do
        card.errors.map do |attrib, msg|
          msg = "<strong>#{attrib.to_s.upcase}:</strong> #{msg}" unless attrib == :abort
          alert 'warning', :dismissible=>true, :alert_class=>'card-error-msg' do
            msg
          end
        end  
      end
    end
  end

  view :not_found do |args| #ug.  bad name.
    sign_in_or_up_links = if !Auth.signed_in?
      %{<div>
        #{ card_link :signin, :text=>'Sign in' } or
        #{ link_to 'Sign up', card_path('new/:signup') } to create it.
       </div>}
    end
    frame args.merge(:title=>'Not Found', :optional_menu=>:never) do
      %{
        <h2>Could not find #{card.name.present? ? "<em>#{card.name}</em>" : 'that'}.</h2>
        #{sign_in_or_up_links}
      }
    end
  end

  view :denial do |args|
    to_task = if task = args[:denied_task]
      %{to #{task} this.}
    else
      'to do that.'
    end
    if !focal?
      %{<span class="denied"><!-- Sorry, you don't have permission #{to_task} --></span>}
    else
      frame args do #ENGLISH below
        message = case
        when task != :read && Card.config.read_only
          "We are currently in read-only mode.  Please try again later."
        when Auth.signed_in?
          "You need permission #{to_task}"
        else
          or_signup = if Card.new(:type_id=>Card::SignupID).ok? :create
            "or #{ link_to 'sign up', card_url('new/:signup') }"
          end
          save_interrupted_action(request.env['REQUEST_URI'])
          "You have to #{ link_to 'sign in', card_url(':signin') } #{or_signup} #{to_task}"
        end

        %{<h1>Sorry!</h1>\n<div>#{ message }</div>}
      end
    end
  end


  view :server_error do |args|
    %{
    <body>
      <div class="dialog">
        <h1>Wagn Hitch :(</h1>
        <p>Server Error. Yuck, sorry about that.</p>
        <p><a href="http://www.wagn.org/new/Support_Ticket">Add a support ticket</a>
            to tell us more and follow the fix.</p>
      </div>
    </body>
    }
  end
  
end
