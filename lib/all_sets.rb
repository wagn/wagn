
module AllSets
end

require 'wagn/model/pattern'
require 'wagn/renderer'

module AllSets
  Dir.glob('lib/wagn/set/**/*.rb').each do |file|
    begin
      file =~ /lib\/(wagn\/set\/.*)\.rb$/ and class_eval ($1+'/model').camelize
    rescue NameError
      #warn "no module #{$1}"
    end
  end
end
