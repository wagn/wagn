# encoding: utf-8
module Wagn
  class Cardname < Object
    require 'htmlentities'

    NAME2CARDNAME = {}

    JOINT = '+'
    BANNED_ARRAY = [ '/', '~', '|']
    BANNED_RE = /#{'[\\'+JOINT+'\\'+BANNED_ARRAY*"\\"+']'}/
    CARDNAME_BANNED_CHARACTERS = BANNED_ARRAY * ' '

    FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "


    class << self
      def new(obj)
        return obj if Cardname===obj
        str = Array===obj ? obj*JOINT : obj.to_s
#        raise "name error #{str}" if str[0] == '/'
        return obj if obj = NAME2CARDNAME[str]
        super str
      end

      def each_cardname(&proc) NAME2CARDNAME.values.uniq.each(&proc) end
      def each_key(&proc) each_cardname.map(&:key).each(&proc) end
    end


    attr_reader :s, :simple, :parts, :key
    alias to_key key


    def initialize(str)
      @key = if (@s = str.to_s).index(JOINT)
          @parts = @s.gsub(/\+$/,'+ ').split(JOINT)
          @simple = false
          @parts.map{|p| p.to_cardname.key } * JOINT  
        else
          @parts = [@s]
          @simple = true
          @s.blank? ? '' : generate_simple_key
        end
      #@key.to_cardname if @key != @s
      NAME2CARDNAME[@s] = self
      Rails.logger.debug "new:#{self.inspect}"; self
    end
    
    def generate_simple_key
      decode_html.underscore.gsub(/[^\p{Word}\*]+/,'_').split(/_+/).reject(&:blank?).map(&:singularize)*'_'
    end

    def decode_html
      @decoded ||= (s.match(/\&/) ?  HTMLEntities.new.decode(s) : s)
    end

    
    alias simple? simple
=begin
    def simple?
      @simple ||= !s.index(JOINT)
    end
    
    def parts
      @parts ||= (simple ? [s] : s.gsub(/\+$/,'+ ').split(JOINT))
    end
=end
    
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


    def valid_cardname?() not parts.find {|pt| pt.match(BANNED_RE)} end

    #FIXME codename
    def template_name?() junction? && !!%w{*default *content}.include?(tag_name) end
    #FIXME codename
    def email_config_name?() junction? && %w{*subject *message}.include?(tag_name) end

    def replace_part( oldpart, newpart )
      oldpart = oldpart.to_cardname unless Cardname===oldpart
      newpart = newpart.to_cardname unless Cardname===newpart
      if oldpart.simple?
        simple? ? (self == oldpart ? newpart : self) :
                    parts.map{ |s| oldpart == s ? newpart : s }.to_cardname
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
    def css_name() key.gsub('*','X').gsub('+','-')                     end

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
      @url_key ||= decode_html.gsub(/[^\*\p{Word}\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
    end

    def piece_names()
      simple? ? [self] : ([self] + trunk_name.piece_names + [tag_name]).uniq
    end

    def to_show(absolute)
      (self =~/\b_(left|right|whole|self|user|\d+|L*R?)\b/) ?
         to_absolute(absolute) : self
    end

    def escapeHTML(args)
      args ? parts.map { |p| p =~ /^_/ and args[p] ? args[p] : p }*JOINT : self
    end

    def fullname(context, base, args, params)
      context = case
          when base; (base.respond_to?(:cardname) ? base.cardname :
                      base.respond_to?(:name) ? base.name : base)
          when args[:base]=='parent'; context.left_name
          else context
          end.to_cardname
      #Rails.logger.info "fullname s(#{inspect}, #{context.inspect}, #{base.inspect}, #{args.inspect}) P:#{params.inspect}"
      to_absolute( context||self, params )
    end

    def to_absolute_name(rel_name=nil)
      (rel_name || self.s).to_cardname.to_absolute(self)
    end

    def nth_left(n)
      (n >= size ? parts[0] : parts[0..-n-1]).to_cardname
    end

    def to_absolute(context, params=nil)
      context = context.to_cardname
      #Rails.logger.info "to_absolute(#{inspect}, #{context.inspect}, #{params.inspect}) T:#{Kernel.caller[0,8]*"\n"}"
      parts.map do |part|
        #Rails.logger.info "to_abs part(#{part}) #{!!(part =~ /^_/)}, #{params&&params[part]}"
        new_part = case part
          when /^_user$/i;  (user=User.current_user) ? user.cardname : part
          when /^(_self|_whole|_)$/i; context
        #Rails.logger.info "to_abs _self(#{context.inspect})"; context
          when /^_left$/i;            context.trunk_name
        #Rails.logger.info "to_abs _left(#{context.trunk_name.inspect})"; context.trunk_name
          when /^_right$/i;           context.tag_name
        #Rails.logger.info "to_abs _right(#{context.tag_name.inspect})"; context.tag_name
          when /^_(\d+)$/i;
            pos = $~[1].to_i
            pos = context.size if pos > context.size
            #Rails.logger.info "to_abs Dig(#{pos}) #{context.parts.inspect}"
            context.parts[pos-1]
          when /^_(L*)(R?)$/i
            l_s, r_s = $~[1].size, $~[2].blank?
            trunk = context.nth_left(l_s)
            r= r_s ? trunk.to_s : trunk.tag_name
            #Rails.logger.debug "_LR(#{l_s}, #{r_s}) TR:#{trunk}, R:#{r}"; r
          when /^_/
            (params && ppart = params[part]) ? CGI.escapeHTML( ppart ) : part
          else                     part
        end.to_s.strip
        new_part.blank? ? context.to_s : new_part
      end * JOINT
    end

  end
end

