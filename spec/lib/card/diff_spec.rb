# -*- encoding : utf-8 -*-
#!/usr/bin/env ruby

require 'wagn/spec_helper'
require 'card/diff'
require 'diff'

describe Card::Diff do
  include Card::Diff

  before do
    @builder = Card::Diff::DiffBuilder.new 'old', 'new'
  end

  it 'should start of tag' do
    assert @builder.start_of_tag?('<')
    assert(!@builder.start_of_tag?('>'))
    assert(!@builder.start_of_tag?('a'))
  end

  it 'should end of tag' do
    assert @builder.end_of_tag?('>')
    assert(!@builder.end_of_tag?('<'))
    assert(!@builder.end_of_tag?('a'))
  end

  it 'should whitespace' do
    assert @builder.whitespace?(" ")
    assert @builder.whitespace?("\n")
    assert @builder.whitespace?("\r")
    assert(!@builder.whitespace?("a"))
  end

  it 'should convert html to list of words simple' do
    assert_equal(
        ['the', ' ', 'original', ' ', 'text'],
        @builder.convert_html_to_list_of_words('the original text'))
  end

  it 'should convert html to list of words should separate endlines' do
    assert_equal(
        ['a', "\n", 'b', "\r", 'c'],
        @builder.convert_html_to_list_of_words("a\nb\rc"))
  end

  it 'should convert html to list of words should not compress whitespace' do
    assert_equal(
        ['a', ' ', 'b', '  ', 'c', "\r \n ", 'd'],
        @builder.convert_html_to_list_of_words("a b  c\r \n d"))
  end

  it 'should convert html to list of words should handle tags well' do
    assert_equal(
        ['<p>', 'foo', ' ', 'bar', '</p>'],
        @builder.convert_html_to_list_of_words("<p>foo bar</p>"))
  end

  it 'should convert html to list of words interesting' do
    assert_equal(
        ['<p>', 'this', ' ', 'is', '</p>', "\r\n", '<p>', 'the', ' ', 'new', ' ', 'string',
         '</p>', "\r\n", '<p>', 'around', ' ', 'the', ' ', 'world', '</p>'],
        @builder.convert_html_to_list_of_words(
            "<p>this is</p>\r\n<p>the new string</p>\r\n<p>around the world</p>"))
  end

  it 'should html diff simple' do
    a = 'this was the original string'
    b = 'this is the new string'
    assert_equal('this <del class="diffmod">was</del><ins class="diffmod">is</ins> the ' +
           '<del class="diffmod">original</del><ins class="diffmod">new</ins> string',
           diff(a, b))
  end

  it 'should html diff with multiple paragraphs' do
    a = "<p>this was the original string</p>"
    b = "<p>this is</p>\r\n<p> the new string</p>\r\n<p>around the world</p>"

    # Some of this expected result is accidental to implementation.
    # At least it's well-formed and more or less correct.
    assert_equal(
        "<p>this <del class=\"diffmod\">was</del><ins class=\"diffmod\">is</ins></p>"+
        "<ins class=\"diffmod\">\r\n</ins><p> the " +
        "<del class=\"diffmod\">original</del><ins class=\"diffmod\">new</ins>" +
        " string</p><ins class=\"diffins\">\r\n</ins>" +
        "<p><ins class=\"diffins\">around the world</ins></p>",
        diff(a, b))
  end

  # FIXME this test fails (ticket #67, http://dev.instiki.org/ticket/67)
  it 'should html diff preserves endlines in pre' do
    a = "<pre>\na\nb\nc\n</pre>"
    b = "<pre>\n</pre>"
    assert_equal(
        "<pre>\n<del class=\"diffdel\">a\nb\nc\n</del></pre>",
        diff(a, b))
  end

  it 'should html diff with tags' do
    a = ""
    b = "<div>foo</div>"
    assert_equal '<div><ins class="diffins">foo</ins></div>', diff(a, b)
  end

  it 'should diff for tag change' do
    a = "<a>x</a>"
    b = "<b>x</b>"
    # FIXME sad, but true - this case produces an invalid XML. If handle this you can, strong your foo is.
    assert_equal '<a><b>x</a></b>', diff(a, b)
  end

end
