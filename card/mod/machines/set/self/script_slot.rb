include_set Abstract::CodeFile

def source_files
  %w(wagn_mod wagn_editor wagn_layout wagn_navbox wagn_upload wagn).map do |n|
    "#{n}.js.coffee"
  end
end
