# -*- encoding : utf-8 -*-

# API to create/update/delete additional cards together with the main card.
# The most common case is for fields. For example toghether with "my address" you want to create the subcards "my address+name", "my address+street", etc. but subcards don't have to be descendants.

# Subcards can be added as card objects or attribute hashes.



class Card
  def subcards
    @subcards ||= Subcards.new(self)
  end

  def field tag
    Card[cardname.field(tag)]
  end

  def subcard card_name
    subcards.card card_name
  end

  def subfield field_name
    subcards.field field_name
  end

  def add_subcard name_or_card, args=nil
    subcards.add name_or_card, args
  end

  def add_subfield name, args=nil
    subcards.add_field name, args
  end

  def remove_subcard name_or_card
    subcards.remove name_or_card
  end

  def remove_subfield name_or_card
    subcards.remove_field name_or_card
  end

  def preserve_subcards
    if subcards.present?
      Card::Cache[Card::Subcards].write key, @subcards
    end
  end

  def restore_subcards
    if Card::Cache[Card::Subcards].exist? key
      @subcards = Card::Cache[Card::Subcards].fetch key
    end
  end

  def expire_subcards
    Card::Cache[Card::Subcards].delete key
  end


  class Subcards

    def initialize(context_card)
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
          add_attributes name, args
        elsif args[:name]
          add_attributes args.delete(:name), args
        else
          args.each_pair do |key, val|
            if val.kind_of? String
              add_attributes key, :content => val
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
        yield(fetch_subcard key)
      end
    end

    alias_method :each, :each_card

    def each_with_key
      @keys.each do |key|
        yield(fetch_subcard(key), key)
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
      if name_or_card.kind_of? Card
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
      Card.fetch key, :subcard => true
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

    def add_attributes name, attributes={}
      absolute_name =
        if @context_card.name =~ /^\+/
          name
        else
          name.to_name.to_absolute_name(@context_card.name).s
        end
      card = Card.assign_or_initialize_by absolute_name, attributes
      add_card card
    end

    def add_card card
      card.supercard = @context_card
      if !card.cardname.simple? && card.cardname.is_a_field_of?(@context_card.cardname)
        card.superleft = @context_card
      end
      @keys << card.key
      Card.write_to_cache card
      card
    end
  end
end