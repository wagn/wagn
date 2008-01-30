task :compress_javascript => :environment do
  cmd = "cd #{RAILS_ROOT}/public/javascripts; " +
        "cat #{System.javascript_files.join(" ")} > #{System.compressed_js}.tmp; " +
        "java -jar ../../lib/custom_rhino.jar -c #{System.compressed_js}.tmp > #{System.compressed_js}; " +
        "rm #{System.compressed_js}.tmp"
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

