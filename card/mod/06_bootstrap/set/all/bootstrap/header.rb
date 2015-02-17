format :html do 
  view :header do |args|
    %{
      <h3 class="card-header panel-title">
        #{ _optional_render :toggle, args, :hide }
        #{ _optional_render :title, args }
        #{ _optional_render :menu, args }
      </h3>
    }
  end
  
  view :menu_link do |args|
    '<span class="glyphicon glyphicon-cog" aria-hidden="true"></span>'
  end
  
  
  view :toggle do |args|
    verb, adjective, direction = ( args[:toggle_mode] == :close ? %w{ open open expand } : %w{ close closed collapse-down } )
    
    link_to '', path( :view=>adjective ), 
      :remote => true,
      :title => "#{verb} #{card.name}",
      :class => "#{verb}-icon  glyphicon glyphicon-#{direction} toggler slotter nodblclick"
  end
end