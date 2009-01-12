namespace :cache do
  desc "inc global seq to reset cache" 
  task :clear => :environment  do
    CachedCard.bump_global_seq
  end
end