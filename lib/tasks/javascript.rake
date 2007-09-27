task :compress_javascript => :environment do
  cmd = "cd #{RAILS_ROOT}/public/javascripts; " +
        "cat #{JAVASCRIPT_FILES.join(" ")} > #{COMPRESSED_JS}.tmp; " +
        "java -jar ../../lib/custom_rhino.jar -c #{COMPRESSED_JS}.tmp > #{COMPRESSED_JS}; " +
        "rm #{COMPRESSED_JS}.tmp"
  `#{cmd}`  
end

task :compress_wadget => :environment do   
  unless File.exist? "#{RAILS_ROOT}/public/javascripts/dojo"
    raise "Dojo must be present in /public/javascripts/dojo to compile wadget"
  end
	cmd = "cd #{RAILS_ROOT}/public/javascripts/; \n" + 
	      "cp wadget.profile.js dojo/buildscripts/profiles/; \n" +
	      "cd dojo/buildscripts; \n" +
				"ant -Dprofile=wadget clean release \n" +
				"cd ../../; \n" +
				"cp dojo/release/dojo/dojo.js ./wadget.js \n"
  print "#{cmd}"
end

task :test => [ :compress_javascript ]