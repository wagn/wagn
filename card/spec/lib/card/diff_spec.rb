# -*- encoding : utf-8 -*-
# !/usr/bin/env ruby

require "card/diff"

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

  def summary old_s, new_s, opts=@opts
    Card::Diff.summary(old_s, new_s, opts)
  end

  old_p = "<p>old</p>"
  new_p = "<p>new</p>"
  new_h = "<h1>new</h1>"
  def p_diff
    diff "<p>old</p>", "<p>new</p>"
  end

  describe "traffic light" do
    it "is green for addition" do
      a = "a"
      b = "a b"
      db = Card::Diff.new(a, b)
      expect(db.green?).to be_truthy
      expect(db.red?).to be_falsey
    end
    it "is red for deletion" do
      a = "a"
      b = ""
      db = Card::Diff.new(a, b)
      expect(db.green?).to be_falsey
      expect(db.red?).to be_truthy
    end
    it "is green and red for change" do
      a = "a"
      b = "b"
      db = Card::Diff.new(a, b)
      expect(db.green?).to be_truthy
      expect(db.red?).to be_truthy
    end
    it "is off for no change" do
      a = "a"
      b = "a"
      db = Card::Diff.new(a, b)
      expect(db.green?).to be_falsey
      expect(db.red?).to be_falsey
    end
  end

  describe "summary" do
    before(:all) do
      @opts = { format: :html }
    end

    it "omits unchanged text" do
      a = "<p>this was the original string</p>"
      b = "<p>this is the new string</p>"
      expect(summary a, b).to eq(
        "...#{del 'was'}#{ins 'is'}...#{del 'original'}#{ins 'new'}..."
      )
    end

    it "no ellipsis if changes fit exactly" do
      a = "123"
      b = "456"
      expect(summary a, b, summary: { length: 6 }).to eq(
        "#{del '123'}#{ins '456'}"
      )
    end

    it "green ellipsis if added text does not fit" do
      a = "123"
      b = "5678"
      expect(summary a, b, summary: { length: 6 }).to eq(
        "#{del '123'}#{ins '...'}"
      )
    end

    it "neutral ellipsis if complete change does not fit" do
      a = "123 123"
      b = "456 456"
      expect(summary a, b, summary: { length: 9 }).to eq(
        "#{del '123'}#{ins '456'}..."
      )
    end

    it "red ellipsis if deleted text partially fits" do
      a = "123456"
      b = "567"
      expect(summary a, b, summary: { length: 4 }).to eq(
        (del "1...").to_s
      )
    end

    it "green ellipsis if added text partially fits" do
      a = "1234"
      b = "56789"
      expect(summary a, b, summary: { length: 8 }).to eq(
        "#{del '1234'}#{ins '5...'}"
      )
    end

    it "removes html tags" do
      a = "<a>A</a>"
      b = "<b>B</b>"
      expect(summary a, b, format: :html).to eq(
        "#{del 'A'}#{ins 'B'}"
      )
    end

    it "with html tags in raw format" do
      a = "<a>1</a>"
      b = "<b>1</b>"
      expect(summary a, b, format: :raw).to eq(
        "#{del(tag 'a')}#{ins(tag 'b')}...#{del(tag '/a')}#{ins(tag '/b')}"
      )
    end
  end

  context "html format" do
    before(:all) do
      @opts = { format: :html }
    end

    it "doesn't change a text without changes" do
      text = "Hello World!\n How are you?"
      expect(diff text, text).to eq(text)
    end
    it "preserves html" do
      expect(p_diff).to eq("<p>#{del 'old'}#{ins 'new'}</p>")
    end
    it "ignores html changes" do
      expect(diff old_p, new_h).to eq("<h1>#{del 'old'}#{ins 'new'}</h1>")
    end

    it "diff with multiple paragraphs" do
      a = "<p>this was the original string</p>"
      b = "<p>this is</p>\n<p> the new string</p>\n<p>around the world</p>"

      expect(diff a, b).to eq(
        "<p>this #{del 'was'}#{ins 'is'}</p>"\
        "\n<p> the " \
        "#{del 'original'}#{ins 'new'}" \
        " string</p>\n" \
        "<p>#{ins 'around the world'}</p>"
      )
    end
  end

  context "text format" do
    before(:all) do
      @opts = { format: :text }
    end

    it "removes html" do
      expect(p_diff).to eq("#{del 'old'}#{ins 'new'}")
    end

    it "compares complete links" do
      diff = Card::Diff.complete("[[A]]\n[[B]]", "[[A]]\n[[C]]", format: :html)
      expect(diff).to eq("[[A]]\n#{del '[[B]]'}#{ins '[[C]]'}")
    end

    it "compares complete nests" do
      diff = Card::Diff.complete("{{A}}\n{{B}}", "{{A}}\n{{C}}", format: :html)
      expect(diff).to eq("{{A}}\n#{del '{{B}}'}#{ins '{{C}}'}")
    end
  end

  context "raw format" do
    before(:all) do
      @opts = { format: :raw }
    end

    it "excapes html" do
      expect(p_diff).to eq("#{tag 'p'}#{del 'old'}#{ins 'new'}#{tag '/p'}")
    end

    it "diff for tag change" do
      expect(diff old_p, new_h).to eq(del("#{tag 'p'}old#{tag '/p'}") + ins("#{tag 'h1'}new#{tag '/h1'}"))
    end
  end

  context "pointer format" do
    before(:all) do
      @opts = { format: :pointer }
    end

    it "removes square brackets" do
      expect(diff "[[Hello]]", "[[Hi]]").to eq(del("Hello") + ins("Hi"))
    end
  end
end
