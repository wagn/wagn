module Wagn
  module Set::Right::Permissions
    include Wagn::Sets

    format :base

    define_view :editor, :right=>'create' do |args|
      set_name = card.cardname.trunk_name
      set_card = Card.fetch(set_name)
      not_set = set_card && set_card.type_id==Card::SetID

      group_options = Session.as_bot { Card.search(:type=>Card::RoleID, :sort=>'name') }

      inheritable = not_set ? false : set_card.inheritable?
      inheriting = inheritable && card.content=='_left'

      item_names = inheriting ? [] : card.item_names

      form.hidden_field( :content, :class=>'card-content') +

      content_tag(:table, :class=>'perm-editor') do

        content_tag(:tr, :class=>'perm-labels') do
          content_tag(:th) { 'Groups'} +
          content_tag(:th) { 'Individuals'} +
          (inheritable ? content_tag(:th) { 'Inherit'} : '')
        end +

        content_tag(:tr, :class=>'perm-options') do
          content_tag(:td, :class=>'perm-group perm-vals') do
            group_options.map do |option|
              checked = !!item_names.delete(option.name)
              %{<div class="group-option">
                #{ check_box_tag( "#{option.key}-perm-checkbox", option.name, checked, :class=>'perm-checkbox-button'  ) }
                <label>#{ link_to_page option.name }</label>
              </div>}
            end * "\n"
          end +

          content_tag(:td, :class=>'perm-indiv perm-vals') do
            _render_list :items=>item_names, :extra_css_class=>'perm-indiv-ul'
          end +

          if inheritable
            content_tag(:td, :class=>'perm-inherit') do
              check_box_tag( 'inherit', 'inherit', inheriting ) +
              content_tag(:a, :title=>"use #{card.cardname.tag} rule for left card") { '?' }
            end
          else; ''; end
        end
      end


    end

    define_view :core, { :right=>'create'} do |args|
      @item_view ||= :link
      card.content=='_left' ? core_inherit_content : _final_pointer_type_core(args)
    end

    define_view :closed_content, { :right=>'create'} do |args|
      card.content=='_left' ? core_inherit_content : _final_pointer_type_closed_content(args)
    end

    alias_view :core,           { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
    alias_view :editor,         { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
    alias_view :closed_content, { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
  end
  
  class Renderer::Html

    private

    def core_inherit_content
      %{<div class="inherit-perm"> (Inherit from left card) </div>}
    end
  end
end
