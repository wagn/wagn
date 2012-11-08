task :restart do
  system("touch tmp/restart.txt")
  system("touch tmp/debug.txt") if ENV["DEBUG"] == 'true'
end

# to debug:
#  restart passenger in development, single server.
#  rake restart DEBUG=true
#  rdebug -c

