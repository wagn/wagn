
require_dependency 'wagn/sets'

Wagn.send :include, Wagn::Exceptions

module Cardlib
  Card

  def self.included base

    Wagn::Sets.load_cardlib

    Cardlib.constants.each do |const|
      Rails.logger.warn "consts #{const}, #{base}"
      base.send :include, Cardlib.const_get( const )
    end

    Wagn::Sets.load_sets
    Wagn::Sets.load_renderers

    super
  end
end
