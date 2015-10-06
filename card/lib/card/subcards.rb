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
  end

  def preserve_subcards
    if subcards.present?
      Card.cache.write_local subcards_cache_key, @subcards
    end
  end

  def restore_subcards
    if (cached_subcards = Card.cache.read_local(subcards_cache_key))
      @subcards = cached_subcards
    end
  end

  def expire_subcards
    Card.cache.delete_local subcards_cache_key
  end

  def subcards_cache_key
    "#{key}#SUBCARDS#"
  end

  class Subcards
    attr_accessor :context_card, :keys
    def initialize context_card
      @context_card = context_card
      @keys = ::Set.new
    end

    def remove name_or_card
      key = case name_or_card
            when Card
              name_or_card.key
            when Symbol
              fetch_subcard(name_or_card).key
            else
              name_or_card.to_name.key
            end

      @keys.include? key && @keys.delete(key)
    end

    def add name_or_card_or_attr, card_or_attr = nil
      if card_or_attr
        name = name_or_card_or_attr
      else
        card_or_attr = name_or_card_or_attr
      end
      case card_or_attr
      when Hash
        args = card_or_attr
        if name
          add_attributes name, args
        elsif args[:name]
          add_attributes args.delete(:name), args
        else
          args.each_pair do |key, val|
            if val.is_a? String
              add_attributes key, content: val
            else
              add_attributes key, val
            end
          end
        end
      when Card
        add_card card_or_attr
      when Symbol, String
        add_attributes card_or_attr, {}
      end
    end

    def << value
      add value
    end

    def method_missing method, *args
      if @keys.respond_to? method
        @keys.send method, *args
      end
    end

    def each_card
      @keys.each do |key|
        card = fetch_subcard key
        yield(card) if card
      end
    end

    alias_method :each, :each_card

    def each_with_key
      @keys.each do |key|
        card = fetch_subcard(key)
        yield(card, key) if card
      end
    end

    def []= name, card_or_attr
      case card_or_attr
      when Hash
        add_attributes name, card_or_attr
      when Card
        add_card name, card_or_attr
      end
    end

    def [] name
      card name
    end

    def field name
      key = field_name_to_key name
      if @keys.include? key
        fetch_subcard key
      end
    end

    def card name
      if @keys.include? name.to_name.key
        fetch_subcard name
      end
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

    alias_method :add_field, :add_child
    alias_method :remove_field, :remove_child

    def present?
      @keys.present?
    end

    private

    def fetch_subcard key
      Card.fetch key, subcard: true, local_only: true
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

    def add_attributes name, attributes = {}
      absolute_name =
        if @context_card.name =~ /^\+/
          name.to_name
        else
          name.to_name.to_absolute_name(@context_card.name)
        end

      if absolute_name.is_a_field_of?(@context_card.name) &&
         (absolute_name.parts.size - @context_card.cardname.parts.size) > 2
        left_card = add_attributes absolute_name.left
        add_card left_card
        left_card.add_attributes absolute_name, attributes
      else
        card = Card.assign_or_initialize_by absolute_name.s, attributes,
                                            local_only: true
        add_card card
      end


    end

    def add_card card
      card.supercard = @context_card
      if !card.cardname.simple? &&
         card.cardname.is_a_field_of?(@context_card.cardname)
        card.superleft = @context_card
      end
      @keys << card.key
      Card.write_to_local_cache card
      card
    end
  end
end
