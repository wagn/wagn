format :html do  

  view :list_item do |args|
    %{
      <li class="pointer-li input-group">
        #{ text_field_tag 'pointer_item', args[:pointer_item], :class=>'pointer-item-text form-control' }
        <span class="input-group-btn">
          <button class="pointer-item-delete glyphicon glyphicon-remove-circle btn btn-default" type="button"></button> 
        </span>
      </li>
    }
  end

  view :edit do |args|
    super(args.merge(:pointer_item_class=>'form-control'))
  end
  
  view :editor do |args|
    super(args.merge(:pointer_item_class=>'form-control'))
  end
  
end