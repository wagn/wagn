# -*- encoding : utf-8 -*-

format :html do
  view :new do |args|
    #FIXME - make more use of standard new view
    frame_args = args.merge :title=>'Sign Up', :show_help=>true #, :hide_menu=>true
    frame_args[:help_text] = case
      when card.rule_card( :add_help, :fallback=>:help ) ; nil
      when Account.create_ok?                            ; 'Send us the following, and we\'ll send you a password.' 
      else                                               ; 'All Account Requests are subject to review.'
      end

    success = Card.setting "#{ Card[ card.accountable? ? :signup : :request ].name }+#{ Card[ :thanks ].name }"
    # *signup+*thanks or *request+*thanks

    wrap_frame :signup, frame_args do
      card_form :create, 'card-form', 'main-success'=>"REDIRECT" do |f|
        @form = f
        %{
          #{ f.hidden_field :type_id }
          #{ hidden_field_tag :success, success }
          #{ _render_name_editor :help=>'usually first and last name' }
          #{ fieldset :email, text_field( 'card[account_args]', :email ), :editor=>'content' }
          #{ with_inclusion_mode(:new) { edit_slot } if card.structure }
          <fieldset><div class="button-area">#{ submit_tag 'Submit' }</div></fieldset>
        }
      end
    end
  end


  view :edit do |args|
    frame_args = { :title=>'Invite', :show_help=>true, :hide_menu=>true,
      :help_text=>"Accept account request from: #{link_to_page card.name}"
    }
  
    wrap_frame :edit, frame_args do
      card_form :update, 'card-form autosave' do |f|
        @form= f
        %{
          #{ hidden_field_tag 'card[type_id]', Card.default_accounted_type_id }
          #{ hidden_field_tag :activate, 'true'                               }
          #{ _render_invitation_field                                         }        
        }
      end
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

