# -*- encoding : utf-8 -*-
module Wagn
  class Cardname < String
    require 'htmlentities'


    JOINT = ?+
    BANNED_ARRAY = [ ?/, ?~, ?| ]
    BANNED_RE = /#{ ([?[] + BANNED_ARRAY << JOINT )*?\\ }#{ ?] }/
    CARDNAME_BANNED_CHARACTERS = BANNED_ARRAY * ' '

    FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "

    WORD_RE = RUBY_VERSION =~ /^1\.9/ ? '\p{Word}/' : '/\w/'

    @@name2cardname = {}

    class << self
      def new(obj)
        raise "??? #{obj.inspect}" if Card===obj
        return obj if Cardname===obj
        str = Array===obj ? obj*JOINT : obj.to_s
        return obj if obj = @@name2cardname[str]
        super str
      end
    end


    attr_reader :s, :simple, :parts, :key
    alias to_key key


    def initialize(str)
      @key = if (@s = str.to_s.strip).index(JOINT)
          @parts = @s.split(/\s*#{Regexp.escape(JOINT)}\s*/)
          @parts << '' if @s.last == JOINT
          @simple = false
          @parts.map{|p| p.to_cardname.key } * JOINT  
        else
          @parts = [@s]
          @simple = true
          @s.blank? ? '' : generate_simple_key
        end
      #@key.to_cardname if @key != @s
      @@name2cardname[@s] = self
      #warn (Rails.logger.debug "new:#{self.inspect}"); self
    end
    
    def generate_simple_key
      decode_html.underscore.gsub(/[^#{WORD_RE}\*]+/,'_').split(/_+/).reject(&:blank?).map(&:singularize)*'_'
    end
    
    def decode_html
      @decoded ||= (s.match(/\&/) ?  HTMLEntities.new.decode(s) : s)
    end
    
    alias simple? simple
    
    def inspect() "<CardName key=#{key}[#{s}, #{size}]>" end

    def self.unescape(uri) uri.gsub(' ','+').gsub('_',' ')             end

    # This probably doesn't belong here, but I wouldn't put it in string either
    def self.substitute!( str, hash )
      hash.keys.each do |var|
        str.gsub!(/\{(#{var})\}/) {|x| hash[var.to_sym]}
      end
      str
    end   

    alias to_str s
    alias to_s s
    def ==(obj)
      obj.nil? ? false :
        key == (obj.respond_to?(:to_key) ? obj.to_key :
               obj.respond_to?(:to_cardname) ? obj.to_cardname.key : obj.to_s)
    end
    def size() parts.size end

    def to_cardname() self end
    def valid?
      not (s =~ /\+$/ or parts.find {|pt| pt.match(BANNED_RE)})
    end

    #FIXME codename
    def template_name?() junction? && !!%w{*default *content}.include?(tag_name) end
    #FIXME codename
    def email_config_name?() junction? && %w{*subject *message}.include?(tag_name) end

    def replace_part( oldpart, newpart )
      oldpart = oldpart.to_cardname unless Cardname===oldpart
      newpart = newpart.to_cardname unless Cardname===newpart
      if oldpart.simple?
        simple? ? (self == oldpart ? newpart : self) :
                    parts.map{ |s| oldpart == s ? newpart.to_s : s }.to_cardname
      elsif simple?
        self
      else
        oldpart == parts[0, oldpart.size] ?
          ((self.size == oldpart.size) ? newpart :
             (newpart.parts+(parts[oldpart.size,].lines.to_a)).to_cardname) : self
      end
    end


    def tag_name()    simple? ? self : parts[-1]                       end
    def left_name()   simple? ? nil  : self.class.new(parts[0..-2])    end
    def trunk_name()  simple? ? self : self.class.new(parts[0..-2])    end
    def junction?()   not simple?                                      end
      #Rails.logger.info "trunk_name(#{to_str})[#{to_s}] #{r.to_s}"; r
    alias particle_names parts

    def module_name() s.gsub(/^\*/,'X_').gsub(/[\b\s]+/,'_').camelcase end
    def css_name() @css_name ||= key.gsub('*','X').gsub('+','-')       end

    def to_star()     star? ? s : '*'+s                                end
    def star?()       simple? and !!(s=~/^\*/)                         end
    def tag_star?()   !!((simple? ? self : parts[-1])=~/^\*/)          end
    alias rstar? tag_star?
    def star_rule(star)
      [s, (star = star.to_s) =~ /^\*/ ? star : '*'+star].to_cardname end

    def empty?()      parts && parts.empty? or s && s.blank?           end
    alias blank?      empty?

    def pre_cgi()          parts * '~plus~'                            end
    def escape()           s.gsub(' ','_')                             end

    def to_url_key()
      @url_key ||= decode_html.gsub(/[^\*#{WORD_RE}\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
    end

    def piece_names()
      simple? ? [self] : ([self] + trunk_name.piece_names + [tag_name]).uniq
    end

    def to_show(context)
      # FIXME this is not quite right.  distinction is that is leaves blank parts blank.
      (self.s =~/\b_(left|right|whole|self|user|main|\d+|L*R?)\b/) ?
         to_absolute(context) : self
    end

    def escapeHTML(args)
      args ? parts.map { |p| p =~ /^_/ and args[p] ? args[p] : p }*JOINT : self
    end

    def to_absolute_name(rel_name=nil)
      (rel_name || self.s).to_cardname.to_absolute(self)
    end

    def nth_left(n)
      (n >= size ? parts[0] : parts[0..-n-1]).to_cardname
    end

    def to_absolute(context, params=nil)
      context = context.to_cardname
      parts.map do |part|
        new_part = case part
          when /^_user$/i;            (user=Card.user_id) ? user : part
          when /^_main$/i;            Wagn::Conf[:main_name]
          when /^(_self|_whole|_)$/i; context
          when /^_left$/i;            context.trunk_name
          when /^_right$/i;           context.tag_name
          when /^_(\d+)$/i;
            pos = $~[1].to_i
            pos = context.size if pos > context.size
            context.parts[pos-1]
          when /^_(L*)(R?)$/i
            l_s, r_s = $~[1].size, $~[2].blank?
            trunk = context.nth_left(l_s)
            r= r_s ? trunk.to_s : trunk.tag_name
          when /^_/
            (params && ppart = params[part]) ? CGI.escapeHTML( ppart ) : part
          else                     part
        end.to_s.strip
        new_part.blank? ? context.to_s : new_part
      end * JOINT
    end

  end
end

