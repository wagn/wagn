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

  def add_subfield name, args
    subcards.add_field name, args
  end

  def remove_subcard name_or_card
    subcards.remove name_or_card
  end

  def remove_subfield name_or_card
    subcards.remove_field name_or_card
  end


  class Subcards

    def initialize(context_card)
      @context_card = context_card
      @keys = ::Set.new
    end

    def remove name_or_card
      case name_or_card
      when Card
        @keys.delete name_or_card.key
      when Symbol
        @keys.delete fetch_subcard(name_or_card).key
      else
        @keys.delete name_or_card.to_name.key
      end
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
          add_attributes args[:name], args
        else
          args.each_pair do |key, val|
            if val.kind_of? String
              add_attributes key, {:content => val }
            else
              add_attributes key, val
            end
          end
        end
      when Card
        add_card card_or_attr
      when Symbol
        add_attributes name, {}
      end
    end

    def << value
      add value
    end

    def extract_fields! args
      args.keys.each do |key|
        if key =~ /^\+/
          add( key => args.delete(key) )
        end
      end
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
      args_with_name  =
        case name
        when Symbol
          args.merge :name=>"+#{Card[name].key}"
        when /^\+/
          args.merge :name=>name
        else
          args.merge :name=>"+#{name}"
        end
      add args_with_name
    end

    def remove_child name_or_card
      case name
      when Symbol
        remove "+#{Card[name]}"
      when /^\+/
        remove name
      when Card
        remove name
      else
        remove "+#{name}"
      end
    end

    alias_method :add_field, :add_child
    alias_method :remove_field, :remove_child

    private

    def fetch_subcard key
      Card.fetch key, :subcard => true
    end


    def field_name_to_key name
      @context_card.cardname.field_name(name.remove /^\+/).key
    end

    def add_attributes name, attributes
      if name.kind_of? Symbol
        codename = name
        name =
          if attributes.delete(:absolute)
            Card[name].name
          else
            "+#{Card[name].name}"
          end
      end
      absolute_name = name.to_name.to_absolute_name(@context_card.name).s
      card = Card.assign_or_initialize_by absolute_name, attributes

      add_card card
    end

    def add_card card
      card.supercard = @context_card
      @keys << card.key
      Card.write_to_cache card
      card
    end
  end
end