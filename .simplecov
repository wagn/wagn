
unless ENV['COVERAGE'] == 'false'
    
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/features/'
    add_filter '/config/'
    add_filter '/tasks/'
    add_filter '/generators/'
    add_filter 'lib/wagn'

    add_group 'Card', 'lib/card'  
    add_group 'Set Patterns', 'tmp/set_patterns'
    add_group 'Sets',         'tmp/sets'
    add_group 'Formats' do |src_file|
      src_file.filename =~ /mods\/[^\/]+\/formats/
    end
    add_group 'Chunks' do |src_file|
      src_file.filename =~ /mods\/[^\/]+\/chunks/
    end
  end

end
