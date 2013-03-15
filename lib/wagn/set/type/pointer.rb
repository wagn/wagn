
module Wagn
  module Set::Type::Pointer
    include Sets

    format :base

    define_view :core, :type=>'pointer' do |args|
      card.item_names.join ', '
    end


    format :html

    define_view :core, :type=>'pointer' do |args|
      itemview = args[:item] || :closed #Wagn::Renderer::DEFAULT_ITEM_VIEW  #FIXME: this needs work, it won't subclass as intended
      %{<div class="pointer-list">#{card.pointer_items self, itemview}</div>}
      #+ link_to( 'add/edit', path(action), :remote=>true, :class=>'slotter add-edit-item' ) #ENGLISH
    end

    define_view :closed_content, :type=>'pointer' do |args|
      itemview = args[:item]=='name' ? 'name' : 'link'
      %{<div class="pointer-list">#{card.pointer_items self, itemview}</div>}
    end

    define_view :editor, :type=>'pointer' do |args|
      part_view = (c = card.rule(:input)) ? c.gsub(/[\[\]]/,'') : :list
      form.hidden_field( :content, :class=>'card-content') +
      raw(_render(part_view))
    end

    define_view :list, :type=>'pointer' do |args|
      args ||= {}
      items = args[:items] || card.item_names(:context=>:raw)
      items = [''] if items.empty?
      options_card_name = ((oc = card.options_card) ? oc.name : '*all').to_name.url_key

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

    define_view :checkbox, :type=>'pointer' do |args|
      %{<div class="pointer-checkbox-list">} +
      card.options.map do |option|
        checked = card.item_names.include?(option.name)
        id = "pointer-checkbox-#{option.cardname.key}"
        %{<div class="pointer-checkbox"> } +
          check_box_tag( "pointer_checkbox", option.name, checked, :id=>id, :class=>'pointer-checkbox-button' ) +
          %{<label for="#{id}">#{option.name}</label> } +
          ((description = card.option_text(option.name)) ?
            %{<div class="checkbox-option-description">#{ description }</div>} : '' ) +
        "</div>"
      end.join("\n") +
      '</div>'
    end

    define_view :multiselect, :type=>'pointer' do |args|
      options = options_from_collection_for_select(card.options,:name,:name,card.item_names)
      select_tag("pointer_multiselect", options, :multiple=>true, :class=>'pointer-multiselect')
    end

    define_view :radio, :type=>'pointer' do |args|
      input_name = "pointer_radio_button-#{card.key}"
      options = card.options.map do |option|
        checked = (option.name==card.item_names.first)
        id = "pointer-radio-#{option.cardname.key}"
        description = card.option_text(option.name)
        %{ <div class="pointer-radio"> } +
          radio_button_tag( input_name, option.name, checked, :id=>id, :class=>'pointer-radio-button' ) +
          %{<label for="#{id}">#{ option.name }</label> } +
          (description ? %{<div class="radio-option-description">#{ description }</div>} : '') +
        '</div>'
      end.join("\n")

      %{ <div class="pointer-radio-list">#{options}</div> }
    end

    define_view :select, :type=>'pointer' do |args|
      options = [["-- Select --",""]] + card.options.map{|x| [x.name,x.name]}
      select_tag("pointer_select", options_for_select(options, card.item_names.first), :class=>'pointer-select')
    end


    module Model
      def collection?() true  end

      def pointer_items renderer, itemview
        typeparam = case (type=item_type)
          when String ; ";type:#{type}"
          when Array  ; ";type:#{type.second}"  #type spec is likely ["in", "Type1", "Type2"]
          else ""
        end
        renderer.process_content_object content.gsub(/\[\[/,"<div class=\"pointer-item item-#{itemview}\">{{").gsub(/\]\]/,"|#{itemview}#{typeparam}}}</div>")
      end

      def item_cards( args={} )
        if args[:complete]
          #warn "item_card[#{args.inspect}], :complete"
          Wql.new({:referred_to_by=>name}.merge(args)).run
        else
          #warn "item_card[#{inspect}], :complete"
          item_names(args).map do |name|
            Card.fetch name, :new=>{}
          end.compact
        end
      end

      def item_names( args={} )
        context = args[:context] || self.cardname
        cc=self.raw_content
        self.content.split(/\n+/).map{ |line|
          line.gsub(/\[\[|\]\]/,'')
        }.map{ |link| context==:raw ? link : link.to_name.to_absolute(context) }
      end

      def item_type
        opt = options_card
        return nil if (!opt || opt==self)  #fixme, need better recursion prevention
        opt.item_type
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
        card = self.rule_card :options
        (card && card.collection?) ? card : nil
      end

      def options
        (oc=self.options_card) ? oc.item_cards(:default_limit=>50) : Card.search(:sort=>'alpha',:limit=>50)
      end

      def option_text(option)
        name = self.rule(:options_label) || 'description'
        textcard = Card["#{option}+#{name}"]
        textcard ? textcard.content : nil
      end
    end
  end
end
