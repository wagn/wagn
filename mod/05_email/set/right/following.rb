
include Card::Set::Type::Pointer

event :update_follow_rules, :before=>:process_subcards, :changed=>:db_content do
  if left
    Card.refresh_rule_cache_for_user left.id
    Card.clear_follower_ids_cache
    new_names = item_names
    old_names = item_names :content=>(db_content_was || '')
    (new_names-old_names).each do |item|
      add_follow_rule item
    end
    (old_names-new_names).each do |item|
      prepare_delete_follow_rule item
    end
  end
end

event :settify_new_follow_options, :before=>:update_follow_rules, :on=>:save, :changed=>:db_content do
  temp = db_content
  item_names.each do |name| 
    if (option_card = Card.fetch(name)) && 
         ( !option_card.junction? || option_card.left.type_id != SetID || !option_card.follow_option? )

      new_name = if option_card.type_id == SetID  # +followoption is missing
        "#{name}+always"
      elsif option_card.type_id == CardtypeID
        "#{name}+*type+always"
      elsif option_card.follow_option?
        "*all+#{name}"
      else
        "#{name}+*self+always"
      end
      temp.sub!("[[#{name}]]","[[#{new_name}]]")
    end
  end
  db_content = temp
end

def add_item name
  super
  add_follow_rule name
end

def drop_item name
  super
  prepare_delete_follow_rule name
end

def add_follow_rule name
  follow_rule = "#{name.to_name.left}+#{Card[:follow].name}+#{left.name}"
  subcards[follow_rule] = {:content=>"[[#{name.to_name.right}]]", :type_id=>PointerID}
end

def prepare_delete_follow_rule name
  @remove_rule_stash ||= []
  @remove_rule_stash << "#{name}+#{Card[:follow].name}+#{left.name}"
end


event :remove_follow_rule, :after=>:store, :when=> proc { |c| c.remove_rule_stash } do 
  @remove_rule_stash.each do |rule_name|
    Card.delete rule_name
  end
  @remove_rule_stash = nil
end



format()      { include Card::Set::Type::Pointer::Format     }
format :html do
   include Card::Set::Type::Pointer::HtmlFormat

   view :open do |args|
     if card.left and card.left.id == Auth.current_id 
       render_edit(args.merge(:checkbox_list=>true))
     else
       super(args)
     end
   end
   
   view :list do |args|
     if args.delete :checkbox_list
       "Following:<p>" +
       render_checkbox_lists(args) +
       '</p>Ignoring:<p>' +
       subformat(card.left.ignoring_card).render_checkbox_list(args) +
       '</p>'
     else
       super(args)
     end
   end

   view :checkbox_list do |args|
     args ||= {}
     items = args[:item_list] || card.item_names(:context=>:raw)
     items = [''] if items.empty?     
     options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

     
     list = %{<div class="pointer-checkbox-sublist">} +
       Card::FollowOption.names.map do |name|
         option_card = Card[name]
         checked = card.item_names.include?(option_card.name)
         checkbox_item option_card, checked
       end.join("\n") + 
       '</div>' + 
       items.reject{|name| card.special_follow_option? name}.map do |name|   #FIXME
         binding.pry
         if option_card = Card.fetch(name)
           checkbox_item option_card, true
         end
       end.join("\n") +
       %{ <ul class="pointer-list-editor pointer-sublist-ul" options-card="#{options_card_name}">
            <li class="pointer-li"> } +
              text_field_tag( 'pointer_item', '', :class=>'pointer-item-text', :id=>'asdfsd' ) +
              link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
       %{   </li>
          </ul>
          <div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>
       }

     %{<div class="pointer-mixed">#{list}</div>}
   end
   
   
   

   def checkbox_item option_card, checked
     id = "pointer-checkbox-#{option_card.cardname.key}"
     description = false
     %{ <div class="pointer-checkbox"> } +
       check_box_tag( "pointer_checkbox", option_card.cardname.url_key, checked, :id=>id, :class=>'pointer-checkbox-button') +
       %{ <label for="#{id}">#{option_card.follow_label}</label>
       #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>}
   end
   
   
   view :pointer_items, :tags=>:unknown_ok do |args|
     super(args.merge(:item=>:link))
   end
   
end

format(:css ) { include Card::Set::Type::Pointer::CssFormat  }

# format :html do
#   view :core do |args|
#     watch_card = Card.fetch params["subscribe"]
#     set_options = watch_card.set_names.reverse
#
#     # first = (csk=opts[:current_set_key]) ? set_options.index{|s| s.to_name.key == csk} : 0
#     # if first > 0
#     #   set_options[0..(first-1)].reverse.each do |set_name|
#     #     opts[:fallback_set] = set_name if Card.exists?("#{set_name}+#{opts[:setting_name]}")
#     #   end
#     # end
#     # last = set_options.index{|s| s.to_name.key == card.cardname.trunk_name.key} || -1
#     # # note, the -1 can happen with virtual cards because the self set doesn't show up in the set_names.  FIXME!!
#     # set_options = set_options[first..last]
#     #
#     #
#     #
#     setting_name    = args[:setting_name]
#     current_set_key = args[:current_set_key] || Card[:all].name  # (should have a constant for this?)
#     open_rule       = args[:open_rule]
#     part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
#
#     form_for card, :url=>path(:action=>:update, :no_id=>true), :remote=>true, :html=>
#         {:class=>"card-form card-rule-form slotter" } do |form|
#
#           #{ hidden_field_tag 'success[id]', open_rule.name }
#           #{ hidden_field_tag 'success[view]', 'open_rule' }
#           #{ hidden_field_tag 'success[item]', 'view_rule' }
#       %{
#         <div class="card-editor">
#           #{
#             fieldset 'set', (
#               option_items = set_options.map do |set_name|
#                 checked = false
#                 #checked = ( args[:set_selected] == set_name or current_set_key && args[:set_options].length==1 )
#                 is_current = set_name.to_name.key == current_set_key
#                 %{
#                   <li>
#                     #{ form.radio_button :name, "#{set_name}+#{setting_name}", :checked=> checked }
#                     <span class="set-label">
#                       #{ link_to_page Card.fetch(set_name).label, set_name, :target=>'wagn_set' }
#                     </span>
#                   </li>
#                 }
#               end
#               %{ <ul>#{ option_items * "\n" }</ul>}
#             ), :editor => 'set'
#           }
#         </div>
#
#         <div class="edit-button-area">
#           #{
#             if !card.new_card?
#               b_args = { :remote=>true, :class=>'rule-delete-button slotter', :type=>'button' }
#               #b_args[:href] = path :action=>:delete, :success=>{ :id=>open_rule.cardname.url_key, :view=>:open_rule, :item=>:view_rule }
#               #if fset = args[:fallback_set]
#               #  b_args['data-confirm']="Deleting will revert to #{setting_name} rule for #{Card.fetch(fset).label }"
#               #end
#               %{<span class="rule-delete-section">#{ button_tag 'Delete', b_args }</span>}
#             end
#            }
#            #{ button_tag 'Submit', :class=>'rule-submit-button' }
#            #{ button_tag 'Cancel', :class=>'rule-cancel-button slotter', :type=>'button',
#                 :href=>path( :view=>( card.new_card? ? :closed_rule : :open_rule ), :success=>true ) }
#         </div>
#         #{  form.hidden_field( :content, :class=>'card-content') + raw(_render(part_view))
#         }
#       }
#     end

