Wagn::Conf[:pack_dirs].split(/,\s*/).each do |dir|
  Wagn::Pack.dir File.expand_path( "#{dir}/**/*_pack.rb",__FILE__)
end
