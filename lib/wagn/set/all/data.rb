# -*- encoding : utf-8 -*-

module Wagn
  module Set::All::Json
    extend Set

    define_view :atom do |args|
      item = args[:item]    
      item = :raw if item.nil? || item == :atom # item view of atom view
      args[:item] = :atom                       # item view of atom's item view
      h = {
        :card => {
          :name  => card.name,
          :type  => card.type_name 
        }
      }  
      h[:views] = [
        { :name => item,
          :parts => _render( item, args)
        }
      ]
      h
    end
  end
end