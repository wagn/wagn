module AllSets
  Dir.glob('lib/wagn/set/**/*_module.rb').each do |f|
    f =~ /lib\/(wagn\/set\/.*_module)\.rb$/ and
      class_eval $1.split('/').map{|s| s.camelize}*'::'
  end
end
