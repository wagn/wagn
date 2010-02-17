=begin
One Yury Kotlyarov recently posted this Rails project as a question:

  http://github.com/yura/howto-rspec-custom-matchers/tree/master

It asks: How to write an RSpec matcher that specifies an HTML
<form> contains certain fields, and enforces their properties
and nested structure? He proposed [the equivalent of] this:

    get :new  # a Rails "functional" test - on a controller

    assert_xhtml do
      form :action => '/users' do
        fieldset do
          legend 'Personal Information'
          label 'First name'
          input :type => 'text', :name => 'user[first_name]'
        end
      end
    end

The form in question is a familiar user login page:

<form action="/users">
  <fieldset>
    <legend>Personal Information</legend>
    <ol>
      <li id="control_user_first_name">
        <label for="user_first_name">First name</label>
        <input type="text" name="user[first_name]" id="user_first_name" />
      </li>
    </ol>
  </fieldset>
</form>

If that form were full of <%= eRB %> tags, testing it would be 
mission-critical. (Adding such eRB tags is left as an exercise for 
the reader!)

This post creates a custom matcher that satisfies the following 
requirements:

 - the specification <em>looks like</em> the target code
    * (except that it's in Ruby;)
 - the specification can declare any HTML element type
     _without_ cluttering our namespaces
 - our matcher can match attributes exactly
 - our matcher strips leading and trailing blanks from text
 - the matcher enforces node order. if the specification puts
     a list in collating order, for example, the HTML's order
     must match
 - the specification only requires the attributes and structural 
     elements that its matcher demands; we skip the rest - 
     such as the <ol> and <li> elements. They can change
     freely as our website upgrades
 - at fault time, the matcher prints out the failing elements
     and their immediate context.

=end

require 'nokogiri'

class BeHtmlWith

  def initialize(scope, &block)
    @scope, @block = scope, block
    @references = []
    @spewed = {}
  end

  attr_accessor :builder,
                :doc,
                :failure_message,
                :message,
                :reference,
                :references,
                :returnable,
                :sample,
                :scope

  def matches?(stwing, &block)
    @block ||= block  #  ERGO  test that ||= - preferrably with a real RSpec suite!

    @scope.wrap_expectation self do
      @doc = Nokogiri::HTML(stwing)
      return run_all_xpaths(build_xpaths)
    end
  end
 
  def build_xpaths(&block)
    bwock = block || @block || proc{} #  CONSIDER  what to do with no block? validate?
    @builder = Nokogiri::HTML::Builder.new(&bwock)

    elemental_children.map do |child|
      build_deep_xpath(child)
    end
  end

  def elemental_children(element = @builder.doc)
    element_kids = element.children.grep(Nokogiri::XML::Node)

    element_kids = element_kids.reject{|k| 
                     k.class == Nokogiri::XML::Text ||
                     k.class == Nokogiri::XML::DTD
                     }  #  CONSIDER  rebuild to use not abuse the text nodage!

    return element_kids
  end
  
  def build_deep_xpath(element)
    path = build_xpath(element)
    path.index('not(') == 0 and return '/*[ ' + path + ' ]'
    return '//' + path
  end

  def build_xpath(element)
    count = @references.length
    @references << element  #  note we skip the without @reference!
    
    if element.name == 'without!'
      return 'not( ' + build_predicate(element, 'or') + ' )'
    else
      target = translate_tag(element)
      path = "descendant::#{ target }[ refer(., '#{ count }') "
        #  refer() is first so we collect many samples, despite boolean short-circuiting
      path << 'and '  if elemental_children(element).any?
      path << build_predicate(element) + ']'
      return path
    end
  end

  def translate_tag(element)
    if element.name == 'any!'
      '*'
    else
      element.name.sub(/\!$/, '')
    end
  end

  def build_predicate(element, conjunction = 'and')
    conjunction = " #{ conjunction } "
    element_kids = elemental_children(element)
    return element_kids.map{|child|  build_xpath(child)  }.join(conjunction)
  end

  def run_all_xpaths(xpaths)
    xpaths.each do |path|
      if match_xpath(path).empty?
        complain
        return false
      end
    end
    
    return true
  end

  def match_xpath(path, &refer)
    nodes = @doc.root.xpath_with_callback path, :refer do |element, index|
      collect_samples(element, index.to_i)
    end
     
    @returnable ||= nodes.first  #  TODO  be_with_html must get on board too
    return nodes
  end

#  ERGO  match text with internal spacies?

  def collect_samples(elements, index) # TODO  rename these samples to specimens
    samples = elements.find_all do |element|
                match_attributes_and_text(@references[index], element)
              end
    
    collect_best_sample(samples)
    samples
  end

  def match_attributes_and_text(reference, sample)
    @reference, @sample = reference, sample
    match_attributes and match_text
  end

#  TODO  uh, indenting mebbe?

  def match_attributes
    sort_nodes.each do |attr|
      case attr.name
        when 'verbose!' ;  verbose_spew(attr)
        when 'xpath!'   ;  match_xpath_predicate(attr) or return false
        else            ;  match_attribute(attr)       or return false
      end
    end

    return true
  end

  def sort_nodes
    @reference.attribute_nodes.sort_by do |q|
      { 'verbose!' => 0,  #  put this first, so it always runs, even if attributes don't match
        'xpath!' => 2  #  put this last, so if attributes don't match, it does not waste time
        }.fetch(q.name, 1)
    end 
  end

  def verbose_spew(attr)
    if attr.value == 'true' and @spewed[yo_path = @sample.path] == nil
      puts
      puts '-' * 60
      p yo_path
      puts @sample.to_xhtml
      @spewed[yo_path] = true
    end
  end  #   ERGO  this could use a test...

#  TODO  why we have no :css! yet??

  def match_xpath_predicate(attr)
    @sample.parent.xpath("*[ #{ attr.value } ]").each do |m|
      m.path == @sample.path and 
        return true
    end

    return false
  end

  def match_attribute(attr)
    ref = deAmpAmp(attr.value)
    sam = deAmpAmp(@sample[attr.name])
    ref == sam or match_regexp(ref, sam) or 
      match_class(attr.name, ref, sam)
  end

  def deAmpAmp(stwing)
    stwing.to_s.gsub('&amp;amp;', '&').gsub('&amp;', '&')
  end  #  ERGO await a fix in Nokogiri, and hope nobody actually means &amp;amp; !!!

  def match_regexp(reference, sample)
    reference =~ /\(\?.*\)/ and   #  the irony _is_ lost on us...
      Regexp.new(reference) =~ sample
  end

  def match_class(attr_name, ref, sam)
    attr_name == 'class' and
      " #{ sam } ".index(" #{ ref } ")
  end  #  NOTE  if you call it a class, but ref contains 
       #        something fruity, you are on your own!

  def match_text(ref = @reference, sam = @sample)
    ref_text = get_texts(ref)
    ref_text.empty? and return true
    sam_text = get_texts(sam)
    (ref_text - sam_text).empty? and return true
    got = (ref_text.length == 1 and match_regexp(ref_text.first, sam_text.join))
    return got
  end

  def get_texts(element)
   element.children.grep(Nokogiri::XML::Text).
      map{|x|x.to_s.strip}.select{|x|x.any?}
  end

  def collect_best_sample(samples)
    sample = samples.first or return

    if @best_sample.nil? or depth(@best_sample) > depth(sample)
      @best_sample = sample
    end
  end

  def depth(e)
    e.xpath('ancestor-or-self::*').length
  end
  
  def complain( refered = @builder.doc, 
                 sample = @best_sample || @doc.root )
           #  ERGO  use to_xml? or what?
    @failure_message = "#{message}\n".lstrip +
                       "\nCould not find this reference...\n\n" +
                          refered.to_xhtml.sub(/^\<\!DOCTYPE.*/, '') +
                     "\n\n...in this sample...\n\n" +
                          sample.to_xml
  end

  def build_deep_xpath_too(element)
    return '//' + build_xpath_too(element)
  end

  def build_xpath_too(element)
    path = element.name.sub(/\!$/, '')
    element_kids = element.children.grep(Nokogiri::XML::Node)
    path << '[ '
    count = @references.length
    @references << element
    brackets_owed = 0

    if element_kids.length > 0
      child = element_kids[0]
      path << './descendant::' + build_xpath_too(child)
    end

    if element_kids.length > 1
      path << element_kids[1..-1].map{|child|
                '[ ./following-sibling::*[ ./descendant-or-self::' + build_xpath_too(child) + ' ] ]'
               }.join #(' and .')
    end
       path << ' and ' if element_kids.any?

    path << "refer(., '#{ count }') ]"  #  last so boolean short-circuiting optimizes
    return path
  end

  def negative_failure_message
    "please don't negate - use without!"
  end
  
end


module Test; module Unit; module Assertions

  def wrap_expectation whatever;  yield;  end unless defined? wrap_expectation

  def assert_xhtml(*args, &block)  # ERGO merge
    xhtml, message = args
    
    if @response and message.nil?
      message = xhtml
      xhtml = @response.body
    end
    
    if block
      matcher = BeHtmlWith.new(self, &block)
      matcher.message = message
      matcher.matches?(xhtml, &block)
      message = matcher.failure_message
      flunk message if message.to_s != ''
      return matcher.returnable
    else
     _assert_xml(xhtml)
      return @xdoc
    end
  end

end; end; end

module Spec; module Matchers
  def be_html_with(&block)
    BeHtmlWith.new(self, &block)
  end
end; end


class Nokogiri::XML::Node

  class XPathPredicateYielder
    def initialize(method_name, &block)
      self.class.send :define_method, method_name do |*args|
        raise 'must call with block' unless block
        block.call(*args)
      end
    end
  end

  def xpath_with_callback(path, method_name, &block)
    xpath path, XPathPredicateYielder.new(method_name, &block)
  end

end

module Nokogiri
  module XML
    class Builder
      def cleanse_element_name(method)
        method.to_s.sub(/[_]$/, '') # or [_!]
      end  #  monkey patch me!
    
      def method_missing method, *args, &block # :nodoc:
        if @context && @context.respond_to?(method)
          @context.send(method, *args, &block)
        else
          node = Nokogiri::XML::Node.new(cleanse_element_name(method), @doc) { |n|
            args.each do |arg|
              case arg
              when Hash
                arg.each { |k,v| n[k.to_s] = v.to_s }
              else
                n.content = arg
              end
            end
          }
          insert(node, &block)
        end
      end
    end
  end
end
