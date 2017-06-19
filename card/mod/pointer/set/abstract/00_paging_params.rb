format do
  def limit_param
    @limit ||=
      Env.params[:limit].present? ? Env.params.delete(:limit).to_i : default_limit
  end

  def offset_param
    @offset ||=
      Env.params[:offset].present? ? Env.params.delete(:offset).to_i : 0
  end
end
