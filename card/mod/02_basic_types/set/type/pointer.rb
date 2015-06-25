
event :add_and_drop_items, :before=>:approve, :on=>:save do
  self.add_item Env.params['add_item']   if Env.params['add_item']
  self.drop_item Env.params['drop_item'] if Env.params['drop_item']
end

event :insert_item_event, :before=>:approve, :on=>:save, :when=> proc {|c| Env.params['insert_item']} do
  index = Env.params['item_index'] || 0
  self.insert_item index.to_i, Env.params['insert_item']
end

format do
  def item_links args={}
    card.item_cards(args).map do |item_card|
      subformat(item_card).render_link
    end
  end

  def wrap_item item, args={}
    item #no wrap in base
  end

  view :core do |args|
    render_pointer_items args.merge(:joint=>', ')
  end

  view :pointer_items, :tags=>:unknown_ok do |args|
    i_args = item_args(args)
    joint = args[:joint] || ' '
    card.item_cards.map do |i_card|
      wrap_item nest(i_card, i_args.clone), i_args
    end.join joint
  end
end

format :html do

  view :core do |args|
    %{<div class="pointer-list">#{ render_pointer_items args }</div>}
  end

  view :closed_content do |args|
    args[:item] = (args[:item] || inclusion_defaults(card)[:view])=='name' ? 'name' : 'link'
    args[:joint] ||= ', '
    _render_core args
  end

#  view :edit do |args|
#    super(args.merge(:pointer_item_class=>'form-control'))
#  end

  view :editor do |args|
    part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
    hidden_field( :content, :class=>'card-content') +
    raw(_render part_view, args)

    #.merge(:pointer_item_class=>'form-control')))
  end

  view :list do |args|
    args ||= {}
    items = args[:item_list] || card.item_names(:context=>:raw)
    items = [''] if items.empty?
    options_card_name = (oc = card.options_rule_card) ? oc.cardname.url_key : ':all'

    extra_css_class = args[:extra_css_class] || 'pointer-list-ul'

    %{
      <ul class="pointer-list-editor #{extra_css_class}" data-options-card="#{options_card_name}">
        #{
          items.map do |item|
            _render_list_item args.merge( :pointer_item=>item )
          end * "\n"
        }
      </ul>
      #{ add_item_button }
    }
  end

  def add_item_button
    content_tag :span, :class=>'input-group' do
      button_tag :class=>'pointer-item-add' do
        glyphicon('plus') + ' add another'
      end
    end
  end

  view :list_item do |args|
    %{
      <li class="pointer-li">
      <span class="input-group">
        <span class="input-group-addon handle">
          #{ glyphicon 'option-vertical left' }
          #{ glyphicon 'option-vertical right'}
        </span>
        #{ text_field_tag 'pointer_item', args[:pointer_item], :class=>'pointer-item-text form-control' }
        <span class="input-group-btn">
          <button class="pointer-item-delete btn btn-default" type="button">
            #{ glyphicon 'remove'}
          </button>
        </span>
        </span>
      </li>
    }
  end


  view :checkbox do |args|
    options = card.option_names.map do |option_name|
      checked = card.item_names.include?(option_name)
      label = ((o_card = Card.fetch(option_name)) && o_card.label) || option_name
      id = "pointer-checkbox-#{option_name.to_name.key}"
      description = pointer_option_description option_name
      %{
        <div class="pointer-checkbox">
          #{ check_box_tag "pointer_checkbox", option_name, checked, :id=>id, :class=>'pointer-checkbox-button' }
          <label for="#{id}">#{label}</label>
          #{ %{<div class="checkbox-option-description">#{ description }</div>} if description }
        </div>
      }
    end.join "\n"

    %{<div class="pointer-checkbox-list">#{options}</div>}
  end

  view :multiselect do |args|
    select_tag("pointer_multiselect",
      options_for_select(card.option_names, card.item_names),
      :multiple=>true, :class=>'pointer-multiselect form-control'
    )
  end

  view :radio do |args|
    input_name = "pointer_radio_button-#{card.key}"
    options = card.option_names.map do |option_name|
      checked = (option_name==card.item_names.first)
      id = "pointer-radio-#{option_name.to_name.key}"
      label = ((o_card = Card.fetch(option_name)) && o_card.label) || option_name
      description = pointer_option_description option_name
      %{
        <li class="pointer-radio radio">
          #{ radio_button_tag input_name, option_name, checked, :id=>id, :class=>'pointer-radio-button' }
          <label for="#{id}">#{ label }</label>
          #{ %{<div class="radio-option-description">#{ description }</div>} if description }
        </li>
      }
    end.join("\n")

    %{<ul class="pointer-radio-list">#{options}</ul>}
  end

  view :select do |args|
    options = [["-- Select --",""]] + card.option_names.map{ |x| [x,x]}
    select_tag("pointer_select",
      options_for_select(options, card.item_names.first),
      :class=>'pointer-select form-control'
    )
  end


  def pointer_option_description option
    pod_name = card.rule(:options_label) || 'description'
    dcard = Card[ "#{option}+#{pod_name}" ]
    if dcard and dcard.ok? :read
      with_inclusion_mode :normal do
        subformat(dcard).render_core
      end
    end
  end



  def wrap_item item, args
    %{<div class="pointer-item item-#{args[:view]}">#{item}</div>}
  end


end


format :css do
  view :titled do |args|
    %(#{major_comment "STYLE GROUP: \"#{card.name}\"", '='}#{ _render_core })
  end

  view :core do |args|
    card.item_cards.map do |item|
      nest item, :view=>(params[:item] || args[:item] || :content)
    end.join "\n\n"
  end

  view :content, :core

end


format :js do
  view :core do |args|
    card.item_cards.map do |item|
      nest item, :view=>(params[:item] || args[:item] || :core)
    end.join "\n\n"
  end
end


format :data do
  view :core do |args|
    card.item_cards.map do |c|
      nest c
    end
  end
end


event :standardize_items, :before=>:approve, :on=>:save do
  if db_content_changed?
    self.content = item_names(:context=>:raw).map { |name| "[[#{name}]]" }.join "\n"
  end
end

def diff_args
  {:format => :pointer}
end

def item_cards args={}
  if args[:complete]
    #warn "item_card[#{args.inspect}], :complete"
    Card::Query.new({:referred_to_by=>name}.merge(args)).run
  else

    itype = args[:type] || item_type
    #warn "item_card[#{inspect}], :complete"
    item_names(args).map do |name|
      new_args = itype ? { :type=>itype } : {}
      Card.fetch name, :new=>new_args
    end.compact # compact?  can't be nil, right?
  end
end


def item_names args={}
  context = args[:context] || self.cardname
  content = args[:content] || self.raw_content
  content.to_s.split(/\n+/).map do |line|
    item_name = line.gsub( /\[\[|\]\]/, '').strip
    if context == :raw
      item_name
    else
      item_name.to_name.to_absolute context
    end
  end
end


def item_ids args={}
  item_names(args).map do |name|
    Card.fetch_id name
  end.compact
end

def item_type
  opt = options_rule_card
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

def add_item name
  unless include_item? name
    self.content="[[#{(item_names << name).reject(&:blank?)*"]]\n[["}]]"
  end
end
def add_item! name
  add_item name
  save!
end

def drop_item name
  if include_item? name
    key = name.to_name.key
    new_names = item_names.reject{ |n| n.to_name.key == key }
    self.content = new_names.empty? ? '' : "[[#{new_names * "]]\n[["}]]"
  end
end
def drop_item! name
  drop_item name
  save!
end

def insert_item index, name
  new_names = item_names
  new_names.delete(name)
  new_names.insert(index,name)
  self.content =  new_names.map { |name| "[[#{name}]]" }.join "\n"
end
def insert_item! index, name
  insert_item index, name
  save!
end


def options_rule_card
  self.rule_card :options
end

def option_names
  result_cards = if oc = options_rule_card
    oc.item_names :default_limit=>50, :context=>name
  else
    Card.search :sort=>'name', :limit=>50, :return=>:name
  end
  if selected_options = item_names
    result_cards = result_cards | selected_options
  end
  result_cards
end

def option_cards
  result_cards = if oc = options_rule_card
    oc.item_cards :default_limit=>50, :context=>name
  else
    Card.search :sort=>'alpha', :limit=>50
  end
  if selected_options = item_names
    selected_options.each do |item|
      result_cards.push Card.fetch(item,:new=>{})
    end
    result_cards.uniq!
  end
  result_cards
end
