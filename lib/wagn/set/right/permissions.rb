module Wagn
  module Set::Right::Permissions
    include Sets

    format :base

    define_view :editor, :right=>'create' do |args|
      set_name = card.cardname.trunk_name
      set_card = Card.fetch(set_name)
      not_set = set_card && set_card.type_id != Card::SetID

      group_options = Account.as_bot { Card.search(:type=>Card::RoleID, :sort=>'name') }

      inheritable = not_set ? false : set_card.inheritable?
      inheriting = inheritable && card.content=='_left'

      item_names = inheriting ? [] : card.item_names

      %{     
        #{ form.hidden_field :content, :class=>'card-content' }
        <div class="perm-editor">
        
          <div class="perm-group perm-vals">
            <h5>Groups</h5>
            #{
              group_options.map do |option|
                checked = !!item_names.delete(option.name)
                %{
                  <div class="group-option">
                    #{ check_box_tag( "#{option.key}-perm-checkbox", option.name, checked, :class=>'perm-checkbox-button'  ) }
                    <label>#{ link_to_page option.name }</label>
                  </div>
                }
              end * "\n"
            }
          </div>
          
          <div class="perm-indiv perm-vals">
            <h5>Individuals</h5>
            #{ _render_list :items=>item_names, :extra_css_class=>'perm-indiv-ul' }
          </div>
          
          #{
            if inheritable
              %{
                <h5>Inheritance</h5>
                #{ check_box_tag 'inherit', 'inherit', inheriting }
                #{ content_tag( :a, :title=>"use #{card.cardname.tag} rule for left card") { '?' } }
              }
            end
          }
          
        </div>
      }
    end

    define_view :core, { :right=>'create'} do |args|
      args[:item] ||= :link
      card.content=='_left' ? core_inherit_content(args) : _final_pointer_type_core(args)
    end

    define_view :closed_content, { :right=>'create'} do |args|
      card.content=='_left' ? core_inherit_content(args) : _final_pointer_type_closed_content(args)
    end

    alias_view :core,           { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
    alias_view :editor,         { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
    alias_view :closed_content, { :right=>'create' }, { :right=>'read' }, { :right=>'update' }, { :right=>'delete' }, { :right=>'comment' }
  end
  
  class Renderer::Html

    private

    def core_inherit_content args={}
      sc = args[:set_context]
      text = if sc && sc.tag_name.key == Card[:self].key
        begin
          task = card.tag.codename
          ancestor = Card[sc.trunk_name.trunk_name]
          links = ancestor.who_can( task.to_sym ).map do |card_id|
            link_to_page Card[card_id].name
          end*", "
          "#{links} (inherit)"
        rescue
          '(Inherit)'
        end
      else
        '(Inherit from left card)'
      end
      %{<div class="inherit-perm">#{text}</div>}
    end
  end
end
