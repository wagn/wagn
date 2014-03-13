# -*- encoding : utf-8 -*-

format :html do
  

  view :new do |args|
    #FIXME - make more use of standard new view
    args.merge!(
      :title=>'Sign Up',
      :optional_help => :show, #, :optional_menu=>:never
      :buttons => submit_tag( 'Submit' ),
      :hidden => {
        :success => Card.setting( "#{ Card[ card.accountable? ? :signup : :request ].name }+#{ Card[ :thanks ].name }" ),
        'card[type_id]' => card.type_id
      }
    )
      
    account = card.fetch :trait=>:account, :new=>{}

    frame_and_form :create, args, 'main-success'=>"REDIRECT" do
      [
        _render_name_fieldset( :help=>'usually first and last name' ),
        Account.as_bot { subformat(account)._render( :content_fieldset, :structure=>true ) },  #YUCK!!!!
        ( card.structure ? edit_slot : ''),
        _optional_render( :button_fieldset, args )
      ]
    end
  end


  view :edit do |args|
    args[:help_text] ||= "Accept account request"
    args[:hidden] ||= {
      :activate => 'true',
      :card => { :type_id => Card.default_accounted_type_id }
    } 
  
    frame_and_form :update, args do
      #_render_invitation_field
    end
  end

  view :core do |args|
    links = []
    #ENGLISH
=begin
    if Card.new(:type_id=>Card.default_accounted_type_id).ok? :create
      links << link_to( "Invite #{card.name}", path(:view=>:edit), :class=>'invitation-link')
    end
    if Account.signed_in? && card.ok?(:delete)
      links << link_to( "Deny #{card.name}", path(:action=>:delete), :class=>'slotter standard-delete', :remote=>true )
    end
=end
    process_content(_render_raw) +
    if (card.new_card?); '' else
      %{<div class="invite-links">
          <div><strong>#{card.name}</strong> requested an account on #{format_date(card.created_at) }</div>
          #{#%{<div>#{links.join('')}</div> } unless links.empty? 
          }
      </div>}
    end
  end
end

event :activate_by_token, :before=>:approve, :on=>:update do
  if token = Wagn::Env.params[:token]
    if id == Account.authenticate_by_token(token)
      subcards['+*account'] = {'+*status'=>'active'}
      self.type_id = Card.default_accounted_type_id
      Account.signin id #move this to extend?
      Account.as_bot      
    else
      abort :failure
    end
  end
end

event :preprocess_account_subcards, :before=>:process_subcards, :on=>:create do
  #FIXME: use codenames!
  email, password = subcards.delete('+*account+*email'), subcards.delete('+*account+*password')
  subcards['+*account'] ||={}
  subcards['+*account']['+*email']   = email if email
  subcards['+*account']['+*password' ]=password if password
end

#event :auto_approve, :after=>:approve, :on=>:create, :when=>proc { |c| c.accountable? } do
#  self.type_id = Card.default_accounted_type_id unless Wagn::Env[:no_auto_approval]
#end

send_signup_notifications = proc do |c|
  c.account and c.account.pending? and Card.setting '*request+*to'
end

event :signup_notifications, :after=>:extend, :on=>:create, :when=>send_signup_notifications do
  Mailer.signup_alert(self).deliver
end



