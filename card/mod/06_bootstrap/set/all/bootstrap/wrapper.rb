format :html do

  def frame args={}, &block
    wrap args.merge(:slot_class=>'card-frame panel panel-default', ) do
      %{
        <div class='panel-heading'>
          #{ _render_header args }
        </div>
        #{ %{ <div class="card-subheader">#{ args[:subheader] }</div> } if args[:subheader] }
        #{ _optional_render :help, args, :hide }
        #{ wrap_body args.merge(:body_class=>'panel-body') do output( block.call(args) ) end }
      }
    end
  end
  
  def closed_frame args={}, &block
    wrap args.merge(:slot_class=>'card-frame panel panel-default', ) do
      %{
        <div class='panel-heading'>
        <div style='float: left'>
        #{ _render_header args }
        #{ %{ <div class="card-subheader">#{ args[:subheader] }</div> } if args[:subheader] }
        #{ _optional_render :help, args, :hide }
        </div>
        #{ wrap_body args.merge(:body_class=>'panel-body closed-content') do output( block.call(args) ) end }
        </div>
      }
    end
  end
  
end 