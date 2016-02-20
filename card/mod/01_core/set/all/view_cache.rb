event :clear_view_cache, :finalize do
  Card::ViewCache.reset
end

format do
  def view_caching?
    false
  end
end
