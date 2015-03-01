format :html do
  def button_tag content_or_options = nil, options = {}, &block
    if block_given?
      content_or_options[:class] ||= ''
      content_or_options[:class] += ' btn btn-default'
    else
      options[:class] ||= ''
      options[:class] += ' btn btn-default'
    end
    super(content_or_options, options, &block)
  end

  
  
  def fieldset title, content, opts={}
    if attribs = opts[:attribs]
      attrib_string = attribs.keys.map do |key| 
        %{#{key}="#{attribs[key]}"}
      end * ' '
    end
    help_text = case opts[:help]
      when String ; _render_help :help_text=> opts[:help]
      when true   ; _render_help
      else        ; nil
    end
    %{
      <fieldset #{ attrib_string }>
        <legend>
          <h5>#{ title }</h5>
          #{ help_text }
        </legend>
        #{ editor_wrap( opts[:editor] ) { content } }
      </fieldset>
    }
  end
  
   def type_field args={}
     args[:class] ||= ''
     args[:class] += ' form-control'
     super(args)
   end
end