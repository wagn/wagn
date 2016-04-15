# -*- encoding : utf-8 -*-

# API to create/update/delete additional cards together with the main card.
# The most common case is for fields but subcards don't have to be descendants.
#
# Example toghether with "my address" you want to create the subcards
# "my address+name", "my address+street", etc.
#
# Subcards can be added as card objects or attribute hashes.

class Card
  def subcards
    @subcards ||= Subcards.new(self)
    # @subcards ||= (director && director.subcards)
  end

  def expire_subcards
    subcards.clear
  end

  class Subcards
    attr_accessor :context_card, :keys
    def initialize context_card
      @context_card = context_card
      @keys = ::Set.new
    end

    def clear
      @keys.each do |key|
        if (subcard = fetch_subcard key)
          Card::DirectorRegister.delete subcard.director
        end
        Card.cache.soft.delete key
      end
      @keys = ::Set.new
    end

    def deep_clear cleared=::Set.new
      each_card do |card|
        next if cleared.include? card.id
        cleared << card.id
        card.subcards.deep_clear cleared
      end
      clear
    end

    def remove name_or_card
      key = subcard_key name_or_card
      return unless @keys.include? key
      @keys.delete key
      removed_card = fetch_subcard key
      if removed_card.current_action
        removed_card.current_action.delete
      end
      Card::DirectorRegister.deep_delete removed_card.director
      Card.cache.soft.delete key
      removed_card
    end

    def add name_or_card_or_attr, card_or_attr=nil
      if card_or_attr
        name = name_or_card_or_attr
      else
        card_or_attr = name_or_card_or_attr
      end
      case card_or_attr
      when Hash
        args = card_or_attr
        if name
          new_by_attributes name, args
        elsif args[:name]
          new_by_attributes args.delete(:name), args
        else
          args.each_pair do |key, val|
            case val
            when String then new_by_attributes key, content: val
            when Card
              val.name = absolutize_subcard_name key
              new_by_card val
            else new_by_attributes key, val
            end
          end
        end
      when Card
        new_by_card card_or_attr
      when Symbol, String
        new_by_attributes card_or_attr, {}
      end
    end

    def catch_up_to_stage stage_index
      each_card do |subcard|
        subcard.catch_up_to_stage stage_index
      end
    end

    def rename old_name, new_name
      return unless @keys.include? old_name.to_name.key
      @keys.delete old_name.to_name.key
      @keys << new_name.to_name.key
    end

    def << value
      add value
    end

    def method_missing method, *args
      return unless @keys.respond_to? method
      @keys.send method, *args
    end

    def each_card
      # fetch all cards first to avoid side effects
      # e.g. deleting a user adds follow rules and +*account to subcards
      # for deleting but deleting follow rules can remove +*account from the
      # cache if it belongs to the rule cards
      cards = @keys.map do |key|
        fetch_subcard key
      end
      cards.each do |card|
        yield(card) if card
      end
    end

    alias each each_card

    def each_with_key
      @keys.each do |key|
        card = fetch_subcard(key)
        yield(card, key) if card
      end
    end

    def []= name, card_or_attr
      case card_or_attr
      when Hash
        new_by_attributes name, card_or_attr
      when Card
        new_by_card card_or_attr
      end
    end

    def [] name
      card(name) || field(name)
    end

    def field name
      key = field_name_to_key name
      fetch_subcard key if @keys.include? key
    end

    def card name
      return unless @keys.include? name.to_name.key
      fetch_subcard name
    end

    def add_child name, args
      add prepend_plus(name), args
    end

    def remove_child name_or_card
      if name_or_card.is_a? Card
        remove name_or_card
      else
        absolute_name = @context_card.cardname.field_name(name_or_card)
        if @keys.include? absolute_name.key
          remove absolute_name
        else
          remove @context_card.cardname.relative_field_name(name_or_card)
        end
      end
    end

    alias add_field add_child
    alias remove_field remove_child

    def present?
      @keys.present?
    end

    private

    def subcard_key name_or_card
      key = case name_or_card
            when Card
              name_or_card.key
            when Symbol
              fetch_subcard(name_or_card).key
            else
              name_or_card.to_name.key
            end
      key = absolutize_subcard_name(key).key unless @keys.include?(key)
      key
    end

    def fetch_subcard key
      Card.fetch key, local_only: true, new: {}
    end

    def prepend_plus name
      case name
      when Symbol
        "+#{Card[name].name}"
      when /^\+/
        name
      else
        "+#{name}"
      end
    end

    def field_name_to_key name
      if @context_card.name =~ /^\+/
        @context_card.cardname.relative_field_name(name).key
      else
        absolute_key = @context_card.cardname.field_name(name).key
        if @keys.include? absolute_key
          absolute_key
        else
          @context_card.cardname.relative_field_name(name).key
        end
      end
    end

    # TODO: this method already exists as card instance method in
    #   tracked_attributes.rb. Find a place for it where its accessible
    #   for both. There is one important difference. The keys are symbols
    # here instead of strings
    def extract_subcard_args! args
      subcards = args.delete(:subcards) || {}
      if (subfields = args.delete(:subfields))
        subfields.each_pair do |key, value|
          subcards[cardname.field(key)] = value
        end
      end
      args.keys.each do |key|
        subcards[key] = args.delete(key) if key =~ /^\+/
      end
      subcards
    end

    def new_by_attributes name, attributes={}
      absolute_name = absolutize_subcard_name name
      if absolute_name.field_of?(@context_card.name) &&
         (absolute_name.parts.size - @context_card.cardname.parts.size) > 2
        left_card = new_by_attributes absolute_name.left
        new_by_card left_card
        left_card.new_by_attributes absolute_name, attributes
      else

        subcard_args = extract_subcard_args! attributes
        card = Card.assign_or_initialize_by absolute_name.s, attributes,
                                            local_only: true
        subcard = new_by_card card
        card.subcards.add subcard_args
        subcard
      end
    end

    def absolutize_subcard_name name
      if @context_card.name =~ /^\+/ || name.blank?
        name.to_name
      else
        name.to_name.to_absolute_name(@context_card.name)
      end
    end

    def new_by_card card
      card.supercard = @context_card
      if !card.cardname.simple? &&
         card.cardname.field_of?(@context_card.cardname)
        card.superleft = @context_card
      end
      @keys << card.key
      Card.write_to_soft_cache card
      card.director = @context_card.director.subdirectors.add(card)
      card
    end
  end

  def right_id= card_or_id
    write_card_or_id :right_id, card_or_id
  end

  def left_id= card_or_id
    write_card_or_id :left_id, card_or_id
  end

  def type_id= card_or_id
    write_card_or_id :type_id, card_or_id
  end

  def write_card_or_id attribute, card_or_id
    if card_or_id.is_a? Card
      card = card_or_id
      if card.id
        write_attribute attribute, card.id
      else
        add_subcard card
        card.director.prior_store = true
        with_id_when_exists(card) do |id|
          write_attribute attribute, id
        end
      end
    else
      write_attribute attribute, card_or_id
    end
  end

  def with_id_when_exists card, &block
    card.director.call_after_store(&block)
  end
end
