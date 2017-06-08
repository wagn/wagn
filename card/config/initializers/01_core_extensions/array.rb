module CoreExtensions
  module Array
    def to_pointer_content
      map do |item|
        item =~ /^\[\[.+\]\]$/ ? item : "[[#{item}]]"
      end.join "\n"
    end

    def to_name
      Card.compose_mark self
    end
  end
end
