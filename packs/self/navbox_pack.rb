class Wagn::Renderer
  define_view(:raw, :name=>'*navbox') do |args|
    form_tag '/*search', :id=>'navbox-form', :method=>'get' do
      text_field_tag :_keyword, '', :class=>'navbox'
    end
  end
  alias_view(:raw, {:name=>'*navbox'}, :core)
end

# GET /*complete.json?term=xxx&view=complete (&main = whatever)
