class TagRevision < ActiveRecord::Base
  belongs_to :tag
  belongs_to :created_by, :class_name => "User", :foreign_key =>"created_by"
  
  validates_presence_of :name
  validates_format_of :name, :with=>/^([^+_~\/])*$/, :message=>"may not contain ~,+,_ or /"
  validates_each( :name, :on=>:create ) do |record, attr_name, value|
    if Tag.find_by_name(value)
      record.errors.add('name', 'already exists')
    end
  end
  
end
