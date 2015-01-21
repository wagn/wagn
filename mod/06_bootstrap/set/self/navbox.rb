
format :html do
  
  view :raw do |args|
    input_args = { :class=>'navbox form-control' }
    @@placeholder ||= begin
      p = Card["#{Card[:navbox].name}+*placeholder"] and p.raw_content
    end
    
    input_args[:placeholder] = @@placeholder if @@placeholder

    %{
      <form action="#{Card.path_setting '/:search'}" method="get" class="nodblclick navbar-form" role="search">
        <div class="form-group">
          #{ text_field_tag :_keyword, '', input_args }
        </div>
     </form>
    }
  end
  
  view :core, :raw
  
end
