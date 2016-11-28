
format :html do
  # generate bootstrap column layout
  # @example
  #   layout container: true, fluid: true, class: "hidden" do
  #     row 6, 6, class: "unicorn" do
  #       column "horn",
  #       column "rainbow", class: "colorful"
  #     end
  #   end
  # @example
  #   layout do
  #     row 3, 3, 4, 2, class: "unicorn" do
  #       [ "horn", "body", "tail", "rainbow"]
  #     end
  #     add_html "<span> some extra html</span>"
  #     row 6, 6, ["unicorn", "rainbow"], class: "horn"
  #   end
  #delegate :layout, to: :bootstrap, prefix: :bs
  def bs_layout opts={}, &block
    bootstrap.layout opts, &block
      #layout opts, &block
    #end
  end
  #alias_method :layout, :bs_layout
end


