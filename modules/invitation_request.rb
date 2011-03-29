class Renderer
  view(:content, :type=>'invitation_request') do
    _render_naked + #ENGLISH
    if !card.new_card? # this if is not really necessary yet, but conceptually correct
      %{<div class="invite-links help instruction">
  <div><strong>#{card.name}</strong> asked for an invitation on #{ format_date(card.created_at) }</div>
  <div>} +
      ( if System.ok?(:create_accounts)
          link_to "Invite #{card.name}", {:controller=>'account', :action=>'accept', :card=>{:key=>card.key} }, :class=>'invitation-link'
        else ''
        end +
        if logged_in? and card.ok?(:delete)
          link_to_remote "Deny #{card.name}", { :url=>url_for("card/remove") }
        else ''
      end ) + %{
  </div>
</div>}
    end
  end
end

