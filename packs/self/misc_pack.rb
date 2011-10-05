class Wagn::Renderer
  define_view(:raw, :name=>'*now') do |args|
    Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z')
  end
  alias_view(:raw, {:name=>'*now'}, :naked)


  define_view(:raw, :name=>'*version') do |args|
    Wagn::Version.full
  end
  alias_view(:raw, {:name=>'*version'}, :naked)

  
  define_view(:raw, :name=>'*alerts') do |args|
    div(:id=>"alerts") do
      div(:id=>"notice") { flash[:notice] } +
      div(:id=>"error")  { "#{flash[:warning]}#{flash[:error]}" }
    end
  end
  alias_view(:raw, {:name=>'*alerts'}, :naked)
end
