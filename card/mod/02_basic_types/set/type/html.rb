include_set Abstract::Editor::Ace

def clean_html?
  false
end

def diff_args
  { format: :raw }
end

format do
  view :closed_content do |_args|
    ''
  end

  def chunk_list
    :references
  end
end


