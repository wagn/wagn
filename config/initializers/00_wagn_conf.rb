# -*- encoding : utf-8 -*-
h = Wagn::Conf

h[:root_path] = begin
  epath = ENV['RAILS_RELATIVE_URL_ROOT']
  epath && epath != '/' ? epath : ''
end

h[:attachment_web_dir]     ||= h[:root_path] + '/files'
h[:attachment_storage_dir] ||= "#{Wagn.root}/files"

h[:mod_dirs] = if %w{ test cucumber }.include? Rails.env
  ''
else
  h[:mod_dirs] || "#{Wagn.root}/mods"
end

h[:read_only] = begin
  read_only_raw = !ENV['WAGN_READ_ONLY'].nil? ? ENV['WAGN_READ_ONLY'] : h[:read_only]
  [true, 'true'].member? read_only_raw
end
