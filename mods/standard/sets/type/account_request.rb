# -*- encoding : utf-8 -*-

format :html do
  view :invitation_fields, :type=>:user

  view :new do |args|
    #FIXME - make more use of standard new view
    frame_args = args.merge :title=>'Sign Up', :show_help=>true, :hide_menu=>true
    frame_args[:help_text] = case
      when card.rule_card( :add_help, :fallback=>:help ) ; nil
      when Account.create_ok?                            ; 'Send us the following, and we\'ll send you a password.' 
      else                                               ; 'All Account Requests are subject to review.'
      end

    redirect = Card.setting "#{ Card[ card.accountable? ? :signup : :request ].name }+#{ Card[ :thanks ].name }"
    # *signup+*thanks or *request+*thanks

    wrap_frame :signup, frame_args do
      card_form :create, 'card-form', 'main-success'=>"REDIRECT: #{redirect}" do |f|
        @form = f
        %{
          #{ f.hidden_field :type_id }
          #{ _render_name_editor :help=>'usually first and last name' }
          #{ fieldset :email, text_field( 'card[account_args]', :email ) }
          #{ with_inclusion_mode(:new) { edit_slot :label=>'other' } }

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
          #{ f.hidden_field :type_id, Card::UserID  }
          #{ hidden_field_tag :activate, true       }
          #{ _render_invitation_field               }        
        }
      end
    end
  end

  view :core do |args|
    links = []
    #ENGLISH
    if Account.create_ok?
      links << link_to( "Invite #{card.name}", path(:action=>:edit), :class=>'invitation-link')
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




event :set_type_and_status, :after=>:approve, :on=>:create do
  if accountable?
    self.type_id = Card::UserID
  else
    @account_args ||= {}
    @account_args[:status] = 'pending'
  end
end

event :create_requested_account, :after=>:store, :on=>:create do
  create_account
end



event :signup_notifications, :after=>:extend, :on=>:create do
  Mailer.signup_alert(self).deliver if Card.setting '*request+*to'
end


event :block_user, :after=>:store, :on=>:delete do
  if account = Account[ self.id ]
    account.update_attributes :status=>'blocked'
  end
end
