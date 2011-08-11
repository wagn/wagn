module Wagn
  class Cardname < Object

    CARDNAMES = {}
    require 'htmlentities'

    def self.decode_html(simple)
      simple.match(/\&/) ?  HTMLEntities.new.decode(simple) : simple
    end

    def self.simple_to_key(simple)
      Wagn::Cardname.decode_html(simple).underscore.gsub(/[^\w\*]+/,'_').
        split(/_+/).reject(&:blank?).map(&:singularize)*'_'
      #r=;Rails.logger.debug "simple_to_key[#{simple}] = #{r.inspect}"; r
    end

    JOINT = '+'
    BANNED_ARRAY = [ '/', '~', '|']
    BANNED_RE = /#{'[\\'+JOINT+'\\'+BANNED_ARRAY*"\\"+']'}/
    CARDNAME_BANNED_CHARACTERS = BANNED_ARRAY * ' ' 

    FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "

    attr_reader :s, :simple, :parts, :key

    def self.new(obj)
      return obj if Cardname===obj
      raise "cardname? #{obj.inspect}" if obj.nil?
      name = Array===obj ? obj*JOINT : obj.to_s
      if CARDNAMES.has_key?(name)
        #Rails.logger.info "cardname.cache(#{name}) #{CARDNAMES[name].inspect}"
        CARDNAMES[name]
      else
        newobj= allocate.send(:initialize, name)
        #Rails.logger.info "cardname.new(#{obj.class}) #{newobj.inspect}" # CDNS:#{CARDNAMES.keys.inspect}"
        #newobj.send(:initialize, name)
        # should we stop it from even creating bad names?
        #raise "Bad name #{newobj.s}" if newobj.simple? and newobj.s.match(BANNED_RE)
        CARDNAMES[name] = newobj
      end
    end

    def initialize(obj)
      #@simple = @key = @parts = @s = nil
      raise "???" unless String===obj
      #Rails.logger.debug "newcdnm(#{obj.inspect})" #{Kernel.caller[0..4]*"\n"}"
      #case obj
      #when Cardname;
        #@simple, @s, @parts, @key = obj.simple, obj.s, obj.parts, obj.key
        #(has_s=obj.instance_variable_get(:@s)) ? @s=has_s : @parts=obj.parts
      #Rails.logger.info "newcdnm <cdnm>#{self.class} #{s}: #{self.simple?}, #{self.s.inspect}, #{self.parts.inspect}"
        #return self
      #when Symbol;
      #  @s=obj.to_s
      #when String;          
        @s=obj.strip
      #when Enumerable;                      @parts = obj.map(&:to_s).to_a
      #else raise "Bad cardname #{obj.inspect} #{Kernel.caller[0..10]*"\n"}"
      #end
      #if s
        @parts=(@simple = !s.index(JOINT)) ? [s] : s.gsub(/\+$/,'+ ').split(JOINT)
        #Rails.logger.debug "by_s#{s.inspect} > #{simple.inspect}, #{parts.inspect}"
      #else
      #  raise "Card parts? #{parts.inspect}" if Wagn::Cardname === parts[0]
      #  @s    =(@simple = size == 1)      ?  parts[0] : parts * JOINT
        #Rails.logger.debug "by_parts#{parts.inspect} > #{simple.inspect}, #{s.inspect}"
      #end
      #Rails.logger.info "newcdnm R>#{inspect}: S:#{self.s.inspect}, P:#{self.parts.inspect}"
      #Rails.logger.info "newcdnm R> S:#{self.inspect}, K:#{self.key} P:#{self.parts.inspect}"
      self
    end

    def key()
      @key ||= simple? ? Wagn::Cardname.simple_to_key(s) :
        parts.map(&:to_cardname).reject(&:blank?).map(&:key) * JOINT
    end
    alias to_key key

    def inspect()
      "S(#{simple.inspect})#{(simple or simple.nil?) ? s.inspect : parts.inspect}"
    end
    alias to_str s
    alias to_s s
    alias simple? simple
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
        #Rails.logger.info "replace_part #{oldpart == parts[0, oldpart.size]} ? #{newpart.size == oldpart.size} ? #{newpart.inspect} : #{newpart.parts.inspect} #{parts[oldpart.size,].inspect}"
        #Rails.logger.info "replace_part #{oldpart == parts[0, oldpart.size]} ? #{newpart.size == oldpart.size} ? #{newpart.inspect} : #{(newpart.parts+(parts[oldpart.size].to_a)).inspect}"; r=(
        oldpart == parts[0, oldpart.size] ?
          ((newpart.size == oldpart.size) ? newpart :
                      (newpart.parts+parts[oldpart.size,].to_a).to_cardname) : self
        #);Rails.logger.info "replace_part notsimp #{oldpart.inspect}, #{newpart.inspect} > #{r.inspect}"; r
      end
    end


    def tag_name()    simple? ? self : parts[-1]                       end
    def junction?()   not simple?                                      end
    def tripple?()    size > 2                                         end
    def left_name()   simple? ? nil  : self.class.new(parts[0..-2])    end
    def trunk_name()  simple? ? self : self.class.new(parts[0..-2])    end
      #Rails.logger.info "trunk_name(#{to_str})[#{to_s}] #{r.to_s}"; r
    alias particle_names parts

    def module_name() s.gsub(/^\*/,'X_').gsub(/[\b\s]+/,'_').camelcase end
    def css_name() key.gsub('*','X').gsub('+','-')                     end
    def to_star()     star? ? s : '*'+s                                end
    def star?()       simple? and !!(s=~/^\*/)                         end
    def tag_star?()   !!((simple? ? self : parts[-1])=~/^\*/)          end
    def empty?()      parts && parts.empty? or s && s.blank?           end
    alias blank?      empty?

    def pre_cgi()          parts * '~plus~'                            end
    def escape()           s.gsub(' ','_')                             end
    def self.unescape(uri) uri.gsub(' ','+').gsub('_',' ')             end

    # This probably doesn't belong here, but I wouldn't put it in string either
    def self.substitute!( str, hash )
      hash.keys.each do |var|
        str.gsub!(/\{(#{var})\}/) {|x| hash[var.to_sym]}
      end
      str
    end   

    def to_url_key()
      Wagn::Cardname.decode_html(s).gsub(/[^\*\w\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
    end

    def piece_names()
      simple? ? [self] : ([self] + trunk_name.piece_names + [tag_name]).uniq
    end

    def to_show(absolute)
      (self =~/\b_(left|right|whole|self|user|\d+|L*R?)\b/) ?
         _to_absolute(absolute) : self
    end

    def escapeHTML(args)
      args ? parts.map { |p| p =~ /^_/ and args[p] ? args[p] : p }*JOINT : self
    end

    def fullname(context, base, args)
      #Rails.logger.info "fullname s(#{inspect}, #{context.inspect}, #{base.inspect}, #{args.inspect})"
      context = case
          when base; (base.respond_to?(:cardname) ? base.cardname :
                      base.respond_to?(:name) ? base.name : base)
          when args[:base]=='parent'; context.left_name
          else context
          end
      #r= context and context.to_cardname.to_absolute( (context||self).escapeHTML(args) )
      r= to_absolute( context||self )    #.escapeHTML(args)
      #Rails.logger.info "fullname(#{inspect}, #{context}, esc:#{context.escapeHTML(args).inspect}, Args:#{args.inspect})\nR=#{r.inspect}"; r
    end

    def to_absolute_cardname(context=nil)
      context = context ? self.class.new(context.gsub('~plus~','+')) : self
      _to_absolute(context).to_cardname
    end

    def nth_left(n)
      (n >= size ? parts[0] : parts[0..-n-1]).to_cardname
    end

    def to_absolute(context) _to_absolute(context).to_s end
    #def strip() s==s.strip ? s : initialize(s) end
    def _to_absolute(context)
      context = context.to_cardname
      #Rails.logger.info "_to_absolute(#{context.inspect}) #{self}"
      # Trailing + won't give a last part if it is empty.
      #pts = s =~ /\+$/ ? parts : (s+' ').to_cardname.parts
      #Rails.logger.info "_to_absolute(#{inspect}, #{context.inspect}) #{pts.inspect}"
      parts.map do |part|
        #Rails.logger.info "to_abs part(#{part.s.inspect})"
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
          else                     part
        end.to_s.strip
        new_part.blank? ? context.to_s : new_part
      end * JOINT #.to_cardname
    end
  end
end

