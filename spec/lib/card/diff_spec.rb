# -*- encoding : utf-8 -*-
#!/usr/bin/env ruby

require 'card/diff'

describe Card::Diff do

  def del text
    "<del class='diffdel diff-red'>#{text}</del>"
  end
  def ins text
    "<ins class='diffins diff-green'>#{text}</ins>"
  end
  def tag text
    "&lt;#{text}&gt;"
  end
  def diff old_s, new_s, opts=@opts
    Card::Diff.complete(old_s, new_s, opts)
  end
    
  
  old_p = '<p>old</p>'
  new_p = '<p>new</p>'
  new_h = '<h1>new</h1>'
  def p_diff
    diff '<p>old</p>', '<p>new</p>'
  end

  
  context "html format" do
    before(:all) do
      @opts = {:format=>:html}
    end
    
    it "doesn't change a text without changes" do
      text = "Hello World!\n How are you?"
      expect(diff text, text).to eq(text)
    end
    it 'preserves html' do
      expect(p_diff).to eq("<p>#{del 'old'}#{ins 'new'}</p>")
    end
    it 'ignores html changes' do
      expect(diff old_p, new_h).to eq("<h1>#{del 'old'}#{ins 'new'}</h1>")
    end
    
    it 'diff with multiple paragraphs' do
      a = "<p>this was the original string</p>"
      b = "<p>this is</p>\n<p> the new string</p>\n<p>around the world</p>" 

      expect(diff a, b).to eq(
          "<p>this #{del 'was'}#{ins 'is'}</p>"+
          "\n<p> the " +
          "#{del 'original'}#{ins 'new'}" +
          " string</p>\n" +
          "<p>#{ins 'around the world'}</p>"
          )
    end
  end
  
  context "text format" do
    before(:all) do
      @opts = {:format=>:text}
    end
  
    it 'removes html' do
      expect(p_diff).to eq("#{del 'old'}#{ins 'new'}")
    end
    
    it 'compares complete links' do
      diff = Card::Diff.complete("[[A]]\n[[B]]", "[[A]]\n[[C]]", :format=>:html)
      expect(diff).to eq( "[[A]]\n#{del '[[B]]'}#{ins '[[C]]'}")
    end
    
    it 'compares complete inclusions' do
      diff = Card::Diff.complete("{{A}}\n{{B}}", "{{A}}\n{{C}}", :format=>:html)
      expect(diff).to eq( "{{A}}\n#{del '{{B}}'}#{ins '{{C}}'}")
    end
    
  end
  
  context "raw format" do
    before(:all) do
      @opts = {:format=>:raw}
    end
  
    it 'excapes html' do
      expect(p_diff).to eq("#{tag 'p'}#{del 'old'}#{ins 'new'}#{tag '/p'}")
    end
    
    it 'diff for tag change' do
      expect(diff old_p, new_h).to eq( del("#{tag 'p'}old#{tag '/p'}") + ins("#{tag 'h1'}new#{tag '/h1'}") )
    end    
  end
end
