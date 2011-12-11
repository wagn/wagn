class Wagn::Renderer::Html
  define_view(:show) do |args|
    @main_view = args[:view] || params[:view] || params[:home_view] || :open
    
    if ajax_call?
      self.render(@main_view)
    else
      self.render_layout
    end
  end
  
  define_view(:main_show) do |args|
    wrap(:main, args) do
      %{#{ header } #{ notice } #{
      wrap_content( :open, raw( self.main_content ) ) }}
    end
  end

  define_view(:layout) do |args|
    if @main_content = args.delete(:main_content)
      @card = Card.fetch_or_new('*placeholder')
    else
      @main_card = card
    end

    layout_content = get_layout_content(args)
    
    args[:action]="view"  
    args[:relative_content] = args[:params] = params 
    #warn "render_layout #{card}, #{penv}, #{layout_content}, #{args.inspect}"
    
    process_content(layout_content, args)
  end
  
  define_view(:card_error) do |args|
    Rails.logger.debug "card_errors #{card}, #{card.errors.map(&:to_s).inspect}"
    wrap(:card_error, args) do
      %{<div class="error-explanation">
         <h2>Rats. Issue with #{card.name && card.name.upcase} card:</h2> #{
         card.errors.map do |attr, msg|
           "<div>#{attr.to_s.gsub(/base/, 'captcha').upcase }: #{msg}</div>"
         end * ''}
      </div> }
    end
  end


  define_view(:error) do |args|
    wrap(:error, args) do
      %{Caught error ...\n#{except.inspect}<br>\n<ul><li>#{except.backtrace * "</li>\n<li>"}</li></ul></div>}
    end
  end

  define_view(:denied) do |args|
    params['type']   ||= 'Basic'   # only really need for create
    params['deny']   ||= (card && !card.new_card? ? 'edit' : 'create')
    skip_slot_header ||= false


    wrap(:denied, args) do #ENGLISH below
      %{#{raw(header) unless @skip_slot_header }
        <div id="denied" class="instruction open-content">
          <h1>Ooo.  Sorry, but...</h1>

          <p>
       #{ if User.current_user.anonymous?
           %{You have to #{ link_to "sign in", :controller=>'account', :action=>'signin' }}
          else
           "You need permission"
          end} to #{
          title = card.name ? "<strong>#{fancy_title(card)}</strong>" :'this card'
          raw action == :create ? "create this #{typename} card: #{title}" :
              "#{action} #{title}" }
          </p>

          #{unless @skip_slot_header or @deny=='view'
            %{<p>(See the #{ raw( link_to_action('options', :options, :controller=>'card') ) } tab to learn more.)</p>}
          end} #{

          if User.current_user.anonymous? && Card.new(:typecode=>'InvitationRequest').ok?(:create)
            %{<p>#{ link_to 'Sign up for a new account', :controller=>'account', :action=>'signup' }.</p>}
          end }
        </div> #{
        raw( footer ) unless @skip_slot_header }}
    end
  end

  define_view(:content) do |args|
    c = _render_core(args)
    c = "<span class=\"faint\">--</span>" if c.size < 10 && strip_tags(c).blank?
    wrap(:content, args) { wrap_content(:content, c) }
  end

  define_view(:titled) do |args|
    wrap(:titled, args) do
      content_tag( :h1, raw(fancy_title(card.name))) + 
      raw( wrap_content(:titled, _render_core(args)))
    end
  end

  define_view(:new) do |args|
    if ajax_call?
      new_content :cancel_href=>path(:view, :view=>:missing), :cancel_class=>'standard-slotter'
    else
     @title = "New Card"  #this doesn't work.
     %{
        <h1 class="page-header">
          New #{ card.typecode == 'Basic' && '' || card.typename } Card
        </h1>
        #{ new_instruction }
        #{ new_content :cancel_href=>previous_location, :cancel_class=>'redirecter' }
      }
    end
  end

  def new_instruction
    i=%{#{if card.broken_type
            %{<div class="error" id="no-cardtype-error">
              Oops! There's no <strong>card type</strong> called "<strong>#{ card.broken_type }</strong>".
            </div>}
          end }
       #{
       if card.setting_card('add help', 'edit help')
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
    hide_type ||= params[:type] && !card.broken_type 

    wrap(:new, args) do  
     %{#{error_messages_for card}#{

     form_for card, :url=>path(:create), :remote=>true, 
      :html=>{ :class=>'card-form card-new-form standard-slotter', 'main-success'=>'REDIRECT' } do |form|
      @form = form

      %{
      #{ hidden_field_tag :success, card.setting('thanks') || 'TO-CARD' }

      <div class="card-header">
        #{ 
        if hide_type
          form.hidden_field :typecode 
        else
          %{<span class="new-type">
            <label>type:</label>
            #{ typecode_field :class=>'cardtype-field new-cardtype-field live-cardtype-field', :href=>path(:new)}
          </span>}
        end}
        
        <span class="new-name">
          <label>name:</label>
          #{ 
          if card.cardname.blank? || Card.exists?(card.cardname)
            unless card.setting_card('autoname')
              %{<span class="name-area">#{ raw name_field(form) }</span>}
            end
          else
            %{#{hidden_field_tag 'card[name]', card.name}
            <span class="title">#{ raw fancy_title(card.name) }</span>}
          end
          }
        </span>
      </div>

      #{if instruction=card.setting_card('add help', 'edit help')
        %{<div class="instruction">#{ raw subrenderer(instruction).render_core }</div>}
      end}

      <div class="edit-area">
        <div class="card-editor editor">
          #{ edit_slot(args) }
        </div>

        <div class="edit-button-area">
          #{ submit_tag 'Submit', :class=>'create-submit-button' }
          #{ button_tag 'Cancel', :type=>'button',
            :class=>"create-cancel-button #{args[:cancel_class]}", :href=>args[:cancel_href] }
        </div>
      </div>}
    end }#{

   notice}}
   end
  end

  define_view(:editor) do |args|
    uid = "#{card.key}-#{Time.now.to_i}-#{rand(3)}"
    form.text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>uid
  end

  define_view(:missing) do |args|
    #warn "missing #{args.inspect} #{caller[0..10]*"\n"}"
    new_args = { 'card[name]'=>card.name }
    new_args['card[type]'] = args[:type] if args[:type]

    wrap(:missing, args) do
      link_to raw("Add <strong>#{ @showname || card.name }</strong>"), path(:new, new_args),
        :class=>'standard-slotter init-editors', :remote=>true
    end
  end
  
