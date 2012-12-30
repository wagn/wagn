Wagn.send :include, Wagn::Exceptions

module Cardlib
  def self.included(base)
    super
    Wagn::Sets.load

#    Rails.logger.warn "model constants: #{Cardlib.constants.map(&:to_s)*", "}"
    Cardlib.constants.each do |const|
      base.send :include, Cardlib.const_get(const)
    end
  end
end
