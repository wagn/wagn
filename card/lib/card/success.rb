class Card
  class Success
    include Card::Location

    attr_accessor :params, :redirect, :id, :name, :card, :name_context

    def initialize name_context=nil, success_params=nil
      @name_context = name_context
      @new_args = {}
      @params = OpenStruct.new
      case success_params
      when Hash
        apply(success_params)
      when nil then  self.name = "_self"
      else;  self.target = success_params
      end
    end

    def << value
      case value
      when Hash then apply value
      else; self.target = value
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
      when Integer then @id = value
      when String then @name = value
      when Card then @card = value
      else; self.target = value
      end
    end

    def id= id
      self.mark = id  # for backwards compatibility use mark here: id was often used for the card name
    end

    def type= type
      @new_args[:type] = type
    end

    def content= content
      @new_args[:content] = content
    end

    def target= value
      @id = @name = @card = nil
      @target = process_target value
    end

    def process_target value
      case value
      when ""                     then ""
      when "*previous", :previous then :previous
      when /^(http|\/)/           then value
      when /^TEXT:\s*(.+)/        then  Regexp.last_match(1)
      when /^REDIRECT:\s*(.+)/
        @redirect = true
        process_target Regexp.last_match(1)
      else self.mark = value
      end
    end

    def apply args
      args.each_pair do |key, value|
        self[key] = value
      end
    end

    def card name_context=@name_context
      if @card
        @card
      elsif @id
        Card.find @id
      elsif @name
        Card.fetch @name.to_name.to_absolute(name_context), new: @new_args
      end
    end

    def target name_context=@name_context
      card(name_context) || (@target == :previous ? Card::Env.previous_location : @target) || Card.fetch(name_context)
    end

    def []= key, value
      if respond_to? "#{key}="
        send "#{key}=", value
      elsif key.to_sym == :soft_redirect
        @redirect = :soft
      else
        @params.send "#{key}=", value
      end
    end

    def [] key
      if respond_to? key.to_sym
        send key.to_sym
      elsif key.to_sym == :soft_redirect
        @redirect == :soft
      else
        @params.send key.to_sym
      end
    end

    def params
      @params.marshal_dump
    end

    def to_url name_context=@name_context
      case (target = target(name_context))
      when Card
        page_path target.cardname, params
      else
        target
      end
    end

    def method_missing method, *args
      case method
      when /^(\w+)=$/
        self[Regexp.last_match(1).to_sym] = args[0]
      when /^(\w+)$/
        self[Regexp.last_match(1).to_sym]
      else
        super
      end
    end

    def session
      Card::Env.session
    end
  end
end
