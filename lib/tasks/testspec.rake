namespace :test do
  task :all => :environment do


    puts 'This is not yet working; only first invocation takes effect'
    Rake::Task['test:functionals'].invoke
    puts 'put 2'
    Rake::Task['test:functionals'].invoke
    puts 'put 3'

#    Rake::Task['test'].invoke
#    Rake::Task['spec'].invoke
#    Rake::Task['cucumber'].invoke
  end
end