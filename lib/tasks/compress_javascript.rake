task :compress_javascript => :environment do
  cmd = "cd #{RAILS_ROOT}/public/javascripts; " +
        "cat #{JAVASCRIPT_FILES.join(" ")} > #{COMPRESSED_JS}.tmp; " +
        "java -jar ../../lib/custom_rhino.jar -c #{COMPRESSED_JS}.tmp > #{COMPRESSED_JS}; " +
        "rm #{COMPRESSED_JS}.tmp"
  `#{cmd}`  
end
