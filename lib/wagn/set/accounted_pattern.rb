
Wagn::SetPatterns

module Wagn::SetPatterns

  class Accounted < BasePattern
    register 'accounted', :index=>1, :method_key=>'accounted', :junction_only=>true
    def self.label name;              'Accounted "+" cards'        end
    def self.prototype_args anchor;   {:name=>'*dummy+*account'}   end
    def self.pattern_applies? card; 
      !card.new_card? and cd = card.fetch(:skip_modules=>true,:trait=>:account) and cd.new_card?
    end
  end

end
