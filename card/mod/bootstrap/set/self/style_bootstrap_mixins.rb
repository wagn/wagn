include_set Abstract::CodeFile
include_set Abstract::BootstrapCodeFile

view :raw do |_args|
  # mixins
  content = File.read File.join(BOOTSTRAP_PATH, "_mixins.scss")
  content + card.read_dir("mixins")
end
