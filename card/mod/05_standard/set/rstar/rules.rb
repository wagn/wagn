
format :html do

  view :closed_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule? #these are helpful for handling non-rule rstar cards until we have real rule sets
      
    rule_card = find_current_rule_card

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
    setting_name = args[:setting_name]
    
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
      :rule_context => card,   # determines the set options and the success view
      :set_context  => card.rule_set_name,
    }
    rule_view = edit_mode ? :edit_rule : :show_rule

    %{     
      <tr class="card-slot open-rule #{rule_view.to_s.sub '_', '-'}">
        <td class="rule-cell" colspan="3">
          <div class="rule-setting">
            #{ view_link setting_name.sub(/^\*/,''), :closed_rule, :class=>'close-rule-link slotter' }
            #{ card_link setting_name, :text=>"all #{setting_name} rules", :class=>'setting-link', :target=>'wagn_setting' }
          </div>
          
          <div class="alert alert-info rule-instruction">
            #{ process_content "{{#{setting_name}+*right+*help|content}}" }
          </div>
          
          <div class="card-body">
            #{ subformat( current_rule )._render rule_view, opts }
          </div>
        </td>
      </tr>
    }

  end
  
  def default_open_rule_args args
    current_rule_card = find_current_rule_card || begin
      Card.new :name=> "#{Card[:all].name}+#{card.rule_user_setting_name}"
    end
    
    args.reverse_merge! :current_rule => current_rule_card, :setting_name => card.rule_setting_name
  end
  

  view :show_rule, :tags=>:unknown_ok do |args|
    return 'not a rule' if !card.is_rule?
    
    if !card.new_card?
      set = card.rule_set
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
        #{ hidden_success_formgroup args[:success]}
        #{ editor args }
      }
    end
  end
  
  def default_edit_rule_args args
    args[:rule_context] ||= card
    args[:set_context]  ||= card.rule_set_name 
    args[:set_selected]   = params[:type_reload] ? card.rule_set_name : false
    args[:set_options], args[:fallback_set] = args[:rule_context].set_options
    
    args[:success] ||= {}
    args[:success].reverse_merge!( {
      :card => args[:rule_context],
      :id   => args[:rule_context].cardname.url_key,
      :view => 'open_rule',
      :item => 'view_rule'
    })
  end
  
  
  # used keys for args:
  # :success,  :set_selected, :set_options, :rule_context
  def editor args      
    wrap_with( :div, :class=>'card-editor' ) do
      [
        (type_formgroup( args ) if card.right.rule_type_editable),
        formgroup( 'rule', content_field( form, args.merge(:skip_rev_id=>true) ), :editor=>'content' ),
        set_formgroup( args )
      ]
    end + edit_buttons( args )
  end


  def type_formgroup args
    formgroup 'type', type_field(
      :href         => path(:name=>args[:success][:card].name, :view=>args[:success][:view], :type_reload=>true),
      :class        => 'type-field rule-type-field live-type-field',
      'data-remote' => true
    ), :editor=>'type'
  end
  
  
  def hidden_success_formgroup args
    %{
      #{ hidden_field_tag 'success[id]', args[:id] || args[:card].name }
      #{ hidden_field_tag 'success[view]', args[:view] }
      #{ hidden_field_tag 'success[item]', args[:item] }
    }
  end
  
  def set_formgroup args
    current_set_key = card.new_card? ? Card[:all].cardname.key : card.rule_set_key   # (should have a constant for this?)
    tag = args[:rule_context].rule_user_setting_name
    narrower_rules = []
    option_list = 
      wrap_each_with :li, :class=>'radio' do
        args[:set_options].map do |set_name, state|
          
          checked    = ( args[:set_selected] == set_name or current_set_key && args[:set_options].length==1 )
          is_current = (state == :current)
          warning = if narrower_rules.present?
                      plural = narrower_rules.size > 1 ? 's' : ''
                      "This rule will not have any effect on this card unless you delete the narrower rule#{plural} "+
                       "for #{narrower_rules.to_sentence}."
                    end
          if is_current || state == :overwritten
             narrower_rules << Card.fetch(set_name).label
             narrower_rules.last[0] = narrower_rules.last[0].downcase
          end
          rule_name  = "#{set_name}+#{tag}"
          radio_button( :name, rule_name, :checked=>checked, :warning=>warning ) + %{
              <label class="set-label" #{'current-set-label' if is_current }>
                #{ card_link set_name, :text=> Card.fetch(set_name).label, :target=>'wagn_set' }
                #{'<em>(current)</em>' if is_current }
                #{"<em> #{card_link "#{set_name}+#{card.rule_user_setting_name}", :text=>"(overwritten)"}</em>" if state == :overwritten }
              </label>
             }.html_safe
         end

       end
    formgroup 'set', "<ul>#{ option_list }</ul>", :editor => 'set'
  end
  
  def edit_buttons  args
    delete_button = if !card.new_card?
                      b_args = { :remote=>true, :class=>'rule-delete-button slotter', :type=>'button' }
                      b_args[:href] = path :action=>:delete, :success=>args[:success]
                      if (fset = args[:fallback_set]) && (fcard = Card.fetch(fset))
                        b_args['data-confirm']="Deleting will revert to #{card.rule_setting_name} rule for #{fcard.label }"
                      end
                      %{<span class="rule-delete-section">#{ button_tag 'Delete', b_args }</span>}
                    end
    cancel_path = path :view=>( card.new_card? ? :closed_rule : :open_rule )
    wrap_with( :div, :class=>'button-area' ) do
     [
       delete_button,
       button_tag( 'Submit', :class=>'rule-submit-button', :situation=>'primary' ),
       button_tag( 'Cancel', :class=>'rule-cancel-button slotter', :type=>'button',
                             :href=>cancel_path, :success=>true ) 
     ]
    end
  end
  
=begin
  view :edit_rule2 do |args|
    
    card_form :update do
      [
        _optional_render( :type_formgroup,    args ),
        _optional_render( :content_formgroup, args ),
        _optional_render( :set_formgroup,     args ),
        _optional_render( :button_formgroup,  args )
      ]
    end
  end
=end
  
  def default_follow_item_args args
    args[:condition] ||= Env.params[:condition] || '*always'
  end
  
  view :follow_item, :tags=>:unknown_ok do |args|
    if card.new_card? || !card.include_item?(args[:condition])
      button_view = :add_button
      form_opts = {:add_item=>args[:condition]}
    else
      button_view = :delete_button
      form_opts = {:drop_item=>args[:condition]}
    end

    text = if (option_card = Card.fetch args[:condition])
             option_card.description(card.rule_set)
           else
             card.rule_set.follow_label
           end
    link_target = if card.rule_set.tag.codename == 'self'
                    card.rule_set_name.left
                  else
                    "#{card.rule_set_name}+by name"
                  end
    wrap do
      card_form({:action=>:update, :name=>card.name, :success=>{:view=>:follow_item}}, 
              :hidden=>{:condition=>args[:condition]}.merge(form_opts)) do
        output [
          _optional_render(button_view, args),
          card_link( link_target, :text=>text)
        ]
      end
    end
  end
  
  view :delete_button do |args|
    button_tag :type=>:submit, :class=>'btn-xs btn-item-delete btn-primary', 'aria-label'=>'Left Align' do
      tag :span, :class=>"glyphicon glyphicon-ok", 'aria-hidden'=>"true"
    end 

  end
  
  view :add_button do |args|
    button_tag :type=>:submit, :class=>'btn-xs btn-item-add', 'aria-label'=>'Left Align' do
      tag :span, :class=>"glyphicon glyphicon-plus", 'aria-hidden'=>"true"
    end
  end
  

  private

  def find_current_rule_card
    # self.card is a POTENTIAL rule; it quacks like a rule but may or may not exist.
    # This generates a prototypical member of the POTENTIAL rule's set
    # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
    if card.new_card?
      if setting = card.right
        card.set_prototype.rule_card setting.codename, :user=>card.rule_user
      end
    else
      card
    end 
  end

end


def rule_set_key
  rule_set_name.key
end

def rule_set_name
  if is_user_rule?
    cardname.trunk_name.trunk_name
  else
    cardname.trunk_name
  end
end

def rule_set
  if is_user_rule?
    self[0..-3]
  else
    trunk
  end
end

def rule_setting_name
  cardname.tag
end

def rule_user_setting_name
  if is_user_rule?
    "#{rule_user_name}+#{rule_setting_name}"
  else
   rule_setting_name
  end
end

def rule_user_name
  is_user_rule? ? cardname.trunk_name.tag : nil
end

def rule_user
  is_user_rule? ? self[-2] : nil
end


#~~~~~~~~~~ determine the set options to which the user can apply the rule.
def set_options

  first =  new_card? ? 0 : set_prototype.set_names.index{|s| s.to_name.key == rule_set_key} 
  rule_cnt = 0
  res = []
  fallback_set = nil
  set_prototype.set_names[first..-1].each do |set_name|
    if Card.exists?("#{set_name}+#{rule_user_setting_name}")
      rule_cnt += 1
      res << if rule_cnt == 1 
               [set_name,:current] 
             else
               fallback_set ||= set_name
               [set_name,:overwritten]
             end
    else
      res << (rule_cnt < 1 ? [set_name,:enabled] : [set_name,:disabled])
    end
  end
  
  # fallback_set = if first > 0
  #                 res[0..(first-1)].find do |set_name|
  #                   Card.exists?("#{set_name}+#{rule_user_setting_name}")
  #                 end
  #               end
  # last = res.index{|s| s.to_name.key == cardname.trunk_name.key} || -1
  # # note, the -1 can happen with virtual cards because the self set doesn't show up in the set_names.  FIXME!!
  # [res[first..last], fallback_set]
  #
  # The broadest set should always be the currently applied rule
  # (for anything more general, they must explicitly choose to "DELETE" the current one)
  # the narrowest rule should be the one attached to the set being viewed.  So, eg, if you're looking at the "*all plus" set, you shouldn't
  # have the option to create rules based on arbitrary narrower sets, though narrower sets will always apply to whatever prototype we create
  
  return res, fallback_set
end

def set_prototype
  if is_user_rule?
    self[0..-3].prototype
  else
    trunk.prototype
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
