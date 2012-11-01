Wagn.send :include, Wagn::Exceptions

module Wagn::Model
  Wagn::Set.load_dir File.expand_path( "#{Rails.root}/lib/wagn/model/*.rb",__FILE__)

  def self.included(base)
    Wagn::Model.constants.each do |const|
      base.send :include, Wagn::Model.const_get(const)
    end
  end
end

