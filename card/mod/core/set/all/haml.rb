format do
  def render_haml locals={}, template=nil, a_binding=nil, &block
    template ||= yield
    a_binding ||= binding
    ::Haml::Engine.new(template).render(a_binding, locals)
  end
end
