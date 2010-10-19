task :testspec do
  Rake::Task['test'].invoke
  Rake::Task['spec'].invoke
  Rake::Task['cucumber'].invoke
end