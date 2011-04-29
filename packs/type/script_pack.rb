class Shellbox
  def run(cmd)
    Dir.chdir( RAILS_ROOT + '/public_scripts')
    IO.popen("/usr/bin/env PATH='.' /bin/bash --restricted", "w+") do |p|
      p.puts cmd
      p.close_write
      p.read
    end
  end
end

class Renderer
  define_view(:naked, :type=>'script') do
    command = expand_inclusions( card.content )
    begin
      if System.enable_server_cards
        Shellbox.new.run( command )
      else  
        'sorry, server cards are not enabled' #ENGLISH
      end
    rescue Exception=>e
      e.message
    end
  end

  define_view(:naked, :type=>'ruby') do
    ruby = expand_inclusions( card.content )
    begin
      if System.enable_ruby_cards
        s = Sandbox.new(4)
        s.fuehreAus( ruby )
        result = if s.securityViolationDetected
            s.securityViolationText.message
          elsif s.syntaxErrorDetected
            s.syntaxErrorText.message
          else
            s.sandboxOutput.value.to_s
          end
      else
        "Ruby cards disabled" #ENGLISH
      end
    rescue Exception => e
      CGI.escapeHTML( e.message )
    end
  end

  define_view(:editor, :type=>'date') do
    date_id = "#{self.context}+'date'"
    link_text = card.content.blank? ? (t=Time.now(); [t.year , t.mon, t.day].join('-')) : card.content
    '<div>' +
    link_to_function( link_text, "scwShow($('#{date_id}'), scwID('#{date_id}'));", :id=>date_id, :class=>'date-editor-link' ) +
    '</div>' +
    form.hidden_field( :content, :id=>"#{editor_id}-content" ) +
    editor_hooks( :save=>%{$('#{editor_id}-content').value = $('#{date_id}').innerHTML; return true;} )
  end

  define_view(:editor, :type=>'ruby') do form.text_area :content end
end
