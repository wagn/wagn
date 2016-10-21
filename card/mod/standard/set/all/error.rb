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
  def view_for_unknown view
    case
    when focal? && ok?(:create) then :new
    when commentable?(view)     then view
    else super
    end
  end

  def commentable? view
    return false unless self.class.tagged(view, :comment) &&
                        show_view?(:comment_box, :hide)
    ok? :comment
  end

  def rendering_error exception, view
    details = Auth.always_ok? ? backtrace_link(exception) : error_cardname
    content_tag :span, class: "render-error alert alert-danger" do
      ["error rendering", details, "(#{view} view)"].join "\n"
    end
  end

  def backtrace_link exception
    class_up "alert", "render-error-message errors-view admin-error-message"
    warning = alert("warning", true) do
      %{
        <h3>Error message (visible to admin only)</h3>
        <p><strong>#{exception.message}</strong></p>
        <div>#{exception.backtrace * "<br>\n"}</div>
      }
    end
    link = link_to_card error_cardname, nil, class: "render-error-link"
    link + warning
  end

  view :unsupported_view, perms: :none, tags: :unknown_ok do |args|
    %(
      <strong>
        view <em>#{args[:unsupported_view]}</em>
        not supported for <em>#{error_cardname}</em>
      </strong>
    )
  end

  view :message, perms: :none, tags: :unknown_ok do
    frame { params[:message] }
  end

  view :missing do |args|
    return "" unless card.ok? :create  # should this be moved into ok_view?
    path_opts = args[:type] ? { card: { type: args[:type] } } : {}
    link_text = "Add #{fancy_title voo.title}"
    klass = "slotter missing-#{args[:denied_view] || args[:home_view]}"
    wrap { link_to_view :new, link_text, path: path_opts, class: klass }
  end

  view :closed_missing, perms: :none do
    %(<span class="faint"> #{showname} </span>)
  end

  view :conflict, error_code: 409 do
    actor_link = link_to_card card.last_action.act.actor.cardname
    expanded_act = wrap do
      _render_act_expanded act: card.last_action.act, current_rev_nr: 0
    end
    class_up "card-slot", "error-view"
    wrap do # ENGLISH below
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

  view :errors, perms: :none do
    return if card.errors.empty?
    voo.title = card.name.blank? ? "Problems" : "Problems with #{card.name}"
    voo.hide! :menu
    class_up "card-frame", "panel panel-warning"
    class_up "alert", "card-error-msg"
    frame do
      card.errors.map do |attrib, msg|
        alert "warning", true do
          attrib == :abort ? msg : standard_error_message(attrib, msg)
        end
      end
    end
  end

  def standard_error_message attribute, message
    "<strong>#{attribute.to_s.upcase}:</strong> #{message}"
  end

  view :not_found do # ug.  bad name.
    voo.hide! :menu
    voo.title = "Not Found"
    card_label = card.name.present? ? "<em>#{card.name}</em>" : "that"
    frame do
      [wrap_with(:h2) { "Could not find #{card_label}." },
       sign_in_or_up_links]
    end
  end

  def sign_in_or_up_links
    return if Auth.signed_in?
    signin_link = link_to_card :signin, "Sign in"
    signup_link = link_to "Sign up", path: { action: :new, mark: :signup }
    wrap_with(:div) { "#{signin_link} or #{signup_link} to create it." }
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
      frame do # ENGLISH below
        message =
          case
          when task != :read && Card.config.read_only
            "We are currently in read-only mode.  Please try again later."
          when Auth.signed_in?
            "You need permission #{to_task}"
          else
            signin_link = link_to_card :signin, "sign in"
            or_signup_link =
              if Card.new(type_id: Card::SignupID).ok? :create
                "or " +
                  link_to("sign up", path: { action: "new", mark: :signup })
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
