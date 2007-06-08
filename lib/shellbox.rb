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