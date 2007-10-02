#!/usr/bin/env ruby
require 'pathname'                   

if ARGV.size < 1
  puts "Usage: copy_for_upgrade <from_dir> <to_dir>"
  exit
end

from_dir, to_dir = ARGV
["config/database.yml", "config/wagn.rb", "public/image/*",
   "public/images/*", "public/file/*", "public/stylesheets/local.css"].each do |path|
     path, src, dest = Pathname.new(path), Pathname.new(from_dir), Pathname.new(to_dir)
     puts `cp -r #{src+path} #{dest+path.dirname}`
  end
