require 'diff/lcs'

module ActiveRecord
  class Base
      
    def update_record_without_timestamping
      class << self
        def record_timestamps; false; end
      end
      
      save!
      
      class << self
        remove_method :record_timestamps
      end
    end
    
  end
end

module DiffPatch
  extend self
  def diff(a,b)
    Diff::LCS.diff(a.to_words, b.to_words ).flatten.map do |d| 
      "#{d.action}#{d.position}:#{d.element}" 
    end.join("|;")
  end

  def patch(oldstring,diff)
    lcs_diffs = diff.split("|;").map do |x| 
      m,a,p,e = x.match(/^([\+\-])(\d+):(.*)$/).to_a
      Diff::LCS::Change.new(a,p.to_i,e) 
    end
    Diff::LCS.patch!(oldstring.to_words, lcs_diffs).join("")
  end
end
  
class RevisionMerger
  attr_accessor :card
  
  def initialize card
    @card = card
  end
  
  def dump
    data = []
    @card.revisions.each_with_index do |rev,i|
      prev_content = i==0 ? "" : @card.revisions[i-1].content
      diff_string = DiffPatch.diff( prev_content, rev.content )
      author = rev.author.card.name
      updated = rev.updated_at.xmlschema(6)
      data << [updated, author, diff_string].join("::")
    end
    data
  end

  def load data
    data.each do |line|
      updated_str, author_name, diff = line.split_twice("::")
      time = Time.parse(updated_str)
      author = Card[author_name].extension
      if @card.revisions.find_by_updated_at_and_created_by(time, author)
        Rails.logger.debug "RevisionMerger( #{@card.name} )" +
          " skipping #{author_name}:#{updated_str}"
      else
        newcontent = DiffPatch.patch(@card.content, diff)
        Rails.logger.debug "RevisionMerger( #{@card.name} )" +
          " adding #{author_name}:#{updated_str}  --> #{newcontent[0..20]}" +
          (newcontent.size > 20 ? "..." : "")
        @card.update_attributes :content => newcontent
        cr = @card.current_revision
        cr.updated_at = time
        cr.created_by = author
        cr.update_record_without_timestamping
      end
    end
  end
end

module CardMerger  
  extend self
  
  def dump cardnames
    data = {}
    cardnames.each do |cardname|
      c = Card[cardname]
      data[cardname] = {
        'type' => c.type,
        'revisions' => RevisionMerger.new( Card[cardname] ).dump
      }
    end
    YAML.dump(data)
  end
  
  def load data
    YAML.load(data).each do |cardname, data|
      c = Card.find_or_create :name => cardname, :type => data['type']
      RevisionMerger.new(c).load( data['revisions'] )
    end
  end
end

class String
  def to_words
    HTMLDiff::DiffBuilder.new("","").convert_html_to_list_of_words( self )
  end
  
  def split_twice delim
    a = self.split delim
    [a[0],a[1],a[2..-1].join(delim)]
  end
end