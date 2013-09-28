# -*- encoding : utf-8 -*-

view :core do |args|
  card.item_names.join ', '
end

format :html do

  view :core do |args|
    %{<div class="pointer-list">#{ pointer_items args[:item] }</div>}
  end

  view :closed_content do |args|
    itemview = (args[:item] || inclusion_defaults[:view])=='name' ? 'name' : 'link'
    %{<div class="pointer-list">#{ pointer_items itemview }</div>}
  end

  view :editor do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
    form.hidden_field( :content, :class=>'card-content') +
    raw(_render(part_view))
  end

  view :list do |args| #this is a permission view.  should it go with them?
    args ||= {}
    items = args[:item_list] || card.item_names(:context=>:raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    %{<ul class="pointer-list-editor #{extra_css_class}" options-card="#{options_card_name}"> } +
    items.map do |item|
      %{<li class="pointer-li"> } +
        text_field_tag( 'pointer_item', item, :class=>'pointer-item-text', :id=>'asdfsd' ) +
        link_to( '', '#', :class=>'pointer-item-delete ui-icon ui-icon-circle-close' ) +
      '</li>'
    end.join("\n") +
    %{</ul><div class="add-another-div">#{link_to 'Add another','#', :class=>'pointer-item-add'}</div>}

  end

  view :checkbox do |args|
    options = card.options.map do |option|
      checked = card.item_names.include?(option.name)
      id = "pointer-checkbox-#{option.cardname.key}"
      description = pointer_option_description option
      %{
        <div class="pointer-checkbox">
          #{ check_box_tag "pointer_checkbox", option.name, checked, :id=>id, :class=>'pointer-checkbox-button' }
          <label for="#{id}">#{option.name}</label>
          #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>
      }
    end.join "\n"

    %{<div class="pointer-checkbox-list">#{options}</div>}
  end

  view :multiselect do |args|
    options = options_from_collection_for_select(card.options,:name,:name,card.item_names)
    select_tag("pointer_multiselect", options, :multiple=>true, :class=>'pointer-multiselect')
  end

  view :radio do |args|
    input_name = "pointer_radio_button-#{card.key}"
    options = card.options.map do |option|
      checked = (option.name==card.item_names.first)
      id = "pointer-radio-#{option.cardname.key}"
      description = pointer_option_description option
      %{ 
        <div class="pointer-radio">
        #{ radio_button_tag input_name, option.name, checked, :id=>id, :class=>'pointer-radio-button' }
        <label for="#{id}">#{ option.name }</label>
        #{ %{<div class="radio-option-description">#{ description }</div>} if description }
        </div>
      }
    end.join("\n")

    %{<div class="pointer-radio-list">#{options}</div>}
  end

  view :select do |args|
    options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]}
    select_tag("pointer_select", options_for_select(options, card.item_names.first), :class=>'pointer-select')
  end
  
  def pointer_option_description option
    pod_name = card.rule(:options_label) || 'description'
    dcard = Card[ "#{option.name}+#{pod_name}" ]
    if dcard and dcard.ok? :read
      subformat(dcard).render_core
    end
  end
  
  def pointer_items itemview=nil
    type = card.item_type
    typeparam = case ()
      when String ; ";type:#{type}"
      when Array  ; ";type:#{type.second}"  #type spec is likely ["in", "Type1", "Type2"]
      else ""
    end
    itemview ||= (@inclusion_opts && @inclusion_opts[:view]) || default_item_view
    process_content_object render_raw.gsub(/\[\[/,"<div class=\"pointer-item item-#{itemview}\">{{").gsub(/\]\]/,"|#{itemview}#{typeparam}}}</div>")
  end
end


def item_cards args={}
  if args[:complete]
    #warn "item_card[#{args.inspect}], :complete"
    Card::Query.new({:referred_to_by=>name}.merge(args)).run
  else
    #warn "item_card[#{inspect}], :complete"
    item_names(args).map do |name|
      Card.fetch name, :new=>{}
    end.compact
  end
end

def item_names args={}
  context = args[:context] || self.cardname
  self.raw_content.split(/\n+/).map{ |line|
    line.gsub(/\[\[|\]\]/,'')
  }.map{ |link| context==:raw ? link : link.to_name.to_absolute(context) }
end

def item_ids args={}
  item_names(args).map do |name|
    Card.fetch_id name
  end.compact
end

def item_type
  opt = options_card
  if !opt or opt==self #fixme, need better recursion prevention
    nil
  else
    opt.item_type
  end
end

def items= array
  self.content=''
  array.each { |i| self << i }
  save!
end

def << item
  newname = case item
    when Card     ;  item.name
    when Integer  ;  c = Card[item] and c.name
    else             item
    end
  add_item newname
end

def add_item newname
  inames = item_names
  unless inames.include? newname
    self.content="[[#{(inames << newname).reject(&:blank?)*"]]\n[["}]]"
  end
end

def drop_item name
  inames = item_names
  if inames.include? name
    inames = inames.reject{|n|n==name}
    self.content= inames.empty? ? '' : "[[#{inames * "]]\n[["}]]"
  end
end

def options_card
  self.rule_card :options
end

def options
  if oc = options_card
    oc.item_cards :default_limit=>50
  else
    Card.search :sort=>'alpha', :limit=>50
  end
end


format :css do
  view :content do |args|
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{ _render_core })
  end    
  
  view :core do |args|
    card.item_cards.map do |item|
      process_inclusion item, :view=>(params[:item] || :content)
    end.join "\n\n"
  end
end
