class Wagn::Renderer
  define_view(:editor, :right=>'*create') do |args|
    set_name = card.cardname.trunk_name
    set_card = Card.fetch(set_name)
    return "#{set_name} is not a Set" unless set_card and set_card.typecode=='Set'

    group_options = User.as(:wagbot) { Card.search(:type=>'Role', :sort=>'name') }
    inheritable = set_card.junction_only?
    inheritable ||= ( set_name.tag_name=='*self' && set_name.trunk_name.junction? )
    inheriting = inheritable && card.content=='_left'

    item_names = inheriting ? [] : card.item_names
    form.text_field( :content, :class=>'card.content') +

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
              checked = !!item_names.delete(option.name)
              check_box_tag( "#{option.key}-perm-checkbox", option.name, checked, :class=>'permissions-checkbox-button'  ) +
              span(:class=>"permission-checkbox-label") { link_to_page option.name }
            end
          end.join( "\n" )
        end +
        
        content_tag(:td, :class=>'permissions-individual-options') do
          render :list, :items=>item_names
        end +
        
        if inheritable
          content_tag(:td, :class=>'permissions-inherit') do
            check_box_tag( 'inherit', 'inherit', inheriting ) +
            content_tag(:a, :title=>"use #{card.cardname.tag_name} rule for left card") { '?' }
          end
        else; ''; end
      end
    end


  end
  alias_view(:editor, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )
  
  define_view(:core, { :right=>'*create'}) do |args|
    card.content=='_left' ? core_inherit_content : _final_pointer_type_core(args)
  end
  alias_view(:core, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )
  
  define_view(:closed_content, { :right=>'*create'}) do |args|
    card.content=='_left' ? core_inherit_content : _final_pointer_type_closed_content(args)
  end
  alias_view(:closed_content, { :right=>'*create' }, { :right=>'*read' }, { :right=>'*update' }, { :right=>'*delete' }, { :right=>'*comment' } )

  private
  
  def core_inherit_content
    div(:class=>'inherit-permission') { '(Inherit from left card)' }
  end
end
