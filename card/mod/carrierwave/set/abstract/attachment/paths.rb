MOD_FILE_DIR = "file".freeze

def store_dir
  will_become_coded? ? coded_dir(@new_mod) : upload_dir
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
  mod_name = new_mod || mod
  dir = Card::Mod::Loader.mod_dirs.path(mod_name) || (mod_name == :test && "test")

  raise Error, "can't find mod \"#{mod_name}\"" unless dir
  dir
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
  who_can(:read).include? Card::AnyoneID
end

def file_id
  id? ? id : upload_cache_card.id
end
