require_dependency 'chunks/chunk'

module Chunks
  class Include < Reference
    attr_reader :stars, :renderer, :options, :base
    unless defined? INCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}
      #  Groups: $1, everything (less {{}}), $2 name, $3 options
      INCLUDE_PATTERN = /\{\{(([^\|]+?)\s*(?:\|([^\}]+?))?)\}\}/
      INCLUDE_GROUPS = 3
    end

    def self.pattern() INCLUDE_PATTERN end
    def self.groups() INCLUDE_GROUPS end

    def initialize match, card_params, params
      super
      self.cardname = parse match, params
      @base = card_params[:card]
      #warn "Chunks::include #{inspect}"
      self
    end

    def parse match, params

      case name = params[1].strip

        when /^\#\#/; @unmask_text=''; nil # invisible comment
        when /^\#/||nil?||blank?; @unmask_text = "<!-- #{CGI.escapeHTML params[0]} -->"; nil

        else
          @options = {
            :tname   =>name,  # this "t" is for inclusion.  should rename
            # it is sort of include, this is the name for the inclusion, should still rename
            :view  => nil, :item  => nil, :type  => nil, :size  => nil,
            :hide  => nil, :show  => nil, :wild  => nil,
            :include => params[0] # is this used? yes, by including this in an attrbute
                              # of an xml card, the xml parser can replace the subelements
                              # with the original inclusion notation: {{options[:include]}}
          }

          @configs = Hash.new_from_semicolon_attr_list params[2]

          @options[:style] = @configs.inject({}) do |styles, pair| key, value = pair
            @options.key?(key.to_sym) ? @options[key.to_sym] = value : styles[key] = value
            styles
          end.
            map { |style_name,style| CGI.escapeHTML("#{style_name}:#{style};") } * ''

          [:hide, :show].each do |disp|
            @options[disp] = @options[disp].split(/[\s\,]+/) if @options[disp]
          end
          name
      end
    end

    def unmask_text
      return @unmask_text if @unmask_text

      refcardname
      if view = @options[:view]
        view = view.to_sym
      end

      @unmask_render = yield options # this is not necessarily text, sometimes objects for json

      #Rails.logger.warn "unmask txt #{@unmask_render}, #{options.inspect}"; @unmask_render
    end

    def replace_reference old_name, new_name

      @cardname=@cardname.replace_part old_name, new_name

      ( configs = @configs.to_semicolon_attr_list ).blank? or
        configs = "|" + configs
      @text = '{{' + cardname.to_s + configs + '}}'
    end

  end
end
