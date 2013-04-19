# -*- encoding : utf-8 -*-
module Wagn
  module Set::Rstar
    include Sets

    format :html

    define_view :closed_rule, :rstar=>true, :tags=>:unknown_ok do |args|
      return 'not a rule' if !card.is_rule? #these are helpful for handling non-rule rstar cards until we have real rule sets
        
      rule_card = card.new_card? ? find_current_rule_card[0] : card

      rule_content = !rule_card ? '' : begin
        subrenderer(rule_card)._render_closed_content :set_context=>card.cardname.trunk_name
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



    define_view :open_rule, :rstar=>true, :tags=>:unknown_ok do |args|
      return 'not a rule' if !card.is_rule?
      
      current_rule, prototype = find_current_rule_card
      setting_name = card.cardname.tag
      current_rule ||= Card.new :name=> "*all+#{setting_name}" #FIXME use codename
      set_selected = false

      #~~~~~~ handle reloading due to type change
      if params[:type_reload] && card_args=params[:card]
        params.delete :success # otherwise updating the editor looks like a successful post
        if card_args[:name] && card_args[:name].to_name.key != current_rule.key
          current_rule = Card.new card_args
        else
          current_rule = current_rule.refresh
          current_rule.assign_attributes card_args
          current_rule.include_set_modules
        end

        set_selected = card_args[:name].to_name.left_name.to_s
      end

      edit_mode = !params[:success] && card.ok?( ( card.new_card? ? :create : :update ) )
      
      opts = {
        :open_rule    => card,
        :setting_name => setting_name,
        :set_context  => card.cardname.trunk_name
      }
      rule_view = edit_mode ? :edit_rule : :show_rule
      
      
      
      if edit_mode
        opts.merge!( {
          :fallback_set    => false,
          :current_set_key => (current_rule.new_card? ? nil : current_rule.cardname.trunk_name.key),
          :set_selected    => set_selected
        } )
        
        #~~~~~~~~~~ determine the set options to which the user can apply the rule.

        set_options = prototype.set_names.reverse
        first = (csk=opts[:current_set_key]) ? set_options.index{|s| s.to_name.key == csk} : 0
        if first > 0
          set_options[0..(first-1)].reverse.each do |set_name|
            opts[:fallback_set] = set_name if Card.exists?("#{set_name}+#{opts[:setting_name]}")
          end
        end
        last = set_options.index{|s| s.to_name.key == card.cardname.trunk_name.key} || -1
        # note, the -1 can happen with virtual cards because the self set doesn't show up in the set_names.  FIXME!!
        opts[:set_options] = set_options[first..last]


        # The broadest set should always be the currently applied rule
        # (for anything more general, they must explicitly choose to "DELETE" the current one)
        # the narrowest rule should be the one attached to the set being viewed.  So, eg, if you're looking at the "*all plus" set, you shouldn't
        # have the option to create rules based on arbitrary narrower sets, though narrower sets will always apply to whatever prototype we create
      end

      %{
        
        <tr class="card-slot open-rule #{rule_view.to_s.sub '_', '-'}">
          <td class="rule-cell" colspan="3">
            <div class="rule-setting">
              #{ link_to_view setting_name.sub(/^\*/,''), :closed_rule, :class=>'close-rule-link slotter' }
              #{ link_to_page "all rules", setting_name, :class=>'setting-link', :target=>'wagn_setting' }
            </div>
            
            <div class="instruction rule-instruction">
              #{ process_content "{{#{setting_name}+*right+*help}}" }
            </div>
            
            <div class="card-body">
              #{ subrenderer( current_rule )._render rule_view, opts }
            </div>
          </td>
        </tr>
      }

    end
    
    define_view :show_rule, :rstar=>true, :tags=>:unknown_ok do |args|
      return 'not a rule' if !card.is_rule?
      
      if !card.new_card?
        set = card.trunk
        args[:item] ||= :link
        %{
          <div class="rule-set">
            <label>Applies to</label> #{ link_to_page set.label, set.name }:
          </div>
          #{ _render_core args }
        }
      else
        'No Current Rule'
      end
    end

    define_view :edit_rule, :rstar=>true, :tags=>:unknown_ok do |args|
      return 'not a rule' if !card.is_rule?
  
      setting_name    = args[:setting_name]
      current_set_key = args[:current_set_key] || Card[:all].name  # (should have a constant for this?)
      open_rule       = args[:open_rule]

      form_for card, :url=>path(:action=>:update, :no_id=>true), :remote=>true, :html=>
          {:class=>"card-form card-rule-form slotter" } do |form|

        %{
          #{ hidden_field_tag( :success, open_rule.name ) }
          #{ hidden_field_tag( :view, 'open_rule' ) }

          <div class="card-editor">
            #{
              fieldset 'type', type_field(
                :href         => path(:card=>open_rule, :view=>:open_rule, :type_reload=>true),
                :class        => 'type-field rule-type-field live-type-field',
                'data-remote' => true
              ), :editor=>'type'
            }
            
            #{ fieldset 'content', content_field( form, args.merge(:skip_rev_id=>true) ), :editor=>'content' }
            
            #{
              fieldset 'set', (
                option_items = args[:set_options].map do |set_name|
                  checked = ( args[:set_selected] == set_name or current_set_key && args[:set_options].length==1 )
                  is_current = set_name.to_name.key == current_set_key
                  %{
                    <li>
                      #{ form.radio_button :name, "#{set_name}+#{setting_name}", :checked=> checked }
                      <span class="set-label" #{'current-set-label' if is_current }>
                        #{ link_to_page Card.fetch(set_name).label, set_name, :target=>'wagn_set' }
                        #{'<em>(current)</em>' if is_current}
                      </span>
                    </li>
                  }
                end
                %{ <ul>#{ option_items * "\n" }</ul>}
              ), :editor => 'set'
            }          
          </div>
          
          <div class="edit-button-area">
            #{ 
              if !card.new_card?
                b_args = { :remote=>true, :class=>'rule-delete-button slotter', :type=>'button' }
                b_args[:href] = path :action=>:delete, :view=>:open_rule, :success=>open_rule.cardname.url_key
                if fset = args[:fallback_set]
                  b_args['data-confirm']="Deleting will revert to #{setting_name} rule for #{Card.fetch(fset).label }"
                end
                %{<span class="rule-delete-section">#{ button_tag 'Delete', b_args }</span>}
              end
             }
             #{ submit_tag 'Submit', :class=>'rule-submit-button' }
             #{ button_tag 'Cancel', :class=>'rule-cancel-button slotter', :type=>'button',
                  :href=>path( :view=>( card.new_card? ? :closed_rule : :open_rule ), :card=>open_rule, :success=>true ) }
          </div>
          #{notice }
        }
      end
    end


    
    module Model  
   
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
    end
    
  end


  class Renderer::Html
    private

    def find_current_rule_card
      # self.card is a POTENTIAL rule; it quacks like a rule but may or may not exist.
      # This generates a prototypical member of the POTENTIAL rule's set
      # and returns that member's ACTUAL rule for the POTENTIAL rule's setting
      set_prototype = card.trunk.prototype
      rule_card = if card.new_card?
        setting = card.right and set_prototype.rule_card setting.codename   
      else
        card
      end 
      [ rule_card, set_prototype ]
    end
  end
end
