format do
  def render_haml locals={}, template=nil, a_binding=nil, &block
    return render_haml_template(locals, template || {}) if locals.is_a?(Symbol)

    template ||= yield
    a_binding ||= binding
    ::Haml::Engine.new(template).render(a_binding, locals)
  end

  def render_haml_template view, locals={}
    template = ::File.read(view_template_path(view))
    voo = View.new self, view, locals, @voo
    with_voo voo do
      ::Haml::Engine.new(template).render(binding, locals)
    end
  end

  def view_template_path view, file=__FILE__
    first_try = ::File.expand_path("../#{view}.haml", file)
      .gsub(%r{/tmp/set/mod\d+-([^/]+)/}, '/mod/\1/view/')
    return first_try if ::File.exist?(first_try)
    basename = ::File.basename(file, ".rb")
    ::File.expand_path("../#{basename}/#{view}.haml", file)
      .gsub(%r{/tmp/set/mod\d+-([^/]+)/}, '/mod/\1/view/')
  end
end
