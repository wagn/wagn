# -*- encoding : utf-8 -*-

class CreateDeckRoutesFile < ActiveRecord::Migration
  def up
    routes_path = File.join Wagn.root, 'config', 'routes.rb'
    if !File.exist? routes_path
      template_path = File.join Wagn.gem_root, 'lib', 'wagn', 'generators', 'wagn', 'templates', 'config', 'routes.erb'
      @include_jasmine_engine = false
      decko_path = ''
      routes = ERB.new(File.read template_path).result binding
      File.open(routes_path, "w") { |f|  f.write routes }
    end
  end
end
