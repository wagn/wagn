class Wagn::Renderer::Html
  define_view(:show) do |args|
    @main_view = args[:view] || params[:view] || params[:home_view] || :open
    
    if ajax_call?
      self.render(@main_view)
    else
      self.render_layout
    end
  end

  define_view(:layout) do |args|
    if @main_content = args.delete(:main_content)
      @card = Card.fetch_or_new('*placeholder')
    else
      @main_card = card
    end

    layout_content = get_layout_content(args)
    
    args[:params] = params 
    process_content(layout_content, args)
  end


  define_view(:content) do |args|
    c = _render_core(args)
    c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
    wrap(:content, args) { wrap_content(:content, c) }
  end

  define_view(:titled) do |args|
    wrap(:titled, args) do
      content_tag( :h1, fancy_title(card.name)) + wrap_content(:titled, _render_core(args))
    end
  end

  define_view(:open) do |args|
    comment_box = ''
    if card && card.ok?(:comment)
      comment_box = 
      %{<div class="comment-box nodblclick"> #{
        card_form :comment do |f|
          %{#{f.text_area :comment, :rows=>3 }<br/> #{
          if User.current_user.login == "anon"
            card.comment_author= (session[:comment_author] || params[:comment_author] || "Anonymous") #ENGLISH
            %{<label>My Name is:</label> #{ f.text_field :comment_author }}
          end}
          <input type="submit" value="Comment"/>}
        end}
      </div>}
    end
    
    wrap(:open, args) do
      %{ 
         #{ header }
         #{ wrap_content( :open, _render_open_content(args) ) } 
         #{ comment_box }
         #{ notice }
         #{ footer }
      }
    end
  end

  define_view(:closed) do |args|
    wrap(:closed, args) do
      %{
        <div class="card-header">
          <div class="title-menu"> 
            #{ link_to fancy_title(card), path(:view, :view=>:open), :title=>"open #{card.name}",
                :class=>'title right-arrow slotter', :remote=>true } 
            #{ page_icon(card.name) } &nbsp;
          </div>
        </div> 
        #{ wrap_content :closed, render_closed_content }
      }
    end
  end



  define_view(:new) do |args|
    @help_card = card.rule_card('add help', 'edit help')
    if ajax_call?
      new_content :cancel_href=>path(:view, :view=>:missing), :cancel_class=>'slotter'
    else
      %{
        <h1 class="page-header">
          New #{ card.typecode == 'Basic' && '' || card.typename } Card
        </h1>
        #{ new_instruction }
        #{ new_content :cancel_href=>Card.path_setting('/*previous'), :cancel_class=>'redirecter' }
      }
    end
  end

  define_view(:editor) do |args|
    form.text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>unique_id
  end

  define_view(:missing) do |args|
    #warn "missing #{args.inspect} #{caller[0..10]*"\n"}"
    new_args = { 'card[name]'=>card.name }
    new_args['card[type]'] = args[:type] if args[:type]

    wrap(:missing, args) do
      link_to raw("Add <strong>#{ @showname || card.name }</strong>"), path(:new, new_args),
        :class=>'slotter', :remote=>true
    end
  end
  
