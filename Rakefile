task :push_gems do
  %w(card wagn).each do |gem|
    system %(cd #{gem}; rm *.gem; gem build #{gem}.gemspec; gem push #{gem}-#{version}.gem)
  end
end

task :version do
  puts version
end

task :release do
  system %(git tag -a v#{version} -m "Wagn Version #{version}";  git push --tags wagn)
end

task :cp_tmpsets do
  system %(
    cd ..
    cp -r sites/core-dev/tmp/set* decko-tmpsets
    cd decko-tmpsets
    git commit -a -m 'updated from core-dev'
    git push; git push wagn
    cd ../gem
    git submodule update --remote
  )
end

def version
  File.open(File.expand_path("../card/VERSION", __FILE__)).read.chomp
end
