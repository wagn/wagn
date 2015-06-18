#event :clear_view_cache, :after=>:store do
#  Card::ViewCache.reset
#end

format do
  def view_caching?
    false
  end
end