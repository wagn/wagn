# -*- encoding : utf-8 -*-

format :html do
  view :new do |args|
    #FIXME - make more use of standard new view
    args = args.merge :title=>'Sign Up', :optional_help => :show #, :optional_menu=>:never
    args[:help_text] = case
      when card.rule_card( :add_help, :fallback=>:help ) ; nil
      when Account.create_ok?                            ; 'Send us the following, and we\'ll send you a password.' 
      else                                               ; 'All Account Requests are subject to review.'
      end

    args[:hidden] ||={}
    args[:hidden][:success] = Card.setting "#{ Card[ card.accountable? ? :signup : :request ].name }+#{ Card[ :thanks ].name }"
    args[:buttons] = submit_tag 'Submit'
    # *signup+*thanks or *request+*thanks

    frame_and_form :signup, :create, args, 'main-success'=>"REDIRECT" do
      %{
        #{ @form.hidden_field :type_id }
        #{ _render_name_fieldset :help=>'usually first and last name' }
        #{ _render_email_fieldset }
        #{ edit_slot if card.structure }
        #{ _optional_render :button_fieldset, args }
      }
    end
  end


  view :edit do |args|
    args[:help_text] ||= "Accept account request"
    args[:hidden] ||= {
      :activate => 'true',
      :card => { :type_id => Card.default_accounted_type_id }
    } 
  
    frame_and_form :edit, :update, args do
      _render_invitation_field
    end
  end

  view :core do |args|
    links = []
    #ENGLISH
    if Account.create_ok?
      links << link_to( "Invite #{card.name}", path(:view=>:edit), :class=>'invitation-link')
    end
    if Account.logged_in? && card.ok?(:delete)
      links << link_to( "Deny #{card.name}", path(:action=>:delete), :class=>'slotter standard-delete', :remote=>true )
    end

    process_content(_render_raw) +
    if (card.new_card?); '' else
      %{<div class="invite-links">
          <div><strong>#{card.name}</strong> requested an account on #{format_date(card.created_at) }</div>
          #{%{<div>#{links.join('')}</div> } unless links.empty? }
      </div>}
    end
  end
end


event :auto_approve, :after=>:approve, :on=>:create, :when=>proc { |c| c.accountable? } do
  self.type_id = Card.default_accounted_type_id unless Wagn::Env[:no_auto_approval]
end

send_signup_notifications = proc do |c|
  c.account and c.account.pending? and Card.setting '*request+*to'
end

event :signup_notifications, :after=>:extend, :on=>:create, :when=>send_signup_notifications do
  Mailer.signup_alert(self).deliver
end

