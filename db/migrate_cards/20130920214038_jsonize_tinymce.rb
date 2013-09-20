# -*- encoding : utf-8 -*-

class JsonizeTinymce < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      card = Card[:tiny_mce]
      cleaned_rows = card.content.strip.split( /\s*\,\s+/ ).map do |row|
        key, val = row.split /\s*\:\s*/
        val.gsub! /\"\s*\+\s*\"/, ''
        val.gsub! "'", '"'
        val=%{"#{val}"} unless val=~/^\s*[\'\"]/;
        %("#{key}":#{val})
      end
      card.content = %({\n#{ cleaned_rows.join "\n" }\n})
      card.save!
    end
  end

  def down
    contentedly do
      
    end
  end
end
