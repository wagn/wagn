class Card
  def success
    Env[:controller].success
  end

  class Success
    include Card::Format::Location
    include Card::HtmlFormat::Location

    attr_accessor :params, :redirect
    attr_reader   :target, :id, :name

    def initialize name_context=nil, previous_location='/', success_params=nil
      @name_context = name_context
      @previous_location = previous_location
      @new_args = {}
      @params = OpenStruct.new
      case success_params
      when Hash
        apply(success_params)
      when /^REDIRECT:\s*(.+)/
        @redirect=true
        self.target = $1
      when nil  ;  self.name = '_self'
      else      ;  self.target = success_params
      end
    end


    def << value
      case value
      when Hash ; apply value
      else      ; self.target = value
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
      when Integer   ; self.id     = value
      when String    ; self.name   = value
      when Card      ; self.card   = value
      else           ; self.target = value
      end
    end

    def id= id
      self.mark = id
    end

    def name= name
      @name   = name
    end

    def type= type
      @new_args[:type] = type
    end

    def content= content
      @new_args[:content] = content
    end

    def card= card
      @card   = card
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
        else                        ;  self.mark = value
        end
    end

    def redirect= value
      @redirect = value
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
        Card.fetch @name.to_name.to_absolute(@name_context), :new=>@new_args
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
        page_path card.cardname, params
      else
        target
      end
    end

    def method_missing method, *args
      case method
      when /^(\w+)=$/
        self[$1.to_sym] = args[0]
      when /^(\w+)$/
        self.params[$1.to_sym]
      else
        super
      end
    end
  end
end