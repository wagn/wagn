#!/usr/bin/env ruby

require 'ripper'
require 'stringio'
require 'cgi'
require 'erb'
require 'optparse'
require 'pathname'

# TODO  reflect the banner anchor at generation time, to figure out what to hotlink to

class Ripdoc < Ripper::Filter
  HomePath = (Pathname.new(__FILE__).dirname + '../..').expand_path

  STYLES = {
    CHAR:               'color: brown; font-weight: bolder;',
    const:              "color: #FF4F00; font-weight: bolder;",
    backref:            "color: #f4f; font-weight: bolder;",
    comment:            "font-style: italic; color: #446; font-family: Times; font-size: 110%;",
       # TODO  use "font: Times italic 110%" to save space
    embdoc:             "background-color: #FFe; font-family: Times; font-size: 133%;",
    embdoc_beg:         "display: none;",
    embdoc_end:         "display: none;",
    embexpr:            "background-color: #ccc;",
    embexpr_delimiter:  "background-color: #aaa;",
    gvar:               "color: #8f5902; font-weight: bolder;",
    ivar:               "color: #240;",
    int:                "color: #336600; font-weight: bolder;",
    operator:           "font-weight: bolder; font-size: 120%;",
    kw:                 "color: purple;",
    regexp_delimiter:   "background-color: #faf;",
    regexp:             "background-color: #fcf;",
    string:             "background-color: white;", #dfc
    string_delimiter:   "background-color: #cfa;",
    symbol:             "color: #066;",
    tstring_content: 'background: url(images/tstring.png) right;',
    tstring_internal: 'background: url(images/tstring.png) right;',  #  TODO  merge these two!
    tregexp_content: 'background: url(images/hot_pink.png);'
  }

  def self.generate(filename, title)
    @sauce = compile_fragment(File.read(filename))
    @title = title
    @string_background = :tstring_content
    erb = ERB.new((HomePath + 'lib/assert2/ripdoc.html.erb').read, nil, '>')
    xhtml = erb.result(binding())
    xhtml.gsub! /\<pre>\s*\<\/pre>/m, ''
    xhtml.gsub! /\<p>\s*\<\/p>/m, ''
    return xhtml
  end

  def dequote(attributes)
    return attributes.gsub('&quot;', '"')
  end  #  TODO  complex '"? if we can't it might be a good thing...

  def enline(line)
    line = CGI.escapeHTML(line)
    return line.gsub( /&lt;a(.*?)&gt;/){ "<a #{dequote($1)}>" }.
                gsub('&lt;/a&gt;', '</a>').
                gsub(/&lt;br\s*\/&gt;/, '<br/>').
                gsub( '&lt;code&gt;', '<code style="font-weight: bolder; font-style: normal;">').
                gsub('&lt;/code&gt;', '</code>').
                gsub( '&lt;em&gt;', '<em>').
                gsub('&lt;/em&gt;', '</em>').
                gsub( '&lt;li&gt;', '<li>').
                gsub('&lt;/li&gt;', '</li>').
                gsub( '&lt;ul&gt;', '<ul>').
                gsub('&lt;/ul&gt;', '</ul>').
                gsub('&amp;mdash;', '&mdash;')
  end

  def deformat(line, f)
    if line =~ /^\s/   #  CONSIDER why the line-height broke??
      f << "</p>" if @owed_p
      f << "<pre style='line-height: 75%;'>\n" unless @owed_pre
      @owed_p = false
      @owed_pre = true
      f << enline(line) << "\n"
      return
    end
    
    f << '</pre>' if @owed_pre
    @owed_pre = false
    f << '<p>' unless @owed_p
    @owed_p = true
    f << enline(line)
  end
  
  def on_embdoc_beg(tok, f)
    return f if @in_no_doc
    @embdocs = []
    f << "</pre>\n" if @owed_pre
    @owed_pre = false
    return f
    # on_kw tok, f, 'embdoc_beg'
  end
  
  def is_no_doc?(tok)
    tok.strip =~ /^\#\!nodoc\!/ or tok.strip =~ /^\#\!no_doc\!/
  end

  def on_embdoc(tok, f)
    return f if @in_no_doc
    
    if is_no_doc? tok
      @in_no_doc = true
    else
      @embdocs << tok
    end
    
    return f
  end
  
  def on_embdoc_end(tok, f)
    return f if @in_no_doc
    return end_panel(f)
    return f
  end
  
  def name_toggle(banner)
    banner = banner.gsub(/<.*?>/, '').
                    gsub(/&.*?;/, '').
                    scan(/[ _[:alnum:]]/).
                    map{|x| x == ' ' ? '_' : x }.
                    join.
                    gsub(/_+/, '_').
                    gsub(/_$/, '')

    return "<a href='#' name='#{banner}' id='#{banner}_'></a>" # CONSIDER this can't use <a ../> because enline() would mangle it...
      #  CONSIDER  the _ is due to a bug in libxml - it squeaks at a name and id that are the same - 
       #                                     despite that's a common idiom!
  end
  
  def end_panel(f)
      if banner = @embdocs.shift  #  accordion_toggle_active
        f << '<h1 class="accordion_toggle">'
        f << name_toggle(banner)
        f << enline(banner)
        f << '</h1>'
      end
      
      f << '<div class="accordion_content">'
        f << '<p>'
        @owed_p = true
        prior = false

        @embdocs.each do |doc|
          if doc.strip == ''
            f << "</p>\n<p>" if @owed_p
            prior = false
          elsif doc.strip =~ /^\#\!link\!(.*)/ #!link!froot!loop
            target, contents = $1.split('!')  #  TODO  permit a ! in the contents
            puts '#!link!anchor!text tags work best with text after the last bang!' unless contents
            contents ||= ''
            f << "<a href='\##{target}' onclick='raise(\"#{target}\")'>"
            f << enline(contents)
            f << '</a>'
          else
            f << ' ' if prior
            deformat(doc, f)
            prior = true
          end
        end
        
        f << '</p>' if @owed_p
    f << '<pre>' unless @owed_pre
    @owed_pre = true
    @embdocs = []
    return f
  end

