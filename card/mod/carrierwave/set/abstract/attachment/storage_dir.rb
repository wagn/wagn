MOD_FILE_DIR = "file"

def store_dir
  store_as == :coded ? coded_dir(@new_mod) : upload_dir
  #@store_in_mod ? mod_dir : upload_dir
end

def retrieve_dir
  coded? ? coded_dir : upload_dir
end

# place for files of regular file cards
def upload_dir
  id ? "#{files_base_dir}/#{id}" : tmp_upload_dir
end

# place for files of mod file cards
def coded_dir new_mod=nil
  dir = File.join mod_dir(new_mod), MOD_FILE_DIR, codename
  FileUtils.mkdir_p dir
  dir
end

def mod_dir new_mod=nil
  Card.paths["mod"].to_a.each do |mod_path|
    dir = File.join(mod_path, new_mod || mod)
    return dir if Dir.exist? dir
  end
  raise Error, "can't find mod directory for mod \"#{new_mod || mod}\""
end

def files_base_dir
  bucket ? bucket_config[:subdirectory] : Card.paths["files"].existent.first
end

# used in the indentifier
def file_dir
  if coded?
    ":#{codename}"
  elsif cloud?
    "(#{bucket})/#{file_id}"
  else
    "~#{file_id}"
  end
end

def public?
  who_can(:read).include? Card[:anyone].id
end

def file_id
  id? ? id : upload_cache_card.id
end

def public_file_dir
  File.join Cardio.paths["public"].existent.first, file_dir
end
