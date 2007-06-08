class QueryDatatype < Datatype::Base
  
  register "Query"
  editor_type "Query"
  
  description %{
    Describe Query datatype here.
  }
  
  def before_save(content)
    warn "Escaped #{content}"
    content = CGI::unescapeHTML( URI.unescape(content) )
    warn "UnEscaped #{content}"
    content
  end
  
  def post_render( content )
    args = options_from_content( content )
    warn "Query #{content} args=#{args.inspect}"
    cards = Card.find_by_wql_options( args )
    
    if cards.length==0
      "No cards matched this query"
    else
      warn "CARDS: #{cards.inspect}"
      Renderer.instance.controller.send(:render_to_string, :partial=>'block/tag_cloud', 
        :locals=>{ :card=>@card, :cards => cards })
    end
  #rescue Exception=>e
  #  return "Error processing query: #{e.message}"
  end
  
  def options_from_content( content=nil )
    content ||= @card.content
    args = CGIMethods.parse_query_parameters( content )
    options = args.keys.inject({}) {|hash,key| hash[key.to_sym]=args[key]; hash }
    options.delete(:cardtype) if options[:cardtype]=='Any'
    options
  end
  
  def on_revise(content)
    #nada -- other datatypes update references
  end
  
end
