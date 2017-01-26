format do
  # Renders haml templates. The haml template can be passed as string or
  # block or a symbol that refers to a view template.
  # @param  template_or_locals [Hash, String, Symbol]
  #   If a symbol is given then a template is expected in the corresponding view
  #   directory. Note that {view_template_path} needs to be overridden in
  #   that case to get the right path to the template.
  # @return [String] rendered haml as HTML
  # @example render a view template
  #   # view/type/basic/my_template.haml:
  #   %p
  #     Hi
  #     = name
  #
  #   # set/type/basic.rb:
  #   view :my_view do
  #     render_haml :my_template, name: "Joe:  # => "<p>Hi Joe<p/>"
  #   end
  # @example use a block to pass haml
  #   render_haml name: "Joe" do
  #     <<-HAML.strip_heredoc
  #       %p
  #         Hi
  #         = name
  #     HAML
  #   # => <p>Hi Joe</p>
  # @example create a slot in haml code
  #   - haml_wrap do
  #     %p
  #       some haml
  def render_haml template_or_locals={}, locals_or_binding={}, a_binding=nil
    if template_or_locals.is_a?(Symbol)
      return render_haml_template template_or_locals, locals_or_binding
    end
    if block_given?
      haml_to_html yield, template_or_locals, locals_or_binding
    else
      haml_to_html template_or_locals, locals_or_binding, a_binding
    end
  end

  # @todo Make this more like Rails a implicit feature of a view.
  #   For a start use a different view command. Example
  #   # view/type/basic/my_view.haml:
  #   = name
  #
  #   # set/type/basic.rb:
  #   haml_view :myview do
  #     @name = "Joe"
  #   end
  def render_haml_template view, locals={}
    template = ::File.read view_template_path(view)
    voo = View.new self, view, locals, @voo
    with_voo voo do
      haml_to_html template, locals
    end
  end

  # @todo This is a hack to make haml view templates work.
  #       Needs a general automatic solution.
  # This method must be overridden in every set that uses haml templates
  # so that `__FILE__` points to the right file.
  # @return [String] path to haml view template
  # @example
  #   def view_template_path view
  #     super(view, __FILE__)
  #   end
  def view_template_path view, file=__FILE__
    first_try = ::File.expand_path("../#{view}.haml", file)
      .gsub(%r{/tmp/set/mod\d+-([^/]+)/}, '/mod/\1/view/')
    return first_try if ::File.exist?(first_try)
    basename = ::File.basename(file, ".rb")
    ::File.expand_path("../#{basename}/#{view}.haml", file)
      .gsub(%r{/tmp/set/mod\d+-([^/]+)/}, '/mod/\1/view/')
  end

  def haml_to_html haml, locals, a_binding=nil
    a_binding ||= binding
    ::Haml::Engine.new(haml).render a_binding, locals
  end
end

