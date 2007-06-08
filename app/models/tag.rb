class Tag < ActiveRecord::Base
  has_one :root_card, :class_name=>'Card::Base', :conditions => "trunk_id IS NULL"
  has_many :cards, :class_name=>'Card::Base', :conditions=>"trunk_id IS NOT NULL", :dependent=>:destroy
  
  belongs_to :current_revision, :class_name=>'TagRevision', :foreign_key=>'current_revision_id'
  has_many :revisions, :class_name => 'TagRevision', :order => 'id', :dependent=>:destroy

  belongs_to :created_by, :class_name=>"::User", :foreign_key=>"created_by"
  belongs_to :updated_by, :class_name=>"::User", :foreign_key=>"updated_by"
  
  attr_reader :update_links
    
  def just_renamed? 
    @just_renamed 
  end
  
  def previous_name
    # note previous name is also set when tag is renamed
    @previous_name ||=  revisions[1].name
  end
  
  def name
    if cr = current_revision
      cr.name
    else
      @initial_name
    end
  end
  
  def name=( new_name )
    if new_record?
      @initial_name = new_name
    else
      rename(new_name)
    end
  end
  
  def rename(new_name, update_links=false)
    if new_name == current_revision.name
      raise Wagn::Oops.new( "Name was not changed")
    end
    @previous_name = current_revision.name
    @just_renamed = true
    @update_links = update_links
    self.current_revision = TagRevision.create!( :tag_id=>self.id, :name=>new_name )
    self.save!  # save current_revision_id
    @just_renamed = false
    self
  end

  def recent_revisions(interval)
    if ActiveRecord::Base.connection.adapter_name == "SQLite"
      # this code is theoretically db agnostic, but it broke a test in mysql, so now theres an if..
      split_interval = interval.split
      min_time = eval("#{split_interval[0]}.#{split_interval[1]}.ago")
      recent_revs = revisions.find(:all, :conditions=>["created_at > '#{min_time}'"])
    else
      recent_revs = revisions.find(:all, :conditions=>["created_at > now() - #{self.connection.quote_interval(interval)}"])
    end
    revs = []
    if recent_revs.length > 0 then
      revs = revisions.find(:all, :order=>"created_at DESC", :limit=>recent_revs.length+1)
      revs.shift
    end
    revs
  end
  
  class << self
    def find_by_name( name )
      Tag.find :first,
        :select => "tags.*",
        :joins => "join tag_revisions tr on tr.id=tags.current_revision_id",
        :conditions => ["name = ?", name],
        :readonly => false
    end

    def find_all_by_name( name )
      Tag.find :all,
        :select => "tags.*",
        :joins => "join tag_revisions tr on tr.id=tags.current_revision_id",
        :conditions => ["name = ?", name],
        :readonly => false
    end
  end

end
