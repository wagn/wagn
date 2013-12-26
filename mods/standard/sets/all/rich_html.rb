# -*- encoding : utf-8 -*-
def clean_html?
  true
end

format :html do

  view :show do |args|
    @main_view = args[:view] || args[:home_view]

    if ajax_call?
      view = @main_view || :open
      self.render view, args
    else
      self.render_layout args
    end
  end

  view :layout, :perms=>:none do |args|
    layout_content = get_layout_content args
    process_content layout_content
  end

  view :content do |args|
    wrap :content, args.merge(:slot_class=>'card-content') do
      menu = optional_render :menu, args, default_hidden=true
      %{#{ menu }#{ _render_core args }}
    end
  end

  view :titled, :tags=>:comment do |args|
    wrap :titled, args do
      %{
        #{ _render_header args.merge( :menu_default_hidden=>true ) }
        #{ wrap_body( :content=>true ) { _render_core args } }
        #{ optional_render :comment_box, args }
      }
    end
  end

  view :type_select do |args|
    %{ <script type="text/template" class="live-type-selection">
      <span class="live-type-selection">#{ type_field :class=>'type-field live-type-field' }</span>
    </script>}
  end

  view :labeled do |args|
    wrap :labeled, args do
      %{
        #{ _optional_render :menu, args }
        <label>#{ _render_title args }</label>
        #{
          wrap_body :body_class=>'closed-content', :content=>true do
            _render_closed_content args
          end
        }
      }
    end
  end

  view :title do |args|
    title = fancy_title args[:title]
    title = _optional_render( :title_link, args.merge( :title_ready=>title ), default_hidden=true ) || title
    add_name_context
    title
  end
  
  view :title_link do |args|
    link_to_page (args[:title_ready] || showname(args[:title]) ), card.name
  end

  view :open, :tags=>:comment do |args|
    args[:toggler] = link_to '', path( :view=>:closed ),
      :remote => true,
      :title  => "close #{card.name}",
      :class  => "close-icon ui-icon ui-icon-circle-triangle-s toggler slotter nodblclick"
      
    wrap_frame :open, args.merge(:content=>true) do
      %{#{ _render_open_content args }#{ optional_render :comment_box, args }}
    end
  end

  view :header do |args|
    %{
      <h1 class="card-header">
        #{ args.delete :toggler }
        #{ _render_title args }
        #{ _render_type args.merge( :type_class=>"type-hidden" )  }
        #{
          args[:custom_menu] or unless args[:hide_menu]                          # developer config
            _optional_render :menu, args, (args[:menu_default_hidden] || false)  # wagneer config
          end
        }
      </h1>
    }
  end

  view :menu, :tags=>:unknown_ok do |args|
    disc_tagname = Card.fetch(:discussion, :skip_modules=>true).cardname
    disc_card = unless card.new_card? or card.junction? && card.cardname.tag_name.key == disc_tagname.key
      Card.fetch "#{card.name}+#{disc_tagname}", :skip_virtual=>true, :skip_modules=>true, :new=>{}
    end
    
    @menu_vars = {
      :self         => card.name,
      :type         => card.type_name,
      :structure    => card.structure && card.template.ok?(:update) && card.template.name,
      :discuss      => disc_card && disc_card.ok?( disc_card.new_card? ? :comment : :read ),
      :piecenames   => card.junction? && card.cardname.piece_names[0..-2].map { |n| { :item=>n.to_s } },
      :related_sets => card.related_sets.map { |name,label| { :text=>label, :path_opts=>{ :current_set => name } } }
    }
    if card.real?
      @menu_vars.merge!({
        :edit      => card.ok?(:update),
        :account   => card.account && card.update_account_ok?,
        :watch     => Account.logged_in? && render_watch(args.merge :no_wrap_comment=>true),
        :creator   => card.creator.name,
        :updater   => card.updater.name,
        :delete    => card.ok?(:delete) && link_to( 'delete', path(:action=>:delete),
          :class => 'slotter standard-delete', :remote => true, :'data-confirm' => "Are you sure you want to delete #{card.name}?"
        )
      })
    end
    
    json = html_escape_except_quotes JSON( @menu_vars )
    %{<span class="card-menu-link" data-menu-vars='#{json}'>#{_render_menu_link}</span>}
  end


  view :menu_link do |args|
    '<a class="ui-icon ui-icon-gear"></a>'
  end

  view :type do |args|
    klasses = ['cardtype']
    klass = args[:type_class] and klasses << klass
    case card.type_id
      when Card.default_type_id; klasses << 'default-type'
      when Card::CardtypeID
        klasses << 'no-edit' if Card.search(:type_id=>card.id).present?
    end
    link_to_page card.type_name, nil, :class=>klasses
  end

  view :closed do |args|
    args[:toggler] = link_to '', path( :view=>:open ),
      :remote => true,
      :title => "open #{card.name}",
      :class => "open-icon ui-icon ui-icon-circle-triangle-e toggler slotter nodblclick"
      
    wrap_frame :closed, args.merge(:content=>true, :body_class=>'closed-content') do
#    wrap :closed, args do
      _render_closed_content args
    end
  end


  view :new, :perms=>:create, :tags=>:unknown_ok do |args|
    name_ready = !card.cardname.blank? && !Card.exists?( card.cardname )
    prompt_for_name = !name_ready && !card.rule_card( :autoname )

    hidden = { :success=> card.rule(:thanks) || '_self' }
    if name_ready
      hidden['card[name]'] = card.name
    else
      args[:title] ||= "New #{ card.type_name unless card.type_id == Card.default_type_id }"
    end

    prompt_for_type = (
      !params[:type] and !args[:type] and
      ( main? || card.simple? || card.is_template? ) and
      Card.new( :type_id=>card.type_id ).ok? :create #otherwise current type won't be on menu
    ) 

    cancel = if main?
      { :class=>'redirecter', :href=>Card.path_setting('/*previous') }
    else        
      { :class=>'slotter',    :href=>path( :view=>:missing         ) }
    end
    
    wrap_frame :new, args.merge(:show_help=>true) do
      card_form :create, 'card-form', 'main-success'=>'REDIRECT' do |form|
        @form = form
        %{
          #{ hidden_tags hidden.merge( args[:hidden] || {} ) }
          #{ _render_name_editor if prompt_for_name }
          #{ prompt_for_type ? _render_type_menu : form.hidden_field( :type_id ) }                
          <div class="card-editor editor">
            #{ edit_slot args.merge( :label => prompt_for_name || prompt_for_type ) }
          </div>
          <fieldset>
            <div class="button-area">
              #{ submit_tag 'Submit', :class=>'create-submit-button', :disable_with=>'Submitting' }
              #{ button_tag 'Cancel', :type=>'button', :class=>"create-cancel-button #{cancel[:class]}", :href=>cancel[:href] }
            </div>
          </fieldset>                
        }
      end
    end
  end


  view :editor do |args|
    form.text_area :content, :rows=>3, :class=>'tinymce-textarea card-content', :id=>unique_id
  end

  view :missing do |args|
    return '' unless card.ok? :create  #this should be moved into ok_view
    new_args = { :view=>:new, 'card[name]'=>card.name }
    new_args['card[type]'] = args[:type] if args[:type]

    wrap :missing, args do
      link_to raw("Add #{ fancy_title args[:title] }"), path(new_args),
        :class=>"slotter missing-#{ args[:denied_view] || args[:home_view]}", :remote=>true
    end
  end

  view :closed_missing, :perms=>:none do |args|
    %{<span class="faint"> #{ showname } </span>}
  end

###---(  EDIT VIEWS )
  view :edit, :perms=>:update, :tags=>:unknown_ok do |args|
    wrap_frame :edit, args.merge(:show_help=>true) do
      card_form :update, 'card-form autosave' do |f|
        @form= f
        %{
          #{ hidden_tags(( args[:hidden] || {} )) }
          <div class="card-editor">
            #{ edit_slot args }
          </div>
          <fieldset>
            <div class="button-area">
              #{ submit_tag 'Submit', :class=>'submit-button' }
              #{ button_tag 'Cancel', :class=>'cancel-button slotter', :href=>path, :type=>'button' }
            </div>
          </fieldset>
        }
      end
    end
  end

  view :name_editor do |args|
    fieldset 'name', raw( name_field form ), :editor=>'name', :help=>args[:help]
  end

  view :edit_name, :perms=>:update do |args|
    card.update_referencers = false
    referers = card.extended_referencers
    dependents = card.dependents
  
    wrap_frame :edit_name, args do
      card_form( path(:action=>:update, :id=>card.id), 'card-name-form card-editor', 'main-success'=>'REDIRECT' ) do |f|
        @form = f
        %{  
          #{ _render_name_editor}  
          #{ f.hidden_field :update_referencers, :class=>'update_referencers'   }
          #{ hidden_field_tag :success, '_self'  }
          #{ hidden_field_tag :old_name, card.name }
          #{ hidden_field_tag :referers, referers.size }
          <div class="confirm-rename hidden">
            <h1>Are you sure you want to rename <em>#{card.name}</em>?</h1>
            #{ %{ <h2>This change will...</h2> } if referers.any? || dependents.any? }
            <ul>
              #{ %{<li>automatically alter #{ dependents.size } related name(s). } if dependents.any? }
              #{ %{<li>affect at least #{referers.size} reference(s) to "#{card.name}".} if referers.any? }
            </ul>
            #{ %{<p>You may choose to <em>ignore or update</em> the references.</p>} if referers.any? }  
          </div>
          <fieldset>
            <div class="button-area">
              #{ submit_tag 'Rename and Update', :class=>'renamer-updater hidden' }
              #{ submit_tag 'Rename', :class=>'renamer' }
              #{ button_tag 'Cancel', :class=>'edit-name-cancel-button slotter', :type=>'button', :href=>path(:view=>:edit, :id=>card.id)}
            </div>
          </fieldset>
        }
      end
    end
  end

  view :type_menu do |args|
    field = if args[:variety] == :edit
      type_field :class=>'type-field edit-type-field'
    else
      type_field :class=>"type-field live-type-field", :href=>path(:view=>:new), 'data-remote'=>true
    end
    fieldset 'type', field, :editor => 'type', :attribs => { :class=>'type-fieldset'}
  end

  view :edit_type, :perms=>:update do |args|
    wrap_frame :edit_type, args do
      card_form( :update, 'card-edit-type-form card-editor' ) do |f|
        #'main-success'=>'REDIRECT: _self', # adding this back in would make main cards redirect on cardtype changes
        %{ 
          #{ hidden_field_tag :view, :edit }
          #{if card.type_id == Card::CardtypeID and !Card.search(:type_id=>card.id).empty? #ENGLISH
            %{<div>Sorry, you can't make this card anything other than a Cardtype so long as there are <strong>#{ card.name }</strong> cards.</div>}
          else
            _render_type_menu :variety=>:edit #FIXME dislike this api -ef
          end}
          <fieldset>
            <div class="button-area">              
              #{ submit_tag 'Submit', :disable_with=>'Submitting' }
              #{ button_tag 'Cancel', :href=>path(:view=>:edit), :type=>'button', :class=>'edit-type-cancel-button slotter' }
            </div>
          </fieldset>
        }
      end
    end
  end

  view :edit_in_form, :perms=>:update, :tags=>:unknown_ok do |args|
    eform = form_for_multi
    content = content_field eform, args.merge( :nested=>true )
    opts = { :editor=>'content', :help=>true, :attribs => 
      { :class=> "card-editor RIGHT-#{ card.cardname.tag_name.safe_key }" }
    }
    if card.new_card?
      content += raw( "\n #{ eform.hidden_field :type_id }" )
    else
      opts[:attribs].merge! :card_id=>card.id, :card_name=>(h card.name)
    end
    fieldset fancy_title, content, opts
  end


  view :options do |args|
    current_set = Card.fetch( params[:current_set] || card.related_sets[0][0] )

    wrap_frame :options, args do
      %{
        #{ subformat( current_set ).render_content }
        #{ 
          if card.accountable? && !card.account
            %{
              <div class="new-account-link">
                #{ link_to %{Add a sign-in account for "#{card.name}"}, path(:view=>:new_account),
                   :class=>'slotter new-account-link', :remote=>true }
              </div>
            }
          end
        }
      }
    end
  end
  
  
  view :related do |args|
    if rparams = params[:related]
      rcardname = rparams[:name].to_name.to_absolute_name( card.cardname)
      rcard = Card.fetch rcardname, :new=>{}
      rview = rparams[:view] || :titled        
      show = 'menu,help'
      show += ',comment_box' if rparams[:name] == '+discussion' #fixme.  yuck!

      wrap_frame :related, args do
        process_inclusion rcard, :view=>rview, :show=>show
      end
    end
  end

  view :help, :tags=>:unknown_ok do |args|
    text = if args[:help_text]
      args[:help_text]
    else
      setting = card.new_card? ? :add_help : :help
      setting = [ :add_help, { :fallback => :help } ] if setting == :add_help
      
      if help_card = card.rule_card( *setting ) and help_card.ok? :read
        with_inclusion_mode :normal do
          _final_core args.merge( :structure=>help_card.name )
        end
      end
    end
    %{<div class="instruction">#{raw text}</div>} if text
  end

  view :conflict, :error_code=>409 do |args|
    load_revisions
    wrap :errors do |args|
      %{<strong>Conflict!</strong><span class="new-current-revision-id">#{@revision.id}</span>
        <div>#{ link_to_page @revision.creator.name } has also been making changes.</div>
        <div>Please examine below, resolve above, and re-submit.</div>
        #{wrap(:conflict) { |args| _render_diff } } }
    end
  end

  view :change do |args|
    wrap :change, args do
      %{
        #{link_to_page card.name, nil, :class=>'change-card'}
        #{ _optional_render :menu, args, default_hidden=true }
        #{
        if rev = card.current_revision and !rev.new_record?
          # this check should be unnecessary once we fix search result bug
          %{<span class="last-update"> #{

            case card.updated_at.to_s
              when card.created_at.to_s; 'added'
              when rev.created_at.to_s;  link_to('edited', path(:view=>:history), :class=>'last-edited', :rel=>'nofollow')
              else; 'updated'
            end} #{
       
             time_ago_in_words card.updated_at } ago by #{ #ENGLISH
             link_to_page card.updater.name, nil, :class=>'last-editor'}
           </span>}
        end
        }
      }
    end
  end

  view :errors, :perms=>:none do |args|
    #Rails.logger.debug "errors #{args.inspect}, #{card.inspect}, #{caller[0..3]*", "}"
    if card.errors.any?
      wrap :errors, args do
        %{ <h2>Problems #{%{ with <em>#{card.name}</em>} unless card.name.blank?}</h2> } +
        card.errors.map { |attrib, msg| "<div>#{attrib.to_s.upcase}: #{msg}</div>" } * ''
      end
    end
  end

  view :not_found do |args| #ug.  bad name.
    sign_in_or_up_links = if !Account.logged_in?
      %{<div>
        #{link_to "Sign In", :controller=>'account', :action=>'signin'} or
        #{link_to 'Sign Up', :controller=>'account', :action=>'signup'} to create it.
       </div>}
    end
  
    wrap_frame :notfound, args.merge(:title=>'Not Found', :hide_menu=>'true') do
      %{
        <h2>Could not find #{card.name.present? ? "<em>#{card.name}</em>" : 'that'}.</h2>
        #{sign_in_or_up_links}
      }
    end
  end

  view :denial do |args|
    to_task = if task = args[:denied_task]
      %{to #{task} this.}
    else
      'to do that.'
    end
    
    if !focal?
      %{<span class="denied"><!-- Sorry, you don't have permission #{to_task} --></span>}
    else
      wrap_frame :denial, args do #ENGLISH below
        message = case
        when task != :read && Wagn::Conf[:read_only]
          "We are currently in read-only mode.  Please try again later."
        when Account.logged_in?
          "You need permission #{to_task}"
        else
          or_signup = if Card.new(:type_id=>Card::AccountRequestID).ok? :create
            "or #{ link_to 'sign up', wagn_url('account/signup') }"                    
          end
          "You have to #{ link_to 'sign in', wagn_url('account/signin') } #{or_signup} #{to_task}"
        end
        
        %{<h1>Sorry!</h1>\n<div>#{ message }</div>}
      end
    end
  end


  view :server_error do |args|
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

end


