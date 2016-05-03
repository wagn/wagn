module CoreExtensions
  module Array
    def to_pointer_content
      map do |item|
        "[[#{item}]]"
      end.join "\n"
    end
  end
end
