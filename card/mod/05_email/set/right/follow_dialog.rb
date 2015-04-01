def raw_content
  "Follow #{left.follow_label}"
end

def virtual?; true end


format :html do
  def default_modal_args args
    args[:buttons] = button_tag 'Follow'
    args[:buttons] += button_tag 'Advanced'
    args[:buttons] += button_tag 'Cancel', 'data-dismiss'=>'modal'
  end
end