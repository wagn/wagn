class Wagn::Renderer
  define_view(:editor, :right=>'*create') do
    set_name = card.name.trunk_name
    set_card = Card.fetch(card.name.trunk_name)
    return "#{set_name} is not a Set" unless set_card and set_card.typecode=='Set'

    group_options = User.as(:wagbot) { Card.search(:type=>'Role', :sort=>'name') }
    eid = context
    item_names = card.item_names
    inheritable = Wagn::Pattern.junction_only?(set_name)
    inheritable ||= set_name.tag_name=='*self' && set_name.trunk_name.junction?

    form.hidden_field( :content, :id=>"#{context}-hidden-content") +

    content_tag(:table, :class=>'permission-editor') do
      
      content_tag(:tr, :class=>'permissions-labels') do
        content_tag(:th) { 'Groups'} +
        content_tag(:th) { 'Individuals'} +
        (inheritable ? content_tag(:th) { 'Inherit'} : '')
      end +
      
      content_tag(:tr, :class=>'permissions-options') do
        content_tag(:td, :class=>'permissions-group-options') do
          group_options.map do |option|
            div(:class=>'group-option') do
              check_box_tag( "#{eid}-checkbox", option.name, !!item_names.delete(option.name),
                { :id=>"#{eid}-checkbox-#{option.key}", :class=>'permissions-checkbox-button' } 
              ) +
              span(:class=>"permission-checkbox-label") { link_to_page option.name }
            end
          end.join( "\n" )
        end +
        
        content_tag(:td, :class=>'permissions-individual-options') do
          render :list, :items=>item_names
        end +
        
        (!inheritable ? '' : content_tag(:td, :class=>'permissions-inherit') do
          'hello world'
        end)
      end
    end + 
  
    editor_hooks(:save=>%{
      boxes = jQuery('input[name=#{eid}-checkbox]:checked')
      group_vals = boxes.map(function(i,n){ return jQuery(n).val(); }).get();
      individual_vals = Element.select( $('#{context}-ul'), ".pointer-text").map(function(x){ return x.value; });
      vals = group_vals.concat(individual_vals);
      setPointerContent('#{eid}', vals );  
      return true;
    })
  end
end