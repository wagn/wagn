require 'test/unit'
require 'assert2'
require 'rexml/document'
require 'rexml/entity'
require 'rexml/formatters/pretty'
require 'nokogiri'  #  must be installed to use xpath{}!

module Test; module Unit; module Assertions
  
  def assert_xhtml(xhtml)
    return _assert_xml(xhtml) # , XML::HTMLParser)
  end 

  def _assert_xml(xml) #, parser = XML::Parser)
    if false
      xp = parser.new()
      xp.string = xml
      
      if XML.respond_to? :'default_pedantic_parser='
        XML.default_pedantic_parser = true
      else
        XML::Parser.default_pedantic_parser = true
      end  #  CONSIDER  uh, figure out the best libxml-ruby??
      
      @xdoc = xp.parse.root
    else
      #  CONSIDER  figure out how entities are supposed to work!!
      xml = xml.gsub('&mdash;', '--')
      doc = REXML::Document.new(xml)
      @xdoc = doc.root
    end
  end 

  def assert_xhtml_(xhtml)
    return _assert_xml_(xhtml) # , XML::HTMLParser)
  end 

  def _assert_xml_(xml) #, parser = XML::Parser)
    if false
      xp = parser.new()
      xp.string = xml
      
      if XML.respond_to? :'default_pedantic_parser='
        XML.default_pedantic_parser = true
      else
        XML::Parser.default_pedantic_parser = true
      end  #  CONSIDER  uh, figure out the best libxml-ruby??
      
      @xdoc = xp.parse.root
    else
      #  TODO  figure out how entities are supposed to work!!
      xml = xml.gsub('&mdash;', '--')
      doc = Nokogiri::XML(xml)
      @xdoc = doc.root
    end
  end 

  class AssertXPathArguments
    
    def initialize(path = '', id = nil, options = {})
      @subs = {}
      @xpath = ''
      to_xpath(path, id, options)
    end
    
    attr_reader :subs
    attr_reader :xpath
    
    def to_conditions(hash)
      xml_attribute_name = /^[a-z][_a-z0-9]+$/i  #  CONSIDER is that an XML attribute name match?
      
      @xpath << hash.map{|k, v|
                  sk = k.to_s
                  sk = '_text' if sk == '.' or k == 46
                  k = '.' if k == 46 and RUBY_VERSION < '1.9.0'
                  @subs[sk] = v.to_s
                  "#{ '@' if k.to_s =~ xml_attribute_name }#{k} = $#{sk}" 
                }.join(' and ')
    end
    
    def to_predicate(hash, options)
      hash = { :id => hash } if hash.kind_of? Symbol
      hash.merge! options
      @xpath << '[ '
      to_conditions(hash)
      @xpath << ' ]'
    end

    def to_xpath(path, id, options)
      @xpath = path
      @xpath = "descendant-or-self::#{ @xpath }" if @xpath.kind_of? Symbol
      to_predicate(id, options) if id
    end

  end

    # if node = @xdoc.find_first(path) ## for libxml
    #  def node.text
    #    find_first('text()').to_s
    #  end

  def xpath(path, id = nil, options = {}, &block)
    former_xdoc = @xdoc
    apa = AssertXPathArguments.new(path, id, options)
    node = REXML::XPath.first(@xdoc, apa.xpath, nil, apa.subs)
    
    add_diagnostic :clear do
      diagnostic = "xpath: #{ apa.xpath.inspect }\n"
      diagnostic << "arguments: #{ apa.subs.pretty_inspect }\n" if apa.subs.any?
      diagnostic + "xml context:\n" + indent_xml
    end

    if node
      def node.[](symbol)
        return attributes[symbol.to_s]
      end
    end

    if block
      assert_('this xpath cannot find a node', :keep_diagnostics => true){ node }
      assert_ nil, :args => [@xdoc = node], :keep_diagnostics => true, &block  #  TODO  need the _ ?
    end
    
    return node
    # TODO raid http://thebogles.com/blog/an-hpricot-style-interface-to-libxml/
  ensure
    @xdoc = former_xdoc
  end  #  TODO trap LibXML::XML::XPath::InvalidPath and explicate it's an XPath problem
 
  def xpath_(path, id = nil, options = {}, &block)
    former_xdoc = @xdoc
    apa = AssertXPathArguments.new(path, id, options)
    node = @xdoc.xpath(apa.xpath) #, nil, apa.subs)
       
    add_diagnostic :clear do
      diagnostic = "xpath: #{ apa.xpath.inspect }\n"
      diagnostic << "arguments: #{ apa.subs.pretty_inspect }\n" if apa.subs.any?
      diagnostic + "xml context:\n" + indent_xml
    end

    if node
      def node.[](symbol)
        return attributes[symbol.to_s]
      end
    end

    if block
      assert_('this xpath cannot find a node', :keep_diagnostics => true){ node }
      assert_ nil, :args => [@xdoc = node], :keep_diagnostics => true, &block  #  TODO  need the _ ?
    end
    
    return node
    # TODO raid http://thebogles.com/blog/an-hpricot-style-interface-to-libxml/
  ensure
    @xdoc = former_xdoc
  end  #  TODO trap LibXML::XML::XPath::InvalidPath and explicate it's an XPath problem
 
  def indent_xml(node = @xdoc)
    bar = REXML::Formatters::Pretty.new
    out = String.new
    bar.write(node, out)
    return out
  end
  
end; end; end


if RUBY_VERSION <= '1.8.6'

module REXML
  module Formatters
    class Pretty

      private

  #  see http://www.google.com/codesearch/p?hl=en#Ezb_-tQR858/test_libs/rexml_fix.rb
  #   for less info about this fix...
  
      def wrap(string, width)
        # Recursivly wrap string at width.
        return string if string.length <= width
        place = string.rindex(/\s+/, width) # Position in string with last ' ' before cutoff
        return string if place.nil?
        return string[0,place] + "\n" + wrap(string[place+1..-1], width)
      end

    end
  end

  class Element
    # this patches http://www.germane-software.com/projects/rexml/ticket/128
    def write(output=$stdout, indent=-1, transitive=false, ie_hack=false)
      Kernel.warn("#{self.class.name}.write is deprecated.  See REXML::Formatters")
      formatter = if indent > -1
          if transitive
            require "rexml/formatters/transitive"
            REXML::Formatters::Transitive.new( indent, ie_hack )
          else
            REXML::Formatters::Pretty.new( indent, ie_hack )
          end
        else
          REXML::Formatters::Default.new( ie_hack )
        end
      formatter.write( self, output )
    end
  end
end

end


require '../../test/assert_xhtml_suite.rb' if $0 == __FILE__ and File.exist?('../../test/assert_xhtml_suite.rb')