###---(  EDIT VIEWS )
  define_view(:edit) do |args|
    attrib = params[:attribute] || 'content'
    attrib = 'name' if params[:card] && params[:card][:name]
    wrap(:edit, args) do
      %{#{ header}
       <style>.SELF-#{card.css_name} .edit-area .namepart-#{card.css_name} { display: none; } </style>
       <div class="card-body">
         #{ edit_submenu attrib}
         #{ render "edit_#{attrib}" }
         #{ notice }
       </div>}
    end
  end

  define_view (:edit_content) do |args|
    %{#{
      if inst = card.rule_card('edit help')
        %{<div class="instruction">#{ raw subrenderer(inst).render_core }</div>}
      end}#{
      if card.hard_template and card.hard_template.ok? :read
       %{<div class="instruction">Formatted by a #{ link_to_page 'form card', card.hard_template.name }</div>}
      end}

      <div class="card-editor edit-area #{card.hard_template ? :templated : ''}">
      
      #{ card_form :update, 'card-form card-edit-form autosave' do |f|
        %{<div>#{ @form= f; edit_slot(args) }</div>

        <div class="edit-button-area"> #{
          if !card.new_card?
            button_tag "Delete", :href=>path(:remove), :type=>'button', 'data-type'=>'html',
              :class=>'edit-delete-button delete-button slotter standard-delete'
              
          end}#{
          submit_tag 'Submit', :class=>'edit-submit-button'}#{
          button_tag 'Cancel', :class=>'edit-cancel-button slotter', :href=>path(:view), :type=>'button'}
        </div>}
       end}
    </div>
      }
  end

  define_view(:edit_name) do |args|
    %{
      <div class="edit-area edit-name">
       <h2>Change Name</h2>
      #{ card_form path(:update, :id=>card.id), 'card-edit-name-form', 'main-success'=>'REDIRECT' do |f|
          
          
          
        %{<div>to #{ raw f.text_field( :name, :class=>'card-name-field', :value=>card.name, :autocomplete=>'off' ) } </div>
        #{ hidden_field_tag :success, 'TO-CARD' }
        #{

     if !card.errors[:confirmation_required].empty?
       card.confirm_rename = card.update_referencers = true
       params[:attribute] = 'name'
       
      %{#{if dependents = card.dependents and !dependents.empty?  #ENGLISH below
        %{<div class="instruction">
          <div>This will change the names of these cards, too:</div>
          <ul>#{
            dependents.map do |dep|
              %{<li>#{ link_to_page raw(formal_title dep), dep.name }</li>}
            end.join }
          </ul>
        </div>}
      end}#{

      if children = card.extended_referencers and !children.empty? #ENGLISH below
        %{<h2>References</h2>
        <div class="instruction">
          <div>Renaming could break old links and inclusions on these cards:</div>
          <ul>
            #{children.map do |child|
              %{<li>#{ link_to_page raw(formal_title child), child.name }</li>}
              end.join}
          </ul>
          <div>You can...
            <div class="radio">#{ f.radio_button :update_referencers, 'true' }
              <strong>Fix them</strong>: update old references with new name
            </div>
            <div class="radio">#{ f.radio_button :update_referencers, 'false' }
              <strong>Leave them</strong>: let old references point to old name
            </div>
          </div>
        </div>}
      end}#{
      f.hidden_field 'confirm_rename' }}
    end
    }
    #{ submit_tag 'Rename', :class=>'edit-name-submit-button'}
    #{ button_tag 'Cancel', :class=>'edit-name-cancel-button slotter', :type=>'button', :href=>path(:edit, :id=>card.id)}
    }
    end}
    </div>}
  end

  define_view (:edit_type) do |args|
    %{
    <div class="edit-area edit-type">
    <h2>Change Type</h2> #{
      card_form :update, 'card-edit-type-form' do |f|
        #'main-success'=>'REDIRECT: TO-CARD', # adding this back in would make main cards redirect on cardtype changes
       
        
        
        %{ #{ hidden_field_tag :view, :edit }
        #{if card.typecode == 'Cardtype' and card.extension and !Card.search(:type=>card.cardname).empty? #ENGLISH
          %{<div>Sorry, you can't make this card anything other than a Cardtype so long as there are <strong>#{ card.name }</strong> cards.</div>}
        else
          %{<div>to #{ raw typecode_field :class=>'type-field edit-type-field' }</div>}
        end}
        <div>
          #{ submit_tag 'Submit', :disable_with=>'Submitting' }
          #{ button_tag 'Cancel', :href=>path(:edit), :type=>'button', :class=>'edit-type-cancel-button slotter' }
        </div>}
     end}
    </div>}
  end

  define_view(:edit_in_form) do |args|
    instruction = ''
    if instruction_card = (card.new_card? ? card.rule_card('add help', 'edit help') : card.rule_card('edit help'))
      ss = self.subrenderer(instruction_card)
      instruction = %{<div class="instruction">} +
      ss.with_inclusion_mode(:main) { ss.render :core } +
      '</div>'
    end
    eform = form_for_multi
    
    %{
<div class="edit-area in-multi card-editor RIGHT-#{ card.cardname.tag_name.to_cardname.css_name }">
  <div class="label-in-multi">
    <span class="title">
      #{ link_to_page raw(fancy_title(self.showname || card)), (card.new_card? ? card.cardname.tag_name : card.name) }
    </span>
  </div>     
  
  <div class="field-in-multi" #{ %{card-id="#{card.id}" card-name="#{h card.name}"} if card.id }>
    #{ self.content_field( eform, :nested=>true ) }
    #{ card.new_card? ? eform.hidden_field(:typecode) : '' }
  </div>
  #{instruction}
  <div style="clear:both"></div>
</div>
    }
  end

  define_view(:related) do |args|
    sources = [card.typename,nil]
    sources.unshift '*account' if card.extension_type=='User'
    items = sources.map do |source|
      c = Card.fetch(source ? source.to_cardname.star_rule(:related) : '*related')
      c && c.item_names
    end.flatten.compact
    
    #warn "items = #{items.inspect}"
