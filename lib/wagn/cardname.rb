# -*- encoding : utf-8 -*-
module Wagn
  class Cardname < Object
    require 'htmlentities'

    JOINT = '+'
    BANNED_ARRAY = [ '/', '~', '|' ]
    BANNED_RE = /#{ (['['] + BANNED_ARRAY << JOINT )*'\\' }]/
    CARDNAME_BANNED_CHARACTERS = BANNED_ARRAY * ' '

    FORMAL_JOINT = " <span class=\"wiki-joint\">#{JOINT}</span> "

    RUBY19 = RUBY_VERSION =~ /^1\.9/
    WORD_RE = RUBY19 ? '\p{Word}/' : '/\w/'
    RELATIVE_RE = /\b_(left|right|whole|self|user|main|\d+|L*R?)\b/

    @@name2cardname = {}

    class << self
      def new obj
        return obj if Cardname===obj
        str = Array===obj ? obj*JOINT : obj.to_s
        return obj if obj = @@name2cardname[str]
        super str.strip
      end
      
      def unescape uri
        # key doesn't resolve correctly in unescaped form 
        # dislike this unescaping anyway.
        uri.gsub(' ','+').gsub '_',' '
      end
      
      def substitute! str, hash
        # This probably doesn't belong here, but I wouldn't put it in string either
        ## shouldn't thus use inclusions???
        hash.keys.each do |var|
          str.gsub!(/\{(#{var})\}/) {|x| hash[var.to_sym]}
        end
        str
      end
    end


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~ INSTANCE ~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    attr_reader :simple, :parts, :key, :s
    alias to_key key
    alias to_s s

    def initialize str
      @s = str.to_s.strip
      @s = @s.encode('UTF-8') if RUBY19
      @key = if @s.index(JOINT)
          @parts = @s.split(/\s*#{Regexp.escape(JOINT)}\s*/)
          @parts << '' if @s.last == JOINT
          @simple = false
          @parts.map { |p| p.to_cardname.key } * JOINT  
        else
          @parts = [str]
          @simple = true
          str.blank? ? '' : simple_key
        end
      @@name2cardname[str] = self
    end
    
    def to_cardname()    self                                           end
    def valid?()         not parts.find { |pt| pt.match BANNED_RE }     end
    def size()           parts.size                                     end # size of name = number of parts??  not intuitive.    
    def blank?()         s.blank?                                       end
    alias empty? blank?

    def inspect
      "<CardName key=#{key}[#{self}, #{@parts ? @parts.size : 'no size?'}]>"
    end

    def == obj
      object_key = case
        when obj.respond_to?(:to_key)      ; obj.to_key
        when obj.respond_to?(:to_cardname) ; obj.to_cardname.key
        else                               ; obj.to_s
        end
      object_key == key        
    end


    #~~~~~~~~~~~~~~~~~~~ VARIANTS ~~~~~~~~~~~~~~~~~~~
    
    def simple_key
      decoded.underscore.gsub(/[^#{WORD_RE}\*]+/,'_').split(/_+/).reject(&:blank?).map(&:singularize)*'_'
    end
    
    def url_key
      @url_key ||= decoded.gsub(/[^\*#{WORD_RE}\s\+]/,' ').strip.gsub(/[\s\_]+/,'_')
    end
    
    def css_name
      @css_name ||= key.gsub('*','X').gsub '+','-'
    end
    
    def pre_cgi
      parts.join '~plus~'
    end
    
    def escape
      s.gsub ' ', '_'
    end
    
    def decoded
      @decoded ||= (s.index('&') ?  HTMLEntities.new.decode(s) : s)
    end
        

    #~~~~~~~~~~~~~~~~~~~ PARTS ~~~~~~~~~~~~~~~~~~~
    
    alias simple? simple
    def junction?()     not simple?                                        end
                                                                          
    def left()          @left  ||= simple? ? nil : parts[0..-2]*JOINT      end
    def right()         @right ||= simple? ? nil : parts[-1]               end            

    def left_name()     @left_name  ||= left  && self.class.new( left  )   end
    def right_name()    @right_name ||= right && self.class.new( right )   end
                                                                           
    def trunk()         @trunk ||= simple? ? s : left                      end
    def tag()           @tag   ||= simple? ? s : right                     end            
                                                                                       
    def trunk_name()    @trunk_name ||= simple? ? self : left_name         end
    def tag_name()      @tag_name   ||= simple? ? self : right_name        end 

    def pieces
      @pieces ||= simple? ? [self] : trunk_name.pieces << tag_name
    end


    #~~~~~~~~~~~~~~~~~~~ TRAITS / STARS ~~~~~~~~~~~~~~~~~~~    

    def star?()         simple?   and '*' == s[0]               end
    def rstar?()        junction? and '*' == parts[-1][0]       end
      
    def trait_name tag_code
      if tag_card = Card[ tag_code ]
        [ self, tag_card.name ].to_cardname
      end
    end
    
    def template_name?()     is_trait? [:content, :default]     end
    def email_config_name?() is_trait? [:subject, :message]     end

    def is_trait? traitlist
      if simple?
        false
      else
        right_key = right_name.key
        !!traitlist.find do |codename|
          Card[codename].cardname.key==right_key
        end
      end
    end


    #~~~~~~~~~~~~~~~~~~~~ SHOW / ABSOLUTE ~~~~~~~~~~~~~~~~~~~~

    def to_show context
      # FIXME this is not quite right.  distinction from absolute is that it leaves blank parts blank.
      if s =~ RELATIVE_RE
        to_absolute context
      else
        s
      end
    end

    def to_absolute_name rel_name=nil
      (rel_name || self).to_cardname.to_absolute self
    end

    def to_absolute(context, params=nil)
      context = context.to_cardname
      parts.map do |part|
        new_part = case part
          when /^_user$/i;            (user=Session.user_card) ? user.name : part
          when /^_main$/i;            Wagn::Conf[:main_name]
          when /^(_self|_whole|_)$/i; context
          when /^_left$/i;            context.trunk_name
          when /^_right$/i;           context.tag
          when /^_(\d+)$/i;
            pos = $~[1].to_i
            pos = context.size if pos > context.size
            context.parts[pos-1]
          when /^_(L*)(R?)$/i
            l_s, r_s = $~[1].size, $~[2].blank?
            trunk = context.nth_left(l_s)
            r= r_s ? trunk.to_s : trunk.tag
          when /^_/
            (params && ppart = params[part]) ? CGI.escapeHTML( ppart ) : part
          else                     part
        end.to_s.strip
        #Rails.logger.warn "to_abs#{context}, #{part}, #{new_part}, #{new_part.blank? ? context.to_s : new_part}"
        new_part.blank? ? context.to_s : new_part
      end * JOINT
    end

    def nth_left n
      (n >= size ? parts[0] : parts[0..-n-1]).to_cardname
    end
    
    
    #~~~~~~~~~~~~~~~~~~~~ MISC ~~~~~~~~~~~~~~~~~~~~  
    
    def replace_part oldpart, newpart
      oldpart = oldpart.to_cardname
      newpart = newpart.to_cardname
      if oldpart.simple?
        if simple?
          self == oldpart ? newpart : self
        else
          parts.map do |p|
            oldpart == p ? newpart.to_s : p 
          end.to_cardname
        end
      elsif simple?
        self
      else
        if oldpart == parts[0, oldpart.size]
          if self.size == oldpart.size
            newpart
          else
            (newpart.parts+(parts[oldpart.size,].lines.to_a)).to_cardname
          end
        else
          self
        end
      end
    end


  end
end

