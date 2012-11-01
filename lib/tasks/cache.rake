namespace :cache do
  desc "reset cache"
  task :clear => :environment  do
    Wagn::Cache.reset_global
  end
end
