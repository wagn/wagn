format :html do 
  view :header do |args|
    %{
      <div class="card-header#{ ' panel-heading' if args[:panel] }">
        <h3 class="card-header-title #{ ' panel-title' if args[:panel] }">
          #{ _optional_render :toggle, args, :hide }
          #{ _optional_render :title, args }
        </h3>
        #{ _optional_render :menu, args }
      </div>
    }
  end
  
  view :menu_link do |args|
    glyphicon 'cog'
    #'<span class="glyphicon glyphicon-cog" aria-hidden="true"></span>'
  end
  
  
  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open expand } : %w{ close closed collapse-down } )
    
    link_to  glyphicon(direction), #content_tag(:span, '', :class=>"glyphicon glyphicon-#{direction}"),
             path( :view=>adjective ),
             :remote => true,
             :title => "#{verb} #{card.name}",
             :class => "#{verb}-icon toggler slotter nodblclick"
   end
end