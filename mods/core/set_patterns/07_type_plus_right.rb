@@options = {
  :opt_keys => [:ltype, :right],
  :junction_only=>true,
  :assigns_type=>true
}

def label name
  %{All "+#{name.to_name.tag}" cards on "#{name.to_name.left_name}" cards}
end

def prototype_args anchor
  { :name=>"*dummy+#{anchor.tag}",
    :loaded_left=> Card.new( :name=>'*dummy', :type=>anchor.trunk_name )
  }
end

def anchor_name card
  left = card.left
  type_name = (left && left.type_name) || Card[ Card.default_type_id ].name
  "#{type_name}+#{card.cardname.tag}"
end
