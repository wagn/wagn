# -*- encoding : utf-8 -*-

# API to create/update additional cards together with the main card.
# The most common case is for fields. For example toghether with "my address" you want to create the subcards "my address+name", "my address+street", etc.
# Subcards don't have to be descendants.

# Subcards can be added as card objects or attribute hashes.
# To turn all subcards into card objects call #process


class Card

  def subcard field_name
    subcards.field field_name
  end

  def add_subcard name, args
    add_field name, args
  end

  def remove_subcard name
  end

  def subcards
    @subcards ||= Subcards.new
  end

  class Subcards

    attr_reader :context_card
    # A subcard that is either a card object or a hash of attributes
    class Satellite
      def initialize orbit, card_or_attr
        @orbit = orbit
        case card_or_attr
        when Hash
          @attributes = card_or_attr
        when Card
          @card = card_or_attr
        else
          raise Card::Error, "wrong argument; satellite needs a card object or hash"
        end

      end

      def context_card
        @context_card ||= @orbit.context_card
      end

      def attributes
        if @card
          @card.attributes.symbolize_keys
        else
          @attributes
        end
      end

      def absolute_key
        if @card
          @card.key.to_name.to_absolute_name(context_card.name).key
        else

        end
      end

      def process &block
        if @card
          ab_key = @card.key.to_name.to_absolute_name(context_card.name).key
          if !block_given? || block.call(ab_key, @card.attributes.symbolize_keys)
            @card.supercard = context_card
          else
            @cards[key] = nil
          end
        else
        end
      end

      def card
      end

      def field name

      end

    end

    # subcard.field(:account).add_field

    # processing_mode: defines what happens when subcard objects are used before #process was called
    # :lazy = don't process; use only subcards that were added as card objects
    # :whiny = raise exception
    # :implizit = process all subcards
    def initialize(processing_mode=:lazy, context_card=nil)
      @processed = false
      @cards = {}
      @attributes = {}
      @processing_mode = processing_mode
      @context_card = context_card
      if @processing_mode == :implizit && !@context_card
        raise Card::Error, "context card is needed for implizit processing"
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
          args.keys.each_pair do |key, val|
            if val.kind_of? String
              add_attributes key, {:content => val }
            else
              add_attributes key, val
            end
          end
        end
      when Card
        add_card card_or_attr
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
      if @cards.respond_to? method
        ensure_processed
        @cards.send method, *args
      end
    end

    def each_card
      ensure_processed
      @cards.each_value do |card|
        yield(card)
      end
    end

    def each_with_key
      ensure_processed
      @cards.each_pair do |card, key|
        yield(card, key)
      end
    end

    def []= name, card_or_attr
      key = name.to_name.key
      if @cards[key]
        case card_or_attr
        when Hash
          @cards[key].assign_attributes card_or_attr
        when Card
          @cards[key] = card_or_attr
        end
      elsif @attributes[key]
        case card_or_attr
        when Hash
          @attributes[key]
        when Card
        end
      end

      add attributes.reverse_merge(:name=>name)
    end

    def [] name
      key = name.to_name.key
      @cards[key] || @attributes[key]
    end

    def field name
      self[field_name_to_key]
    end

    def card name
      ensure_processed
      @cards[name.to_name.key]
    end

    def add_child name, args, &block
      args_with_name  =
        case name
        when Symbol
          args.merge :name=>"+#{Card[name].key}"
        when /^\+/
          args.merge :name=>name
        else
          args.merge :name=>"+#{name}"
        end
      add args_with_name, &block
    end

    alias_method :add_field, :add_child

    # process subcard only if block returns true

    def process_if context_card, &block
      if @processed
        raise Card::Error, "subcards processed twice"
      end
      @context_card = context_card

      @satellites.each do |key, sat|
        #ab_key = key.to_name.to_absolute_name(context_card.name).key
        if !block_given? || block.call(sat.absolute_key, sat.attributes)
          sat.process
        end
      end

      @cards.each_pair do |key, card|
        ab_key = key.to_name.to_absolute_name(context_card.name).key
        if !block_given? || block.call(ab_key, card.attributes.symbolize_keys)
          card.supercard = context_card
        else
          @cards[key] = nil
        end
      end

      @attributes.each_pair do |key, opts|
        ab_name = opts[:name].to_name.to_absolute_name context_card.name
        if !block_given? || block.call(ab_name.key, opts)
          opts[:supercard] = context_card
          # opts['subcards'] = extract_subcard_args! opts # this shouldn't be neccessary because it is handled in assign_attributes

          subcard = assign_or_initialize_by ab_name, opts  # WARNING: old code initizalized with relative name (like "+status")
          # don't know if that makes a difference

          if subcard
            @cards[key] = subcard
          else
            @cards.delete sub_name
          end
        end
      end
      @processed = true
    end

    def process context_card
      process_if(context_card)
    end

    private

    def field_name_to_key name
      case name
      when Symbol
        "+#{Card[name].key}"
      when /^\+/
        name.to_name.key
      else
        "+#{name.to_name.key}"
      end
    end

    def ensure_processed
      if !@processed
        case @processing_mode
        when :whiny
          raise Card::Error "subcard object requested before subcards are processed"
        when :implizt
          proccess @context_card
        end
      end
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
      absolute_name = name.to_name.to_absolute_name(@context_card.name)
      attributes[:name] ||= absolute_name
      attributes[:supercard] = @context_card
      card = Card.assign_or_initialize_by attributes

      if codename
        @cards[codename] = card
      end
      @cards[name.to_name.key] = card
    end

    def add_card card
      card.supercard = @context_card
      @cards[card.key] = card
      if card.codename
        @cards[card.codename] = card
      end
    end
  end
end