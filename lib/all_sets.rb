module AllSets
  Dir.glob('lib/wagn/set/**/*.rb').each do |f|
    f =~ /lib\/(wagn\/set\/.*)\.rb$/ and (mod=$1) !~ /_view$/ and
      class_eval mod.camelize
      #class_eval $1.split('/').map{|s| s.camelize}*'::'
  end
end
