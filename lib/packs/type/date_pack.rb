class Wagn::Renderer
  define_view :editor, :type=>'date' do |args|
    form.text_field :content, :class=>'date-editor'
  end
end
