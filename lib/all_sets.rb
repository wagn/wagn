module AllSets
  Dir.glob('lib/wagn/set/**/*.rb').each do |f|
    f =~ /lib\/(wagn\/set\/.*)\.rb$/ and
      class_eval $1.split('/').map{|s| s.camelize}*'::'
  end
end
