format :email_html do
  view :missing        do |args| '' end
  view :closed_missing do |args| '' end

  view :raw do |args| 
    output = card.raw_content
    if args[:locals]
      args[:locals].each do |key, value|
        output.gsub!(/\{\{\s*\_#{key.to_s}\s*\}\}/, value.to_s)
        #instance_variable_set "@#{key}", value
      end
    end
    output
  end

end


def clean_html?
  false
end