#    @items << 'config'
    current = params[:attribute] || items.first.to_cardname.to_key

    wrap(:related, args) do
      %{#{header }
        <div class="submenu"> #{
          items.map do |item|
            key = item.to_cardname.to_key
            text = item.gsub('*','').gsub('subtab','').strip
            link_to text, path(:related, :attrib=>key), :remote=>true,
              :class=>"slotter #{key==current ? 'current-subtab' : ''}"
          end * "\n"}
         </div> #{
         notice }

        <div class="open-content related"> #{
          raw subrenderer(Card.fetch_or_new "#{card.name}+#{current}").render(:content) }
        </div>}
    end
  end

  define_view(:options) do |args|
    attribute = params[:attribute]
    attribute ||= (card.extension_type=='User' ? 'account' : 'settings')
    wrap(:options, args) do
      %{ #{ header } <div class="options-body"> #{ render "option_#{attribute}" } </div> #{ notice } }
    end
  end

  define_view(:option_account) do |args|
    locals = {:slot=>self, :card=>card, :extension=>card.extension }
    %{#{raw( options_submenu(:account) ) }#{

       card_form :update_account do |form|

         %{<table class="fieldset">
           #{if User.as_user==card.extension or User.ok?(:administrate_users)
              raw option_header( 'Account Details' ) +
                template.render(:partial=>'account/edit',  :locals=>locals)
           end }
        #{ render_option_roles } #{

           if options_need_save
             %{<tr><td colspan="3">#{ submit_tag 'Save Changes' }</td></tr>}
           end}
         </table>}
    end }}
  end

  define_view(:option_settings) do |args|
  

    related_sets = card.related_sets
    current_set = params[:current_set] || related_sets[(card.typecode=='Cardtype' ? 1 : 0)]

    options_submenu(:settings) +
      %{<div class="settings-tab">
        #{if !related_sets.empty?
          %{<div class="set-selection">
          #{
          form_tag path(:options, :attrib=>:settings), :method=>'get', :remote=>true, :class=>'slotter' }
            <label>Set:</label>
            <select name="current_set" class="set-select">
            #{ 
            related_sets.map do |set_name| 
               set_card = Card.fetch set_name
              %{<option value="#{ set_card.key }" #{set_card.key==current_set.to_cardname.key ? 'selected="selected"' : ''}>
                #{ set_card.label }
              </option>
              }
            end.join
            }
            </select>
          </div>}
        end
        }
  
  
        <div class="current-set">
          #{ raw( subrenderer(Card.fetch current_set).render :content ) }
        </div>
  #{
        if !card.extension_type && Card.toggle(card.rule('accountable')) && User.ok?(:create_accounts) && card.ok?(:update)
          %{<div class="new-account-link">
          #{ link_to %{Add a sign-in account for "#{card.name}"},
              path(:options, :attrib=>:new_account),
            :class=>'slotter new-account-link', :remote=>true }
          </div>}
         end}
      </div>}
  end

  define_view(:option_roles) do |args|
    roles = Role.find :all, :conditions=>"codename not in ('auth','anon')"
    user_roles = card.extension.roles 

    option_content = if User.ok? :assign_user_roles
      hidden_field_tag(:save_roles, true) +
      (roles.map do |role|
        if role.card && !role.card.trash
         %{<div style="white-space: nowrap">
           #{ check_box_tag "user_roles[%s]" % role.id, 1, user_roles.member?(role) ? true : false }
           #{ link_to_page role.card.name }
         </div>}
        end
      end.compact * "\n").html_safe
    else
      if user_roles.empty?
        'No roles assigned'  # #ENGLISH
      else
        (user_roles.map do |role|
          %{ <div>#{ link_to_page role.card.name }</div>}
        end * "\n").html_safe
      end
    end

    %{#{ raw option_header( 'User Roles' ) }#{
       option(option_content, :name=>"roles", 
      :help=>%{ <span class="small">"#{ link_to_page 'Roles' }" determine which #{ User.always_ok? ? link_to( 'global permissions', :controller=>'admin', :action=>'tasks') : 'global permissions'} a user has access to, as well as card-specific permissions like read, view, comment, and delete.  You can only change a user's roles if you have the global "assign user roles" permission. </span>}, #ENGLISH
      :label=>"#{card.name}'s Roles",
      :editable=>User.ok?(:assign_user_roles)
    )}}
  end

  define_view(:option_new_account) do |args|
    %{#{raw( options_submenu(:account) ) }#{
      card_form :create_account do |form|
      #ENGLISH below

        %{<table class="fieldset">
        #{render :partial=>'account/email' }
           <tr><td colspan="3" style><p>
       A password for a new sign-in account will be sent to the above address.
           #{ submit_tag 'Create Account' }
           </p></td></tr>
        </table>}
     end}}
  end

  define_view(:changes) do |args| 
    load_revisions
    wrap(:changes, args) do
      %{#{header unless params['no_changes_header']}
      <div class="revision-navigation">#{ revision_menu }</div>

      <div class="revision-header">
        <span class="revision-title">#{ @revision.title }</span>
        posted by #{ link_to_page @revision.author.card.name }
      on #{ format_date(@revision.created_at) } #{
      if !card.drafts.empty?
        %{<p class="autosave-alert">
          This card has an #{ autosave_revision }
        </p>}
      end}#{
      if @show_diff and @revision_number > 1  #ENGLISH
        %{<p class="revision-diff-header">
          <small>
            Showing changes from revision ##{ @revision_number - 1 }:
            <ins class="diffins">Added</ins> | <del class="diffmod">Removed</del>
          </small>
        </p>}
      end}
      </div>
      <div class="revision">#{_render_diff}</div>
      <div class="revision-navigation card-footer">#{ revision_menu }</div>}
    end
  end
  
  define_view(:diff) do |args|
    if @show_diff and @previous_revision
      diff @previous_revision.content, @revision.content
    else
      @revision.content
    end
  end
  
  define_view(:conflict) do |args|
    load_revisions
    wrap(:errors) do |args|
      %{<strong>Conflict!</strong><span class="new-current-revision-id">#{@revision.id}</span>
        <div>#{ link_to_page @revision.author.card.name } has also been making changes.</div>
        <div>Please examine below, resolve above, and re-submit.</div>
        #{wrap(:conflict) { |args| _render_diff } } }
    end
  end

  define_view(:remove) do |args|
    wrap(:remove, args) do
    %{#{ header}
    #{card_form :remove, '', 'data-type'=>'html', 'main-success'=>'REDIRECT: TO-PREVIOUS' do |f|
    
      %{#{ hidden_field_tag 'confirm_destroy', 'true' }#{
        hidden_field_tag 'success', "TEXT: #{card.name} removed" }
    
    <div class="content open-content">
      <p>Really remove #{ link_to_page formal_title(card), card.name }?</p>#{
       if dependents = card.dependents and !dependents.empty? #ENGLISH ^
        %{<p>That would mean removing all these cards, too:</p>
        <ul>
          #{ dependents.map do |dep|
            %{<li>#{ link_to_page dep.name }</li>}
          end.join }
        </ul>}
       end}
       #{ error_messages_for card }
       #{ submit_tag 'Yes do it', :class=>'remove-submit-button' }
       #{ button_tag 'Cancel', :class=>'remove-cancel-button slotter', :type=>'button', :href=>path(:view) } 
       #{ notice }
    </div>
      }
    end}}
    end
  end

  define_view(:change) do |args|
    wrap(:change, args) do
      %{#{link_to_page card.name, nil, :class=>'change-card'} #{
       if rev = card.cached_revision and !rev.new_record?
         # this check should be unnecessary once we fix search result bug
         %{<span class="last-update"> #{

           case card.updated_at.to_s
             when card.created_at.to_s; 'added'
             when rev.created_at.to_s;  link_to('edited', path(:changes), :class=>'last-edited')
             else; 'updated'
           end} #{

            time_ago_in_words card.updated_at } ago by #{ #ENGLISH
            link_to_page card.updater.card.name, nil, :class=>'last-editor'}
          </span>}
       end }
       <br style="clear:both"/>}
    end
  end


  define_view(:header) do |args|
    %{<div class="card-header">
       #{ menu }

         <div class="title-menu">
           #{ link_to fancy_title(card), path(:view, :view=>:closed), :title => "close #{card.name}", 
             :class => "line-link title down-arrow slotter", :remote => true }

           #{ unless card.typecode=='Basic'
             %{<span class="cardtype">#{ link_to_page( Cardtype.name_for(card.typecode) ) }</span>}
            end }

           #{ page_icon(card.name) } &nbsp;
         </div>

         <style type="text/css">.SELF-#{card.cardname.css_name} .content .namepart-#{card.cardname.css_name} { display: none; }</style>
    </div>}
  end

  define_view(:footer) do |args|
    %{<div class="card-footer">
      <span class="footer-content">
        <span class="watch-link">#{ _render_watch }</span>
        <span class="footer-links">
          <label>Cards:</label>
          #{raw card.cardname.piece_names.map {|c| link_to_page c}.join(', ') }
        </span>
        #{ 
         if !card.cached_revision.new_record?
           %{
          <span class="last-editor">
            <label>Last Editor:</label>
            #{ raw link_to_page card.cached_revision.author.card.name }
          </span>}
         end 
        }
      </span>&nbsp;
    </div>}
  end


  define_view(:errors) do |args|
    wrap(:errors, args) do
      %{ <h2>Can't save "#{card.name}".</h2> } +
      card.errors.map { |attr, msg| "<div>#{attr}: #{msg}</div>" }.join('')
    end
  end
  
  
  define_view(:not_found) do |args| #ug.  bad name.

    sign_in_or_up_links = User.logged_in? ? '' :
      %{
      <div>
        #{link_to "Sign In", :controller=>'account', :action=>'signin'} or 
        #{link_to 'Sign Up', :controller=>'account', :action=>'signup'} to create it.
      </div>
      }
    %{ <h1 class="page-header">Missing Card</h1> } +
    wrap(:not_found, args) do # ENGLISH 
      %{<div class="content instruction">
          <div>There's no card named <strong>#{card.name}</strong>.</div> 
          #{sign_in_or_up_links}
        </div>}
    end
  end
  

  define_view(:watch) do |args|
    return "" unless User.logged_in?   
    return "" if card.virtual?
    wrap(:watch) do
      @me = User.current_user.card.name          
      if card.typecode == "Cardtype"
        (card.type_watchers.include?(@me) ? "#{watching_type_cards} | " : "") +  watch_unwatch
      else
        card.type_watchers.include?(@me)  ? watching_type_cards : watch_unwatch
      end      
    end
  end
  
  
  define_view(:denial) do |args|
    wrap(:denial, args) do #ENGLISH below
      %{#{ header } 
        <div id="denied" class="instruction open-content">
          <h1>Ooo.  Sorry, but...</h1>
  
        
       #{ if params[:action] != 'view' && Wagn::Conf[:read_only]
            "<div>We are currently in read-only mode.  Please try again later.</div>"
          else
            %{<div>#{
            
            if User.current_user.anonymous?
             %{You have to #{ link_to "sign in", :controller=>'account', :action=>'signin' }}
            else
             "You need permission"
            end} to #{params[:action]} this card#{": <strong>#{fancy_title(card)}</strong>" if card.name && !card.name.blank? }.
            </div>
  
            #{unless @skip_slot_header or @deny=='view'
              %{<p>#{ link_to 'See permission settings', path(:options, :attrib=>'settings'), :class=>'slotter', :remote=>true  }.</p>}
            end} #{
  
            if User.current_user.anonymous? && Card.new(:typecode=>'InvitationRequest').ok?(:create)
              %{<p>#{ link_to 'Sign up for a new account', :controller=>'account', :action=>'signup' }.</p>}
            end }}
          end   }
        </div>
        #{ _render_footer  }}
    end
  end
  
  
  define_view(:server_error) do |args|
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
  
  def card_form *opts
    form_for( card, form_opts(*opts) ) { |form| yield form }
  end

  def form_opts url, classes='', other_html={}
    url = path(url) if Symbol===url
    opts = { :url=>url, :remote=>true, :html=>other_html }
    opts[:html][:class] = classes + ' slotter'
    opts[:html][:recaptcha] = 'on' if Wagn::Conf[:recaptcha_on] && Card.toggle( card.rule('captcha') )
    opts
  end
  
  private

  def watching_type_cards
    "watching #{link_to_page(Cardtype.name_for(card.typecode))} cards"      # can I parse this and get the link to happen? that wud r@wk.
  end

  def watch_unwatch      
    type_link = (card.typecode == "Cardtype") ? " #{card.name} cards" : ""
    type_msg = (card.typecode == "Cardtype") ? " cards" : ""    

    if card.card_watchers.include?(@me) or card.typecode != 'Cardtype' && card.watchers.include?(@me)
      text, toggle, title = "unwatch", :off, "stop getting emails about changes to"
    else
      text, toggle, title = "watch", :on, "get emails about changes to"
    end
    
    link_to "#{text}#{type_link}", path(:watch, :toggle=>toggle), :class=>'watch-toggle slotter',
      :title=>"#{title} #{card.name}#{type_msg}", :remote=>true, :method=>'post'
    
  end

  def load_revisions
    @revision_number = (params[:rev] || (card.revisions.count - card.drafts.length)).to_i
    @revision = card.revisions[@revision_number - 1]
    @show_diff = (params[:mode] != 'false')
    @previous_revision = card.previous_revision(@revision)
  end

  def new_instruction
    i=%{#{if card.broken_type
            %{<div class="error" id="no-cardtype-error">
              Oops! There's no <strong>card type</strong> called "<strong>#{ card.broken_type }</strong>".
            </div>}
          end }
       #{
       if @help_card
         ''  # they'll go inside the card
       elsif !card.cardname.blank? #ENGLISH
         %{<div>Currently, there is no card named "<strong>#{ card.name
                 }</strong>", but you're welcomed to create it.</div>}
       else
         %{<div>Creating a new card is easy; you just need a unique name.</div>}
       end}}
    i.blank? ? '' : %{<div class="instruction new-instruction"> #{ i } </div>}
  end

  def new_content(args)
    hide_type = params[:type] && !card.broken_type 

    wrap(:new, args) do  
      %{#{error_messages_for card}#{
    
      card_form :create, 'card-form card-new-form', 'main-success'=>'REDIRECT' do |form|
        @form = form
    
        %{ #{ hidden_field_tag :success, card.rule('thanks') || 'TO-CARD' }
    
        <div class="card-header">
          #{ 
          if hide_type
            form.hidden_field :typecode 
          else
            %{<span class="new-type">
              <label>type:</label>
              #{ typecode_field :class=>'type-field new-type-field live-type-field', :href=>path(:new), 'data-remote'=>true}
            </span>}
          end}
         
          <span class="new-name">
            
            #{ 
            if card.cardname.blank? || Card.exists?(card.cardname)
              card.rule_card('autoname') ? '&nbsp;' : %{<label>name:</label> <span class="name-area">#{ raw name_field(form) }</span>}
            else
              %{#{hidden_field_tag 'card[name]', card.name} <label>name:</label> <span class="title">#{ raw fancy_title(card.name) }</span>}
            end
            }
          </span>
        </div>
    
       #{@help_card ? %{<div class="instruction">#{ raw subrenderer(@help_card).render_core }</div>} : '' }
    
       <div class="edit-area">
         <div class="card-editor editor">
           #{ edit_slot(args) }
         </div>
    
         <div class="edit-button-area">
           #{ submit_tag 'Submit', :class=>'create-submit-button' }
           #{ button_tag 'Cancel', :type=>'button', :class=>"create-cancel-button #{args[:cancel_class]}", :href=>args[:cancel_href] }
         </div>
       </div>}
     end }#{
    
     notice}}
   end
  end


  
end