#  TODO  need a tregexp_content to distinguish them!

  def span(kode)
    if STYLES[kode.to_sym]
      # class="#{kode}" 
      return %Q[<span style="#{STYLES[kode.to_sym]}">]
    else
      return '<span>'
    end
  end
  
  def spanit(kode, f, tok)
    @spans_owed ||= 0
    @spans_owed += 1
    f << span(kode) << CGI.escapeHTML(tok)
  end

  def on_kw(tok, f, klass = 'kw')
    return f if @in_no_doc
    f << span(klass) << CGI.escapeHTML(tok)
    f << '</span>'
  end

  def on_comment(tok, f)
    if tok.strip =~ /^\#\!end_panel\!/
      f << '</pre>' if @owed_pre
      @owed_pre = false
      f << '</div>'
      return f
    end

    nodoc = is_no_doc?(tok)

    if !nodoc and !@in_no_doc and tok.strip !~ /^\s*#\!/
      f << span(:comment) << enline(tok.rstrip) << '</span>'
      on_nl nil, f
    end
    
    @in_no_doc ||= nodoc
    @in_no_doc = nil if tok.strip =~ /^\#\!doc\!/
    return f
  end

  def on_CHAR(tok, f)
    return f if @in_no_doc
    on_kw tok, f, 'CHAR'
    return f
  end

