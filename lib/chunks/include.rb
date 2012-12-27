require 'chunks/chunk'

module Chunks
  class Include < Reference
    attr_reader :stars, :renderer, :options, :base
    unless defined? INCLUDE_PATTERN
      #  {{+name|attr:val;attr:val;attr:val}}
      INCLUDE_PATTERN = /\{\{(([^\|]+?)\s*(\|([^\}]+?))?)\}\}/
    end

    def self.pattern() INCLUDE_PATTERN end

    def initialize(match_data, content)
      super
      #Rails.logger.warn "FOUND INCLUDE #{match_data} #{content}"
      self.cardname, @options, @configs = a = self.class.parse(match_data)
      #Rails.logger.info "Chunks::Include #{a.inspect}"
      @base, @renderer = content.card, content.renderer
    end

    def self.parse(match)
      name = match[2].strip
      case name
      when /^\#\#/; return [nil, {:comment=>''}] # invisible comment
      when /^\#/||nil?||blank?  # visible comment
        return [nil, {:comment=>"<!-- #{CGI.escapeHTML match[1]} -->"}]
      end
      options = {
        :tname   =>name,  # this "t" is for inclusion.  should rename

        :view  => nil,
        :item  => nil,
        :type  => nil,
        :size  => nil,

        :hide  => nil,
        :show  => nil,
        :wild  => nil,

        :unmask => match[1] # is this used?
      }
      style = {}
      configs = Hash.new_from_semicolon_attr_list match[4]
      configs.each_pair do |key, value|
        if options.key? key.to_sym
          options[key.to_sym] = value
        else
          style[key] = value
        end
      end
      [:hide, :show].each do |disp|
        if options[disp]
          options[disp] = options[disp].split /[\s\,]+/
        end
      end
      options[:style] = style.map{|k,v| CGI.escapeHTML("#{k}:#{v};")}.join
      [name, options, configs]
    end

    def unmask_text(&block)
      return @unmask_text if @unmask_text
      comment = @options[:comment]
      return comment if comment
      refcardname
      if view = @options[:view]
        view = view.to_sym
      end
      yield options
    end

    def revert
      configs = @configs.to_semicolon_attr_list;
      configs = "|#{configs}" unless configs.blank?
      @text = "{{#{cardname.to_s}#{configs}}}"
      super
    end

  end
end
