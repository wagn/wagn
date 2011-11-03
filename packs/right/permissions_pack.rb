class Wagn::Renderer
  define_view(:editor, :right=>'*create') do |args|
    set_name = card.name.trunk_name
    set_card = Card.fetch(card.name.trunk_name)
    return "#{set_name} is not a Set" unless set_card and set_card.typecode=='Set'

    group_options = User.as(:wagbot) { Card.search(:type=>'Role', :sort=>'name') }
    eid = context
    inheritable = set_card.junction_only?
    inheritable ||= set_name.tag_name=='*self' && set_name.trunk_name.junction?
    inheriting = inheritable && card.content=='_left'

    item_names = inheriting ? [] : card.item_names
    uncheck_inherit = inheritable ? "jQuery('input[name=#{eid}-inherit]').attr('checked',false)" : ''
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
                { :id=>"#{eid}-checkbox-#{option.key}", :class=>'permissions-checkbox-button', :onclick=>uncheck_inherit  } ) +
              span(:class=>"permission-checkbox-label") { link_to_page option.name }
            end
          end.join( "\n" )
        end +
        
        content_tag(:td, :class=>'permissions-individual-options') do
          render :list, :items=>item_names, :skip_editor_hooks=>true
        end +
        
        (!inheritable ? '' : content_tag(:td, :class=>'permissions-inherit') do
          check_box_tag( "#{eid}-inherit", 'inherit', inheriting, :onclick=>%{ 
            jQuery('input[name=#{eid}-checkbox]').attr('checked', false); 
            jQuery.each(jQuery('##{eid}-ul input'), function(i,x){ x.value=''; })
          }) +
          content_tag(:a, :title=>"use #{card.name.tag_name} rule for left card") { '?' }
        end)
      end
    end +

    javascript_tag( %{
      indiv_boxes = jQuery('##{context}-ul input');
      indiv_boxes.click( function() { #{uncheck_inherit};} ); 
    } ) +
  
    editor_hooks(:save=>%{
      if (jQuery('input[name=#{eid}-inherit]').attr('checked') == true) {
        jQuery('##{eid}-hidden-content')[0].value = '_left';
        return true;
      }
      boxes = jQuery('input[name=#{eid}-checkbox]:checked')
      group_vals = boxes.map(function(i,n){ return jQuery(n).val(); }).get();
      indiv_boxes = jQuery('##{context}-ul input');
      indiv_vals = jQuery.map(indiv_boxes, function(x){ return x.value; });
      vals = group_vals.concat(indiv_vals);
      setPointerContent('#{eid}', vals );  
      return true;
    })
  end
  alias_view(:editor, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )
  
  define_view(:core, { :right=>'*create'}) do |args|
    card.content=='_left' ? core_inherit_content : _final_pointer_type_core
  end
  alias_view(:core, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )
  
  define_view(:closed_content, { :right=>'*create'}) do |args|
    card.content=='_left' ? core_inherit_content : _final_pointer_type_closed_content
  end
  alias_view(:closed_content, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )

  private
  
  def core_inherit_content
    div(:class=>'inherit-permission') { '(Inherit from left card)' }
  end
end
