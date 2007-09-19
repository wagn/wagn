module Chunk
  class Transclude < Reference
    attr_reader :stars
    unless defined? TRANSCLUDE_PATTERN
      
      #  {{+name|attr:val;attr:val;attr:val}}

    TRANSCLUDE_PATTERN = /\{\{((#{'\\'+JOINT})?[^\|]+?)\s*(\|([^\}]+?))?\}\}/
    end
    def self.pattern() TRANSCLUDE_PATTERN end
  
    def initialize(match_data, content)
      super   
      #warn "FOUND TRANSCLUDE #{match_data} #{content}"
      @card_name = match_data[1].strip
      @relative = match_data[2]
      @options = {
        :view  => 'content',
        :state => 'open',
        :base  => 'self',
        :shade => 'on'
      }.merge(Hash.new_from_semicolon_attr_list(match_data[4]))
      @renderer = @content.renderer
      @card = @content.card or raise "No Card in Transclude Chunk!!"
      @unmask_text = get_unmask_text_avoiding_recursion_loops
    end
  
    private
    def base_card 
      case @options[:base]
      when 'self'; @card
      when 'parent'; @card.trunk
      else invalid_option(:base)
      end
    end
    
    def invalid_option(key)
      raise Wagn::Oops, "Invalid argument {'#{key}': '#{@options[key]}'} in transclusion syntax"
    end

    def get_unmask_text_avoiding_recursion_loops
      # FIXME why not template_tsars? what is relative? about?
      #if relative? and @card.template? #or @card.template_tsar? 
      if @card.template?
        return "#{@text}"
      end
#      if !refcard
#        return "<span class='faint'>{{#{@card_name}}}</span>\n"
#      end
      
      card = refcard ? refcard : Card.new( :name=>refcard_name )
      result = @renderer.slot.render_transclusion(card, @options)
      if WikiContent===result
        @content.merge_chunks(result) 
        result = result.pre_rendered
      end
      result
=begin       
      header, footer = '',''
      case @options[:view]
      when 'content'; #nada
      when 'titled'
        header = %{<div class="title">#{card_link}</div><p>}
        footer = '</p>'
      when 'full'
        slot_class = case @options[:state]
                      when 'closed'; "line"
                      when 'open'; "paragraph"
                      else invalid_option(:state)
                      end
        
        header = %{<div class="card-slot #{slot_class}"><div class="title">#{card_link}</div><div class="content">}
        footer = "</div></div>"
      else 
        invalid_option(:view)
      end
      
      
      action = refcard ? "editOnDoubleClick" : "createOnClick"
      open_shade, close_shade = '',''
      case @options[:shade] 
      when 'on'
        open_shade = %{<span class="transcluded">}
        close_shade = '</span>'
      when 'off';  #nada
      else invalid_option(:shade)
      end
      
      open_content, close_content = '',''
      unless header.empty? and open_shade.empty?
        faint = refcard ? "" : "faint"
        open_content = %{<span class="#{faint} content" cardId="#{refcard_id}">}
        close_content = "</span>"
      end
       
      transcluded_content = refcard ? @renderer.render( refcard ) : "Click to create #{@card_name}"
      #transcluded_content = @renderer.render( refcard )
      if refcard
        @content.merge_chunks(transcluded_content) 
        str = transcluded_content.pre_rendered
      else
        str = transcluded_content
      end
      str.insert(0, open_shade + header + open_content)      
      str.insert(-1, close_content + footer + close_shade )
      #warn "STR: #{str}"
      str
=end      
    end
  #rescue Exception=>e     
  #  return "Error rendering transcluded card #{@card.name}: #{e.message}"
  end
end
