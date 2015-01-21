
format :html do

  view :raw do |args|    
    %{
      <ul class="nav navbar-nav navbar-right">
        <li>
          #{ account_links.join '</li><li> ' }
        </li>
      </ul>
    }
  end

end