# TODO linefeeds inside %w() and possibly ''
#  TODO colorize :"" and :"#{}" correctly

  def on_default(event, tok, f)
    return f if @in_no_doc

    if @symbol_begun
      @symbol_begun = false
      f << %Q[#{span(:symbol)}#{CGI.escapeHTML(tok)}</span>]
    elsif tok =~ /^[[:punct:]]+$/
      f << %Q[#{span(:operator)}#{CGI.escapeHTML(tok)}</span>]
    else
      on_kw tok, f, event.to_s.sub(/^on_/, '')
    end

    return f
  end

  def finish_one_span(f)
    if @spans_owed > 0
      f << '</span>' 
      @spans_owed -= 1
    end
  end

  def on_tstring_beg(tok, f)
    return f if @in_no_doc
    @spans_owed += 1
    f << span(:string)
    @string_background = :tstring_content
    f << %Q[#{span(:string_delimiter)}#{CGI.escapeHTML(tok)}</span>]
  end

  def on_tstring_content(tok, f, style = 'tstring_content')
    tok.split(/\n/).each_with_index do |sub_tok, index|
      if index == 0
        on_string_stretch(sub_tok, f, style)
      else
        space, sub_tok = sub_tok.scan(/(\s*)(.*)/).first
        f << space
        on_string_stretch(sub_tok, f, style)
      end
    end
    return f
  end

  def on_string_stretch(tok, f, klass = 'TODO remove me')
    return f if @in_no_doc
    f << span(@string_background.to_s) << CGI.escapeHTML(tok)
    f << '</span>'
  end

#  TODO  fix end-of-delim bug in // and %w() and %{} etc

  def on_tstring_end(tok, f)
    return f if @in_no_doc
    
    if tok.length > 1
      margin, content, tok = tok.scan(/^(\s*)(.*)(.)$/).first
      f << margin if margin
      on_tstring_content content, f, 'tstring_internal' if content  #  TODO  is this used??
    end
    
    f << %Q[#{span(:string_delimiter)}#{CGI.escapeHTML(tok.to_s)}</span>]
    finish_one_span(f)
    return f
  end  #  TODO  report to ripper author the bug where on_tstring_end contains the whole string

  def on_regexp_beg(tok, f)
    return f if @in_no_doc
    @spans_owed += 1
    f << span(:regexp)
    @string_background = :tregexp_content
    f << %Q[#{span(:regexp_delimiter)}#{CGI.escapeHTML(tok)}</span>]
  end

  def on_regexp_end(tok, f)
    return f if @in_no_doc
    f << %Q[#{span(:regexp_delimiter)}#{CGI.escapeHTML(tok)}</span>]
    finish_one_span(f)
    return f
  end

  def on_embexpr_beg(tok, f)
    return f if @in_no_doc
    spanit :embexpr, f, tok
    return f
  end  #  TODO  don't interrupt a span or nothing with a nodoc!
  
  #  TODO single-line mode for nodoc
  
  def on_ignored_nl(tok, f)
    return f if @in_no_doc
    on_nl nil, f
  end

  def on_nl(tok, f)
    return f if @in_no_doc
    f << "\n"
  end

  def on_lbrace(tok, f)
    return f if @in_no_doc
    spanit '', f, '' # tok  CONSIDER  wonder who is actually emitting the { ??
    f << tok
  end
  
  def on_rbrace(tok, f)
    return f if @in_no_doc
    f << tok
    finish_one_span(f)  #  TODO  these things might wrap lines!
    return f
  end

  def on_symbeg(tok, f)
    return f if @in_no_doc
    on_default(:on_symbeg, tok, f)
    @symbol_begun = true
    return f
  end

#  TODO  syntax hilite the inner language of regices? how about XPathics?
#   escapes in strings??

  def on_ivar(tok, f)
    return f if @in_no_doc
    f << %Q[#{span(:ivar)}#{CGI.escapeHTML(tok)}</span>]
  end

  attr_accessor :embdocs,
                :in_no_doc,
                :owed_pre,
                :spans_owed

  def parse(buf, f)
    @spans_owed = 0
    @symbol_begun = false
    super(buf)
  end

  DOCTYPE = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
              "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' +
              "\n"

  def Ripdoc.compile(f)
    return DOCTYPE +
            '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en" dir="ltr"
            ><head>' + 
           '</head><body>' + compile_fragment(f) + '</body></html>'
  end

  def Ripdoc.compile_fragment(f)
    buf = StringIO.new
    parser = Ripdoc.new(f)
    parser.in_no_doc = false
    parser.owed_pre = true
    parser.parse(buf, f)
    result = buf.string
    parser.spans_owed.times{ result += '</span>' }

    return '<div id="content"><pre>' + result +
               "#{'</pre>' if parser.owed_pre }</div>"

  end

end

#~ :on_ident
#~ :on_const
#~ :on_semicolon
#~ :on_op
#~ :on_int
#~ :on_comma
#~ :on_lparen
#~ :on_rparen
#~ :on_backref
#~ :on_period
#~ :on_lbracket
#~ :on_rbracket
#~ :on_rbrace
#~ :on_qwords_beg
#~ :on_words_sep

class ERB
  attr_accessor :lineno

  remove_method :result
  def result(b)
    eval(@src, b, (@filename || '(erb)'), (@lineno || 1))
  end
end

system 'rubyw1.9.0 ../../test/ripdoc_suite.rb' if $0 == __FILE__
