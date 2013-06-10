
Wagn::SetPatterns

module Wagn::SetPatterns

  class Accounted < BasePattern
    register 'accounted', :index=>1, :method_key=>'accounted', :junction_only=>true
    def self.label name;              'Accounted "+" cards'        end
    def self.prototype_args anchor;   {:name=>'*dummy+*account'}   end
    def self.pattern_applies?  card; 
r1= !card.new_card?
r = r1 && (c=card.fetch(:skip_modules=>true,:trait=>:account)) && !c.new_card?
warn "Accounted appl? #{card.inspect}, cd:#{c.inspect}, r1:#{r1}, r:#{r.inspect}"; r
end
  end

end
