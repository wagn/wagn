
module AllSets
end

require 'wagn/model/pattern'
require 'wagn/renderer'

module AllSets
  Dir.glob('lib/wagn/set/**/*.rb').each do |file|
    file =~ /lib\/(wagn\/set\/.*)\.rb$/ and class_eval $1.camelize
  end
end
