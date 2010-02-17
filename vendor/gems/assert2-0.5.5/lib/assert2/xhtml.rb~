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

class Nokogiri::XML::Node

  class XPathYielder
    def initialize(method_name, &block)
      self.class.send :define_method, method_name do |*args|
        raise 'must call with block' unless block
        block.call(*args)
      end
    end
  end

  def xpath_with_callback(path, method_name, &block)
    xpath path, XPathYielder.new(method_name, &block)
  end

end

class BeHtmlWith

  def deAmpAmp(stwing)
    stwing.to_s.gsub('&amp;amp;', '&').gsub('&amp;', '&')
  end  #  ERGO await a fix in Nokogiri, and hope nobody actually means &amp;amp; !!!

  def get_texts(element)
    element.xpath('text()').map{|x|x.to_s.strip}.reject{|x|x==''}.compact
  end

  def match_regexp(reference, sample)
    reference =~ /^\(\?/ and 
        Regexp.new(reference) =~ sample
  end

  def match_text(ref, sam)
    ref_text = get_texts(ref)
      #  TODO regices?
    ref_text.empty? or ( ref_text - (sam_text = get_texts(sam)) ).empty? or
      (ref_text.length == 1 and 
        match_regexp(ref_text.first, sam_text.join) )
  end  #  The irony _is_ lost on us

  def match_attributes_and_text(reference, sample)
    reference.attribute_nodes.each do |attr|
      ref, sam = deAmpAmp(attr.value), deAmpAmp(sample[attr.name])
      ref == sam or match_regexp(ref, sam) or
        return false
    end

    return match_text(reference, sample)
  end

  def elements_equal(element_1, element_2)
    raise 'programming error: mismatched elements' unless element_1.document == element_2.document
    element_1.path == element_2.path
  end
  
#       end  #  TODO  more "elements" less "nodes"

  def collect_samples(elements, index)
    samples = elements.find_all do |element|
      match_attributes_and_text(@references[index], element)
    end

    @first_samples += samples if samples.any? and index == 0
    return samples
  end
  
  attr_accessor :doc,
                :scope

  def assemble_complaint
    @first_samples << @doc.root if @first_samples.empty?  #  TODO  test the first_samples system
    @failure_message = complain_about(@builder.doc.root, @first_samples)
  end

  def matches?(stwing, &block)
    @scope.wrap_expectation self do  #  TODO  put that back online
      begin
        bwock = block || @block || proc{} #  TODO  what to do with no block? validate?
        @builder = Nokogiri::HTML::Builder.new(&bwock)
        @doc = Nokogiri::HTML(stwing)
        @reason = nil

        @builder.doc.children.each do |child|
          @first_samples = []
          @path = build_deep_xpath(child)
          next if @path == "//descendant::html[ refer(., '0') ]" # CONSIDER wtf is this?

          matchers = @doc.root.xpath_with_callback @path, :refer do |elements, index|
                       collect_samples(elements, index.to_i)
                     end
          
          matchers.empty? and assemble_complaint and return false
           #  TODO  use or lose @reason
        end
        
        # TODO complain if too many matchers

        return true
      end
    end
  end

  def build_deep_xpath(element)
    @references = []
    path = build_xpath(element)
    if path.index('not') == 0
      path = '*[ ' + path + ' ]'  #  ERGO  uh, is there a cleaner way?
    end
    return '//' + path
  end

  def build_deep_xpath_too(element)
    @references = []
    return '//' + build_xpath_too(element)
  end

  attr_reader :references

  def build_predicate(element)
    path = ''
    element_kids = element.children.grep(Nokogiri::XML::Element)

    if element_kids.any?
      path << element_kids.map{|child|
#                 if child.name == 'without' # TODO throw away nested withouts?
#                   'not( ' + build_predicate(child) + '1=1 )'
#                 else
                  build_xpath(child)
#                 end
              }.join(' and ')
      path << ' and '
    end

    return path
  end

  def build_xpath(element)
    count = @references.length
    @references << element  #  note we skip the without @reference!
    
    if element.name == 'without!'
      return 'not( ' + build_predicate(element) + '1=1 )'
    else
      path = 'descendant::'
      path << element.name.sub(/\!$/, '')
      path << '[ '
      path << build_predicate(element)
      path << "refer(., '#{count}') ]"  #  last so boolean short-circuiting optimizes
      return path
    end
  end

  def build_xpath_too(element)
    path = element.name.sub(/\!$/, '')
    element_kids = element.children.grep(Nokogiri::XML::Element)
    path << '[ '
    count = @references.length
    @references << element
    brackets_owed = 0

    if element_kids.length > 0
      child = element_kids[0]
      path << './descendant::' + build_xpath_too(child)
#               }.join(' and ')
#       path << ' and '
    end

    if element_kids.length > 1
      path << element_kids[1..-1].map{|child|
                '[ ./following-sibling::*[ ./descendant-or-self::' + build_xpath_too(child) + ' ] ]'
               }.join #(' and .')
    end
       path << ' and ' if element_kids.any?

    path << "refer(., '#{count}') ]"  #  last so boolean short-circuiting optimizes
    return path
  end

  def complain_about(refered, samples, reason = nil)  #  TODO  put argumnets in order
    reason = " (#{reason})" if reason
    "\nCould not find this reference#{reason}...\n\n" +
      refered.to_html +
      "\n\n...in these sample(s)...\n\n" +  #  TODO  how many samples?
      samples.map{|s|s.to_html}.join("\n\n...or...\n\n")
  end

  def count_elements_to_node(container, element)
    return 0 if elements_equal(container, element)
    count = 0
    
    container.children.each do |child|
      sub_count = count_elements_to_node(child, element)
      return count + sub_count if sub_count        
      count += 1
    end
    
    return nil
  end  #  TODO  use or lose these

#  TODO does a multi-modal top axis work?
# TODO      this_match = node.xpath('preceding::*').length
    
    # http://www.zvon.org/xxl/XPathTutorial/Output/example18.html
    # The preceding axis contains all nodes in the same document 
    # as the context node that are before the context node in 
    # document order, excluding any ancestors and excluding 
    # attribute nodes and namespace nodes 

  attr_accessor :failure_message

  def negative_failure_message
    "TODO"
  end
  
  def initialize(scope, &block)
    @scope, @block = scope, block
  end

  def self.create(stwing)
    bhw = BeHtmlWith.new(nil)
    bhw.doc = Nokogiri::HTML(stwing)
    return bhw
  end

end


module Test; module Unit; module Assertions

  def wrap_expectation whatever;  yield;  end unless defined? wrap_expectation

  def assert_xhtml(xhtml = @response.body, &block)  # TODO merge
    if block
      matcher = BeHtmlWith.new(self, &block)
      matcher.matches?(xhtml, &block)
      message = matcher.failure_message
      flunk message if message.to_s != ''
#       return matcher.builder.doc.to_html # TODO return something reasonable
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
      def content= string
        self.native_content = encode_special_chars(string.to_s)
      end
end