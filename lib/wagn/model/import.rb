=begin
require 'csv'

module Wagn::Model::Import
  class << self
    def csv(opts={})
      csv = CSV.parse(opts[:data])
      fields = csv.shift
      
      name_index = 0 #fields.index(opts[:name_field]) || raise("name field '#{opts[:name]}' not found")
      content_index = nil #opts[:content_field] ? fields.index(opts[:content_field]) : nil
      
      csv.each do |record|
        # do name field
        next if record[name_index].strip.blank?
        base_card = Card.create :typecode=>opts[:cardtype], :name=>record[name_index].strip, :content=>(content_index ? record[content_index].strip : "")
        
        record.each_with_index do |value, index|
          next if ( index == name_index or index == content_index )
          Card.create :name=> "#{base_card.cardname}+#{fields[index].strip}", :content=>(value ? value.strip : '')
        end
      end
    end 
  end
end
=end
