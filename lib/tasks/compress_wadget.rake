task :compress_wadget => :environment do
	cmd = "cd #{RAILS_ROOT}/public/javascripts/; \n" + 
	      "cp wadget.profile.js dojo/buildscripts/profiles/; \n" +
	      "cd dojo/buildscripts; \n" +
				"ant -Dprofile=wadget clean release \n" +
				"cd ../../; \n" +
				"cp dojo/release/dojo/dojo.js ./wadget.js \n"
  print `#{cmd}`
end