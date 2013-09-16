# -*- encoding : utf-8 -*-
h = Wagn::Conf
if base_u = h[:base_url]
  h[:base_url] = base_u.gsub!(/\/$/,'')
  h[:host] = base_u.gsub(/^https?:\/\//,'') unless h[:host]
end

h[:root_path] = begin
  epath = ENV['RAILS_RELATIVE_URL_ROOT']
  epath && epath != '/' ? epath : ''
end

h[:attachment_web_dir]     ||= h[:root_path] + '/files'
h[:attachment_storage_dir] ||= "#{Rails.root}/local/files"

h[:mod_dirs] = if %w{ test cucumber }.include? Rails.env
  ''
else
  h[:mod_dirs] || "#{Rails.root}/local/mods"
end

h[:read_only] = begin
  read_only_raw = !ENV['WAGN_READ_ONLY'].nil? ? ENV['WAGN_READ_ONLY'] : h[:read_only]
  [true, 'true'].member? read_only_raw
end
