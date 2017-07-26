include_set Abstract::CodeFile
include_set Abstract::BootstrapCodeFile

view :raw do |_args|
  content = File.read File.join(BOOTSTRAP_PATH, "mixins", "_breakpoints.scss")
  content + card.read_dir("mixins")
end
