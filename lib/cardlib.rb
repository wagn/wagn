
require_dependency 'wagn/sets'

Wagn.send :include, Wagn::Exceptions

module Cardlib
  #Card

  def self.included base

    Wagn::Sets.load_cardlib
    Wagn::Sets.load_sets

    Cardlib.constants.each do |const|
      base.send :include, Cardlib.const_get( const )
    end

    Wagn::Sets.load_renderers

    super
  end
end
