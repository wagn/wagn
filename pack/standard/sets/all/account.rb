format :html do
  view :signin, :tags=>:unknown_ok do |args|  
    signin_core = wrap :signin, :frame=>:true do
      %{
        <div class="card-header"><h1>Sign In</h1></div>
        #{
          form_tag wagn_path('account/signin') do
            %{
              #{ fieldset :email, text_field_tag( 'login', params[:login], :id=>'login_field' ) }
              #{ fieldset :password, password_field_tag( 'password' ) }
              <fieldset>
                <div class="button-area">
                  #{ submit_tag 'Sign in' }
                  #{ link_to '...or sign up!', wagn_path('/account/signup') if Card.new(:type_id=>Card::AccountRequestID).ok? :create }
                </div>
              </fieldset>
            }
          end
        }
      }
    end
    %{
      <div id="sign-in">#{signin_core}</div>
      <div id="forgot-password">#{_render_forgot_password}</div>
    }    
  end
  
  
  view :forgot_password do |args|
    wrap :forgot_password, :frame=>:true do
      %{
        <div class="card-header"><h1>Forgot Password</h1></div>
        #{
          form_tag wagn_path('account/forgot_password') do
            %{
              <div class="card-body">
                #{ fieldset :email, text_field_tag( 'email', params[:email] ) }
              </div>
              <fieldset><div class="button-area">#{ submit_tag 'Reset my password' }</div></fieldset>
            }
          end
        }
      }
    end
  end
  
  view :signup, :tags=>:unknown_ok do |args|
    div_id = "main-body"
    help_text = if card.rule_card :add_help, :fallback=>:help
      _render :help, :setting=>:add_help
    else
      _render :help, :text => ( Account.create_ok? ? 
        'Send us the following, and we\'ll send you a password.' : 
        'All Account Requests are subject to review.'
      )
    end
    
    %{      
      <div id="signup-form">
        <iframe id="iframe-#{div_id}" height="0" width="0" frameborder="0"></iframe>
        #{
          wrap :signup, :frame=>true do
            %{
              <div class="card-header">
                <h1>Sign Up</h1>
                #{ help_text }
              </div>
              #{
                form_for :card, form_opts( wagn_path( '/account/signup' ), 'card-form') do |f|
                  @form = f
                  %{
                    #{ hidden_field_tag 'element', div_id }
                    #{ f.hidden_field :type_id }
                    <div class="card-body">      
                      #{ _render_name_editor :help=>'usually first and last name' }
                      #{ fieldset :email, text_field( :account, :email ) }
                      #{ with_inclusion_mode(:new) { edit_slot :label=>'other' } }
                    </div>

                    <fieldset><div class="button-area">#{ submit_tag 'Submit' }</div></fieldset>
                    #{ notice }
                  }
                end
              }
            }
          end
          }
      </div>
    }
  end
  
  view :invite, :tags=>:unknown_ok do |args|
    email = params[:account] || {}
    subject = email[:subject] || Card.setting('*invite+*subject') || ''
    message = email[:message] || Card.setting('*invite+*message') || ''

# I really don't think this is used any more.  Looked at several old wagns and couldn't see it in use.  I suppose we'll hear quickly if it's needed,
# in which case I think we should replace it with something more wagny.  Note that we can take substitute! out of SmartName.  (I never thought it fit)
# -efm
#    Card::Name.substitute!( message, {
#      :invitor => Account.current.name + " (#{Account.current.account.email})",
#      :invitee => card.name || ''}
#    )

    cardframe = wrap :invite, :frame=>true do
      %{
        <div class="card-header">
          <h1>Invite</h1>
          #{ _render_help :text=>"Accept account request from: #{link_to_page card.name}" if card.known? }
        </div>        
        #{

          form_for :card, :action=>params[:action] do |f|
            @form = f
            %{
              <div class="card-body">
                #{ hidden_field_tag 'element', "#{div_id}" }

                #{ 
                  if !card.known?
                    %{
                      #{ _render_name_editor :help=>'usually first and last name' }
                      #{ fieldset :email, text_field( :account, :email, :size=>60 ) }
                    }
                  else
                    %{
                      #{ hidden_field :card, :key }
                      #{ hidden_field :account, :email }
                    }
                  end
                }

                #{ fieldset :subject, text_field( :email, :subject, :value=>subject, :size=>60 ) }

                #{ fieldset :message, 
                    text_area( :email, :message, :value=>message, :rows=>15, :cols => 60 ),
                    :help => "We'll create a password and attach it to the email."
                }
              </div>

              <fieldset>
                <div class="button-area">      
                  #{ submit_tag 'Invite' }
                  #{ link_to 'Cancel', previous_location }
                </div>
              </fieldset>
          
              #{render_error} 
            }
          end
        }
      }
    end
    
  end
  
end
