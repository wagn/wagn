include Machine

store_machine_output filetype: "js"

view :javascript_include_tag do |_args|
  %(
    <script src="#{card.machine_output_url}" type="text/javascript"></script>
  )
end
