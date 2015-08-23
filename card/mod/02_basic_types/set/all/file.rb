# FIXME: these methods should move to type/file.rb but some machine stuff is failing if it's not in a "all" set
def store_dir
  if (mod = mod_file?)
    "#{ Cardio.gem_root}/mod/#{mod}/file/#{codename}"
  elsif id
    "#{ Card.paths['files'].existent.first }/#{id}"
  else
    tmp_store_dir
  end
end

def tmp_store_dir
  "#{ Card.paths['files'].existent.first }/#{key}"
end

def mod_file?
  # when db_content was changed assume that it's no longer a mod file
  if !db_content_changed? && content.present? && (
      content =~ /^:[^\/]+\/([^.]+)/ || # current mod_file format
      content.scan("\n").size == 3      # old format, still used in card_changes.
      )
    $1
  end
end



format :file do

  view :core do |args|
    'File rendering of this card not yet supported'
  end


  view :style do |args|
    nil
  end

end
