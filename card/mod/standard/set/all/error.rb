def copy_errors card
  card.errors.each do |att, msg|
    errors.add att, msg
  end
end

format do
  view :closed_missing, perms: :none, closed: true do
    ""
  end

  view :unsupported_view, perms: :none, tags: :unknown_ok do |args|
    "view (#{args[:unsupported_view]}) not supported for #{error_cardname}"
  end

  view :missing, perms: :none do
    ""
  end

  view :not_found, perms: :none, error_code: 404 do |_args|
    error_name = card.name.present? ? card.name : "the card requested"
    %( Could not find #{error_name}. )
  end

  view :server_error, perms: :none, error_code: 500 do
    %(
      Wagn Hitch!  Server Error. Yuck, sorry about that.
      To tell us more and follow the fix,
      add a support ticket at http://wagn.org/new/Support_Ticket
    )
  end

  view :denial, perms: :none, error_code: 403 do
    focal? ? "Permission Denied" : ""
  end

  view :bad_address, perms: :none, error_code: 404 do
    %( 404: Bad Address )
  end

  view :too_deep, perms: :none, closed: true do
    %{ Man, you're too deep.  (Too many levels of nests at a time) }
  end

  view :too_slow, perms: :none, closed: true do
    %( Timed out! #{showname} took too long to load. )
  end
end

format :html do
  def view_for_unknown view, args
    case
    when focal? && ok?(:create)   then :new
    when commentable?(view, args) then view
    else super
    end
  end

  def commentable? view, args
    return false unless self.class.tagged view, :comment
    visibility_args = args.merge default_visibility: :hide
    return false unless show_view? :comment_box, visibility_args
    ok? :comment
  end

  def rendering_error exception, view
    details = Auth.always_ok? ? backtrace_link(exception) : error_cardname
    content_tag :span, class: "render-error alert alert-danger" do
      ["error rendering", details, "(#{view} view)"].join "\n"
    end
  end

  def backtrace_link exception
    warning_options = {
      dismissible: true,
      alert_class: "render-error-message errors-view admin-error-message"
    }
    warning = alert("warning", warning_options) do
      %{
        <h3>Error message (visible to admin only)</h3>
        <p><strong>#{exception.message}</strong></p>
        <div>#{exception.backtrace * "<br>\n"}</div>
      }
    end
    card_link(error_cardname, class: "render-error-link") + warning
  end

  view :unsupported_view, perms: :none, tags: :unknown_ok do |args|
    %(
      <strong>
        view <em>#{args[:unsupported_view]}</em>
        not supported for <em>#{error_cardname}</em>
      </strong>
    )
  end

  view :message, perms: :none, tags: :unknown_ok do |args|
    frame args do
      params[:message]
    end
  end

  view :missing do |args|
    return "" unless card.ok? :create  # should this be moved into ok_view?

    link_opts = {
      remote: true,
      class: "slotter missing-#{args[:denied_view] || args[:home_view]}"
    }
    link_opts[:path_opts] = { type: args[:type] } if args[:type]

    wrap args do
      view_link "Add #{fancy_title args[:title]}", :new, link_opts
    end
  end

  view :closed_missing, perms: :none do
    %(<span class="faint"> #{showname} </span>)
  end

  view :conflict, error_code: 409 do |args|
    actor_link = card_link card.last_action.act.actor.cardname
    expanded_act = wrap(args) do
      _render_act_expanded act: card.last_action.act, current_rev_nr: 0
    end
    wrap args.merge(slot_class: "error-view") do # ENGLISH below
      alert "warning" do
        %(
          <strong>Conflict!</strong>
          <span class="new-current-revision-id">#{card.last_action_id}</span>
          <div>#{actor_link} has also been making changes.</div>
          <div>Please examine below, resolve above, and re-submit.</div>
          #{expanded_act}
        )
      end
    end
  end

  view :errors, perms: :none do |args|
    if card.errors.any?
      title = "Problems"
      title += " with #{card.name}" unless card.name.blank?
      frame_opts = { panel_class: "panel panel-warning",
                     title: title, hide: "menu" }
      frame args.merge(frame_opts) do
        card.errors.map do |attrib, msg|
          unless attrib == :abort
            msg = "<strong>#{attrib.to_s.upcase}:</strong> #{msg}"
          end
          alert "warning", dismissible: true, alert_class: "card-error-msg" do
            msg
          end
        end
      end
    end
  end

  view :not_found do |args| # ug.  bad name.
    sign_in_or_up_links =
      unless Auth.signed_in?
        signin_link = card_link :signin, text: "Sign in"
        signup_link = link_to "Sign up", card_path("new/:signup")
        %(<div>#{signin_link} or #{signup_link} to create it.</div>)
      end
    frame args.merge(title: "Not Found", optional_menu: :never) do
      card_label = card.name.present? ? "<em>#{card.name}</em>" : "that"
      %(<h2>Could not find #{card_label}.</h2> #{sign_in_or_up_links})
    end
  end

  view :denial do |args|
    task = args[:denied_task]
    to_task = task ? "to #{task} this." : "to do that."
    if !focal?
      %(
        <span class="denied">
          <!-- Sorry, you don't have permission #{to_task} -->
        </span>
      )
    else
      frame args do # ENGLISH below
        message =
          case
          when task != :read && Card.config.read_only
            "We are currently in read-only mode.  Please try again later."
          when Auth.signed_in?
            "You need permission #{to_task}"
          else
            signin_link = link_to "sign in", card_url(":signin")
            or_signup_link =
              if Card.new(type_id: Card::SignupID).ok? :create
                "or " + link_to("sign up", card_url("new/:signup"))
              end
            Env.save_interrupted_action(request.env["REQUEST_URI"])
            "Please #{signin_link} #{or_signup_link} #{to_task}"
          end

        %(
          <h1>Sorry!</h1>
          <div>#{message}</div>
        )
      end
    end
  end

  view :server_error do
    %{
      <body>
        <div class="dialog">
          <h1>Wagn Hitch :(</h1>
          <p>Server Error. Yuck, sorry about that.</p>
          <p>
            <a href="http://www.wagn.org/new/Support_Ticket">
              Add a support ticket
            </a>
            to tell us more and follow the fix.
          </p>
        </div>
      </body>
    }
  end
end
