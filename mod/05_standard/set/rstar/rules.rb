def set_key
  set_name.key
end

def set_name
  if is_user_rule?
    cardname.trunk_name.trunk_name
  else
    cardname.trunk_name
  end
end

def set
  if is_user_rule?
    trunk.trunk
  else
    trunk
  end
end

def setting_name
  cardname.tag
end

def user_setting_name
  if is_user_rule?
    "#{user_name}+#{setting_name}"
  else
    setting_name
  end
end

def user_name
  is_user_rule? ? cardname.trunk_name.tag : nil
end

def user
  is_user_rule? ? self[-2] : nil
end

format :html do

  view :closed_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule? #these are helpful for handling non-rule rstar cards until we have real rule sets
      
    rule_card = card.new_card? ? find_current_rule_card[0] : card

    rule_content = !rule_card ? '' : begin
      subformat(rule_card)._render_closed_content :set_context=>card.cardname.trunk_name
    end

    cells = [
      ["rule-setting",
        link_to( card.cardname.tag.sub(/^\*/,''), path(:view=>:open_rule),
          :class => 'edit-rule-link slotter', :remote => true, :rel=>'nofollow' )
      ],
      ["rule-content",
        %{<div class="rule-content-container">
           <span class="closed-content content">#{rule_content}</span>
         </div> } ],
      ["rule-set", (rule_card ? rule_card.trunk.label : '') ],
    ]

    extra_css_class = rule_card && !rule_card.new_card? ? 'known-rule' : 'missing-rule'

    %{<tr class="card-slot closed-rule">} +
    cells.map do |css_class, content|
      %{<td class="rule-cell #{css_class} #{extra_css_class}">#{content}</td>}
    end.join("\n") +
    '</tr>'
  end

  
  view :open_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule?
    current_rule = args[:current_rule]  
    setting_name = args[:setting_name] || card.setting_name
    
    edit_mode = !params[:success] && card.ok?( ( card.new_card? ? :create : :update ) )
    #~~~~~~ handle reloading due to type change
    if params[:type_reload] && card_args=params[:card]
      if card_args[:name] && card_args[:name].to_name.key != current_rule.key
        current_rule = Card.new card_args
      else
        current_rule = current_rule.refresh
        current_rule.assign_attributes card_args
        current_rule.include_set_modules
      end
      edit_mode = true
    end
    
    opts = {
      :success      => {:card => card},
      :set_context  => card.set_name,
    }
    rule_view = edit_mode ? :edit_rule : :show_rule

    %{     
      <tr class="card-slot open-rule #{rule_view.to_s.sub '_', '-'}">
        <td class="rule-cell" colspan="3">
          <div class="rule-setting">
            #{ view_link setting_name.sub(/^\*/,''), :closed_rule, :class=>'close-rule-link slotter' }
            #{ card_link setting_name, :text=>"all rules", :class=>'setting-link', :target=>'wagn_setting' }
          </div>
          
          <div class="instruction rule-instruction">
            #{ process_content "{{#{setting_name}+*right+*help}}" }
          </div>
          
          <div class="card-body">
            #{ subformat( current_rule )._render rule_view, opts }
          </div>
        </td>
      </tr>
    }

  end
  
  def default_open_rule_args args
    args.merge!({
        :current_rule => find_current_rule_card,
        :setting_name => card.cardname.tag,
      })
  end
  

  view :show_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule?
    
    if !card.new_card?
      set = card.set
      args[:item] ||= :link
      %{
        <div class="rule-set">
          <label>Applies to</label> #{ card_link set.cardname, :text=>set.label }:
        </div>
        #{ _render_core args }
      }
    else
      'No Current Rule'
    end
  end

  view :edit_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule?

    form_for card, :url=>path(:action=>:update, :no_id=>true), :remote=>true, :html=>
        {:class=>"card-form card-rule-form slotter" } do |form|
      @form = form
      %{
        #{ hidden_success_fieldset args[:success]}
        #{ editor args }
      }
    end
  end
  
  def default_edit_rule_args args
    args[:set_context] ||= card.set_name 
    args[:set_selected]  = params[:type_reload] ? card.set_name : false
    args[:success] ||= {}
    args[:success].reverse_merge!( {
      :card => card,
      :id   => card.cardname.url_key,
      :view => 'open_rule',
      :item => 'view_rule'
    })
    args[:set_options], args[:fallback_set] = set_options
  end
  
  
  #~~~~~~~~~~ determine the set options to which the user can apply the rule.
  def set_options
    res = set_prototype.set_names.reverse
    first =  card.new_card? ? 0 : res.index{|s| s.to_name.key == card.set_key} 
    
    fallback_set = if first > 0
                    res[0..(first-1)].find do |set_name|
                      Card.exists?("#{set_name}+#{card.user_setting_name}")
                    end
                  end
    last = res.index{|s| s.to_name.key == card.cardname.trunk_name.key} || -1
    # note, the -1 can happen with virtual cards because the self set doesn't show up in the set_names.  FIXME!!
    [res[first..last], fallback_set]
    
    # The broadest set should always be the currently applied rule
    # (for anything more general, they must explicitly choose to "DELETE" the current one)
    # the narrowest rule should be the one attached to the set being viewed.  So, eg, if you're looking at the "*all plus" set, you shouldn't
    # have the option to create rules based on arbitrary narrower sets, though narrower sets will always apply to whatever prototype we create
  end
  

  
  # used keys for args:
  # :success,  :set_selected, :set_options
  def editor args      
    wrap_with( :div, :class=>'card-editor' ) do
      [
        (type_fieldset( args ) if card.right.rule_type_editable),
        fieldset( 'rule', content_field( form, args.merge(:skip_rev_id=>true) ), :editor=>'content' ),
        set_fieldset( args )
      ]
    end + edit_buttons( args )
  end


  def type_fieldset args
    fieldset 'type', type_field(
      :href         => path(:card=>args[:success][:card], :view=>args[:success][:view], :type_reload=>true),
      :class        => 'type-field rule-type-field live-type-field',
      'data-remote' => true
    ), :editor=>'type'
  end
  
  
  def hidden_success_fieldset args
    %{
      #{ hidden_field_tag 'success[id]', args[:id] || args[:card].name }
      #{ hidden_field_tag 'success[view]', args[:view] }
      #{ hidden_field_tag 'success[item]', args[:item] }
    }
  end
  
  def set_fieldset args
    current_set_key = card.new_card? ? Card[:all].cardname.key : card.set_key   # (should have a constant for this?)
    tag = card.user_setting_name
    option_list = wrap_each_with :li do
                    args[:set_options].map do |set_name|
                      checked = ( args[:set_selected] == set_name or current_set_key && args[:set_options].length==1 )
                      is_current = set_name.to_name.key == current_set_key
                      rule_name = "#{set_name}+#{tag}"
                      form.radio_button( :name, rule_name, :checked=> checked ) + %{
                          <span class="set-label" #{'current-set-label' if is_current }>
                            #{ card_link set_name, :text=> Card.fetch(set_name).label, :target=>'wagn_set' }
                            #{'<em>(current)</em>' if is_current}
                          </span>
                        }.html_safe
                     end
                   end
    fieldset 'set', "<ul>#{ option_list }</ul>", :editor => 'set'
  end
  
  def edit_buttons  args
    delete_button = if !card.new_card?
                      b_args = { :remote=>true, :class=>'rule-delete-button slotter', :type=>'button' }
                      b_args[:href] = path :action=>:delete, :success=>args[:success]
                      if (fset = args[:fallback_set]) && (fcard = Card.fetch(fset))
                        b_args['data-confirm']="Deleting will revert to #{card.setting_name} rule for #{fcard.label }"
                      end
                      %{<span class="rule-delete-section">#{ button_tag 'Delete', b_args }</span>}
                    end
    cancel_path = path :view=>( card.new_card? ? :closed_rule : :open_rule )
    wrap_with( :div, :class=>'edit-button-area' ) do
     [
       delete_button,
       button_tag( 'Submit', :class=>'rule-submit-button' ),
       button_tag( 'Cancel', :class=>'rule-cancel-button slotter', :type=>'button',
                             :href=>cancel_path, :success=>true ) 
     ]
    end
  end
  
=begin
  view :edit_rule2 do |args|
    
    card_form :update do
      [
        _optional_render( :type_fieldset,    args ),
        _optional_render( :content_fieldset, args ),
        _optional_render( :set_fieldset,     args ),
        _optional_render( :button_fieldset,  args )
      ]
    end
  end
=end

  private

  def set_prototype
    if card.is_user_rule?
      card[0..-3].prototype
    else
      card.trunk.prototype
    end
  end

  def find_current_rule_card
    # self.card is a POTENTIAL rule; it quacks like a rule but may or may not exist.
    # This generates a prototypical member of the POTENTIAL rule's set
    # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
    if card.new_card?
       ((setting = card.right) && set_prototype.rule_card(setting.codename, :user=>card.user)) ||
            Card.new(:name=> "#{Card[:all].name}+#{card.user_setting_name}")
    else
      card
    end 
  end

end

# 

=begin

def repair_set
  @set_repair_attempted = true
  if real?
    reset_patterns
    template # repair happens in template loading
    include_set_modules
  end
end
 
def method_missing method_id, *args
  if !@set_repair_attempted and repair_set
    send method_id, *args
  else
    super
  end
end
=end
