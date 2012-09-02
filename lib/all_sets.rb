module AllSets
  Dir.glob('lib/wagn/set/**/*.rb').each do |f|
    if f =~ /lib\/(wagn\/set\/.*)\.rb$/
      klass = $1.split('/').map{|s| s.camelize}*'::' #.inject(Module) {|k,m|
      #Rails.logger.warn "alls: #{k.inspect}.const_get(#{m.inspect})"
      #k.const_get(m) }
      k=class_eval(klass)
      Rails.logger.warn "all sets: #{klass.inspect}, #{k}"
    end
  end
end
