format :html do

  def frame args={}, &block
    args.reverse_merge!(
      :slot_class=>'card-frame panel panel-default',
      :body_class=>'panel-body'
    )
    super args
  end

end 