event :clear_view_cache, :finalize do
  Card::Cache::ViewCache.reset
end

format do
  def view_caching?
    false
  end
end
