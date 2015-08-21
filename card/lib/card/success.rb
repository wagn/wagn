class Card
  class Success
    include Card::Format::Location
    include Card::HtmlFormat::Location

    attr_accessor :params, :redirect
    attr_reader   :target, :id, :name

    def initialize name_context, previous_location, success_params=nil
      @name_context = name_context
      @previous_location = previous_location
      @params = OpenStruct.new

      case success_params
      when Hash
        apply(success_params)
      when /^REDIRECT:\s*(.+)/
        @redirect=true
        target = $1
      when nil  ;  @name = '_self'
      else      ;  target = success_params
      end
    end


    def << value
      case value
      when Hash ; apply value
      else      ; target = value
      end
    end

    def hard_redirect?
      @redirect == true
    end

    # reset card object and override params with success params
    def soft_redirect?
      @redirect == :soft
    end

    def mark= value
      case value
      when Integer   ; id   = value
      when String    ; name = value
      when Card      ; card = value
      else           ; target = value
      end
    end

    def id= id
      @id     = id
      @target = id
    end

    def name= name
      @name   = name
      @target = name
    end

    def card= card
      @card   = card
      @target = card
      @id     = card.id
      @name   = card.name
    end

    def target= value
      @target =
        case value
        when '*previous', :previous ; @previous_location
        when /^(http|\/)/           ;  value
        when /^TEXT:\s*(.+)/        ;  $1
        when ''                     ;  ''
        else                        ;  mark = value
        end
    end

    def apply args
      args.each_pair do |key, value|
        self[key] = value
      end
    end

    def card
      if @card
        @card
      elsif @id
        Card.find @id
      elsif @name
        Card.fetch @name.to_name.to_absolute(@name_context), :new=>{}
      end
    end

    def target
      card || @target
    end

    def []= key, value
      unless try "#{key}=", value
        if key.to_sym == :soft_redirect
          @redirect = :soft
        else
          @params[key] = value
        end
      end
    end

    def params
      @params.to_h
    end

    def to_url
      if card
        page_path card.cardname, @params
      else
        target
      end
    end

  end
end