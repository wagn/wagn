Rake::Task['assets:precompile'].enhance do
  access_file = File.join(Rails.public_path, 'files/.htaccess')
  target = File.join(Rails.public_path, 'assets')
  
  cp access_file, target
end