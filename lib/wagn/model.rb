Wagn.send :include, Wagn::Exceptions

module Wagn::Model
  def self.included(base)
    super
    Wagn::Sets.load

#    Rails.logger.warn "model constants: #{Wagn::Model.constants.map(&:to_s)*", "}"
    Wagn::Model.constants.each do |const|
      base.send :include, Wagn::Model.const_get(const)
    end
  end
end
