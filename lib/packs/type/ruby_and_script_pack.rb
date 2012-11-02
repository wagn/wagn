class Shellbox
  def run(cmd)
    Dir.chdir( Rails.root + '/public_scripts')
    IO.popen("/usr/bin/env PATH='.' /bin/bash --restricted", "w+") do |p|
      p.puts cmd
      p.close_write
      p.read
    end
  end
end

class Wagn::Renderer
  define_view :core, :type=>'script' do |args|
    command = process_content( card.content )
    begin
      if Wagn::Conf[:enable_server_cards]
        Shellbox.new.run( command )
      else
        'sorry, server cards are not enabled' #ENGLISH
      end
    rescue Exception=>e
      e.message
    end
  end

  alias_view( :editor, {:type=>'plain_text'},  {:type=>'script'} )

end