###---(  EDIT VIEWS )
  define_view(:edit) do |args|
    @attribute = params[:attribute] || 'content'
    wrap(:edit, args) do
      %{#{header
       }<style>.SELF-#{card.css_name} .edit-area .namepart-#{card.css_name} { display: none; } </style>
       <div class="card-body">
         #{render "edit_#{@attribute}" }
         #{notice }
       </div>}
    end
  end

  define_view (:edit_content) do |args|
    %{#{raw edit_submenu(params[:inclusions] ? :inclusions : :content)}#{
      if inst = card.setting_card('edit help')
        %{<div class="instruction">#{ raw subrenderer(inst).render_core }</div>}
      end}#{
      if card.hard_template and card.hard_template.ok? :read
       %{<div class="instruction">
   Formatted by a #{ link_to_page 'form card', card.hard_template.name #ENGLISH
       }
  </div>}
      end}

      <div class="card-editor edit-area #{card.hard_template ? :templated : ''}">
      #{ form_for card, :url=>path(:update),
      :html=>{ :class=>'card-form card-edit-form standard-slotter autosave', :remote=>true } do |f|
        %{<div>#{ @form= f; edit_slot(args) }</div>

        <div class="edit-button-area"> #{
          if !card.new_card?
            button_tag "Delete", :href=>path(:remove), :type=>'button', 'data-type'=>'html',
              :class=>'edit-delete-button delete-button standard-slotter standard-delete'
              
          end}#{
          submit_tag 'Submit', :class=>'edit-submit-button'}#{
          button_tag 'Cancel', :class=>'edit-cancel-button standard-slotter', :href=>path(:view), :type=>'button'}
        </div>}
       end}
    </div>
      }
  end

  define_view(:edit_name) do |args|
    %{#{ edit_submenu :name }
      <div class="edit-area edit-name">
       <h2>Change Name</h2>
      #{ form_for card, :url=>path(:update), :remote=>true,
        :html=>{ :class=>'card-edit-name-form standard-slotter', 'main-success'=>'REDIRECT' } do |f|
          
          
          
        %{<div>to #{ raw f.text_field( :name, :class=>'card-name-field', :value=>card.name, :autocomplete=>'off' ) } </div>
        #{ hidden_field_tag :success, 'TO-CARD' }
        #{

     if card.confirm_rename
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
    #{ button_tag 'Cancel', :class=>'edit-name-cancel-button standard-slotter init-editors', :type=>'button', :href=>path(:edit)}
    }
    end}
    </div>}
  end

  define_view (:edit_type) do |args|
    %{#{ raw edit_submenu(:type)}
    <div class="edit-area edit-type">
    <h2>Change Type</h2> #{
      form_for :card, :url=>path(:update), :remote=>true, 
        #'main-success'=>'REDIRECT: TO-CARD', # adding this back in would make main cards redirect on cardtype changes
        :html=>{ :class=>'standard-slotter card-edit-type-form' } do |f|
          
        %{#{if card.typecode == 'Cardtype' and card.extension and !Card.search(:type=>card.cardname).empty? #ENGLISH
          %{<div>Sorry, you can't make this card anything other than a Cardtype so long as there are <strong>#{ card.name }</strong> cards.</div>}
        else
          %{<div>to #{ raw typecode_field :class=>'cardtype-field edit-cardtype-field' }</div>}
        end}
        <div>
          #{ button_tag 'Cancel', :href=>path(:edit), :type=>'button', :class=>'edit-type-cancel-button standard-slotter init-editors' }
        </div>}
     end}
    </div>}
  end

  define_view(:edit_in_form) do |args|
    instruction = ''
    if instruction_card = (card.new_card? ? card.setting_card('add help', 'edit help') : card.setting_card('edit help'))
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
  
  <div class="field-in-multi">
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
              :class=>"standard-slotter #{key==current ? 'current-subtab' : ''}"
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
    #warn "attribute = "
    wrap(:options, args) do
      %{ 
      #{ header }
      <div class="options-body"> #{ render "option_#{attribute}" } </div>
      <span class="notice">#{ flash[:notice] } </span>
      }
    end
  end

  define_view(:option_account) do |args|
    locals = {:slot=>self, :card=>card, :extension=>card.extension }
    %{#{raw( options_submenu(:account) ) }#{

        form_for :card, :url=>path(:update_account), :remote=>true,
          :html=>{ :class=>'standard-slotter' } do |form|

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
    current_set = params[:current_set] || related_sets[0]

    options_submenu(:settings) +
      %{<div class="settings-tab">
        #{if !related_sets.empty?
          %{<div class="set-selection">
          #{
          form_tag path(:options, :attrib=>:settings), :method=>'get', :remote=>true, :class=>'standard-slotter' }
            <label>Set:</label>
            <select name="current_set" class="set-select">
            #{ 
            related_sets.map do |set_name| 
               set_card = Card.fetch set_name
              %{<option value="#{ set_card.key }" #{set_card.key==current_set ? 'selected="selected"' : ''}>
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
        if !card.extension_type && Card.toggle(card.setting('accountable')) && User.ok?(:create_accounts) && card.ok?(:update)
          %{<div class="new-account-link">
          #{ link_to %{Add a sign-in account for "#{card.name}"},
              path(:options, :attrib=>:new_account),
            :class=>'standard-slotter new-account-link', :remote=>true }
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
      form_for :card, :url=>path(:create_account),
         :html=>{:class=>'standard-slotter'}, :remote=>true do |form|
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

  define_view(:changes) do |args| #ENGLISH
    @revision_number = (params[:rev] || (card.revisions.count - card.drafts.length)).to_i
    @revision = card.revisions[@revision_number - 1]
    @show_diff = (params[:mode] != 'false')
    @previous_revision = card.previous_revision(@revision)
    
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
    if @show_diff and @previous_revision  #ENGLISH
      %{<p class="revision-diff-header">
        <small>
          Showing changes from revision ##{ @revision_number - 1 }:
          <ins class="diffins">Added</ins> | <del class="diffmod">Removed</del>
        </small>
      </p>}
    end}

    </div>


    <div class="revision">#{
    if @show_diff and @previous_revision
      diff @previous_revision.content, @revision.content
    else
      @revision.content
    end}
    </div>

    <div class="revision-navigation card-footer">
    #{ revision_menu }
    </div>}
    end
  end

  define_view(:remove) do |args|
    wrap(:remove, args) do
    %{#{ header}#{
      form_for :card, :url=>path(:remove), :html => { :remote=>true,
        :class=>'standard-slotter', 'data-type'=>'html', 'main-success'=>'REDIRECT: TO-PREVIOUS' } do |f|
    
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
       #{ button_tag 'Cancel', :class=>'remove-cancel-button standard-slotter', :type=>'button', :href=>path(:view) } 
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

  define_view(:open) do |args|
    wrap(:open, args) do
      %{#{
      header } #{
      notice } #{
      wrap_content( :open, raw(_render_open_content) ) } #{

      if card && card.ok?(:comment)
        %{<div class="comment-box"> #{
          form_for :card, :url=>path(:comment), :remote=>:true,
                :html=> { :class=>'standard-slotter' } do |f|
            %{#{f.text_area :comment, :rows=>3 }<br/> #{
            if User.current_user.login == "anon"
              card.comment_author= (session[:comment_author] || params[:comment_author] || "Anonymous") #ENGLISH
              %{<label>My Name is:</label> #{
                  f.text_field :comment_author }}
            end}
            <input type="submit" value="Comment"/>}
          end}
       </div>}
     end} #{

     footer }}
    end
  end

  define_view(:closed) do |args|
    #warn "view closed #{card}, #{card}"
    wrap(:closed, args) do
      %{<div class="card-header">
        <div class="title-menu"> #{
          raw link_to( raw(fancy_title(card)),
            path(:view, :view=>:open),
            :title=>"open #{card.name}",
            :class=>'title right-arrow standard-slotter',
            :remote=>true ) } #{
          raw page_icon(card.name) }&nbsp;
        </div>
      </div> #{
      wrap_content :closed, render_closed_content }}
    end
  end

  define_view(:header) do |args|
    %{<div class="card-header">
       #{ raw menu }

         <div class="title-menu">
           #{ link_to raw(fancy_title(card)), path(:view, :view=>:closed),
             :class => "line-link title down-arrow standard-slotter",
             :title => "close #{card.name}", :remote => true }

           #{ unless card.typecode=='Basic'
             %{<span class="cardtype">
               #{ raw link_to_page( Cardtype.name_for(card.typecode) ) }
             </span>}
            end }

           #{ raw page_icon(card.name) } &nbsp;
         </div>

         <style type="text/css">.SELF-#{card.cardname.css_name
            } .content .namepart-#{card.cardname.css_name
            } { display: none; }</style>
    </div>}
  end

  define_view(:footer) do |args|
    %{<div class="card-footer">
      <span class="footer-content">
        <span class="watch-link">#{ raw slot.watch_link }</span>
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

end

