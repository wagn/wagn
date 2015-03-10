format :html do

  def frame args={}, &block
    args.reverse_merge!(
      :slot_class   => 'panel panel-default',
      :header_class => 'panel-heading',
      :title_class  => 'panel-title',
      :body_class   => 'panel-body'
    )
    super args
  end
end 
