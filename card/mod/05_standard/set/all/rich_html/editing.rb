format :html do
  ###---( TOP_LEVEL (used by menu) NEW / EDIT VIEWS )

  view :new, :perms=>:create, :tags=>:unknown_ok do |args|
    frame_and_form :create, args, 'main-success'=>'REDIRECT' do
      [
        _optional_render( :name_formgroup,     args ),
        _optional_render( :type_formgroup,     args ),
        _optional_render( :content_formgroups, args ),
        _optional_render( :button_formgroup,   args )
      ]
    end  
  end
  

  def default_new_args args    
    hidden = args[:hidden] ||= {}
    hidden[:success] ||= card.rule(:thanks) || '_self'
    hidden[:card   ] ||={}
    
    args[:optional_help] ||= :show

    # name field / title
    if !params[:name_prompt] and !card.cardname.blank?
      # name is ready and will show up in title
      hidden[:card][:name] ||= card.name
    else
      # name is not ready; need generic title
      args[:title] ||= "New #{ card.type_name unless card.type_id == Card.default_type_id }" #fixme - overrides nest args
      unless card.rule_card :autoname
        # prompt for name
        hidden[:name_prompt] = true unless hidden.has_key? :name_prompt
        args[:optional_name_formgroup] ||= :show
      end
    end
    args[:optional_name_formgroup] ||= :hide

    
    # type field
    if ( !params[:type] and !args[:type] and 
        ( main? || card.simple? || card.is_template? ) and
        Card.new( :type_id=>card.type_id ).ok? :create #otherwise current type won't be on menu
      )
      args[:optional_type_formgroup] = :show
    else
      hidden[:card][:type_id] ||= card.type_id
      args[:optional_type_formgroup] = :hide
    end


    cancel = if main?
      { :class=>'redirecter', :href=>Card.path_setting('/*previous') }
    else
      { :class=>'slotter',    :href=>path( :view=>:missing         ) }
    end
    
    args[:buttons] ||= %{
      #{ button_tag 'Submit', :class=>'create-submit-button', :disable_with=>'Submitting', :situation=>'primary' }
      #{ button_tag 'Cancel', :type=>'button', :class=>"create-cancel-button #{cancel[:class]}", :href=>cancel[:href] }
    }
    
  end

  
  view :edit, :perms=>:update, :tags=>:unknown_ok do |args|
    frame_and_form :update, args do
      [
        _optional_render( :content_formgroups, args ),
        _optional_render( :button_formgroup,   args )
      ]
    end
  end

  def default_edit_args args
    args[:optional_help] = :show
    
    args[:buttons] = %{
      #{ button_tag 'Submit', :class=>'submit-button', :disable_with=>'Submitting', :situation=>'primary' }
      #{ button_tag 'Cancel', :class=>'cancel-button slotter', :href=>path, :type=>'button' }
    }
  end
  
  view :edit_name, :perms=>:update do |args|
    frame_and_form( { :action=>:update, :id=>card.id }, args, 'main-success'=>'REDIRECT' ) do
      [
        _render_name_formgroup( args ),
        _optional_render( :confirm_rename, args ),
        _optional_render( :button_formgroup, args )
      ]
    end
  end

  view :confirm_rename do |args|
    referers = args[:referers]
    dependents = card.dependents
    alert 'warning' do
      %{
        <h5>Are you sure you want to rename <em>#{card.name}</em>?</h5>
        #{ %{ <h6>This change will...</h6> } if referers.any? || dependents.any? }
        <ul>
          #{ %{<li>automatically alter #{ dependents.size } related name(s). } if dependents.any? }
          #{ %{<li>affect at least #{referers.size} reference(s) to "#{card.name}".} if referers.any? }
        </ul>
        #{ %{<p>You may choose to <em>update or ignore</em> the references.</p>} if referers.any? }
      }
    end
  end


  def default_edit_name_args args
    referers = args[:referers] = card.extended_referencers  
    args[:hidden] ||= {}
    args[:hidden].reverse_merge!(
      :success  => '_self',
      :old_name => card.name,
      :referers => referers.size,
      :card     => { :update_referencers => false }
    )
    args[:buttons] = %{
      #{ button_tag 'Rename and Update', :disable_with=>'Renaming', :class=>'renamer-updater', :situation=>'primary' }
      #{ button_tag 'Rename',            :disable_with=>'Renaming', :class=>'renamer'         }
      #{ button_tag 'Cancel', :class=>'slotter', :type=>'button', :href=>path(:view=>:edit, :id=>card.id)}
    }
    
  end


  view :edit_type, :perms=>:update do |args|
    frame_and_form :update, args do
    #'main-success'=>'REDIRECT: _self', # adding this back in would make main cards redirect on cardtype changes
      [
        _render_type_formgroup( args ),
        optional_render( :button_formgroup, args )
      ]
    end
  end

  def default_edit_type_args args
    args[:variety] = :edit #YUCK!
    args[:hidden] ||= { :view=>:edit }
    args[:buttons] = %{
      #{ button_tag 'Submit', :disable_with=>'Submitting', :situation=>'primary' }
      #{ button_tag 'Cancel', :href=>path(:view=>:edit), :type=>'button', :class=>'slotter' }      
    }    
  end
end