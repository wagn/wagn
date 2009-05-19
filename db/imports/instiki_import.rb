module InstikiImport
  DB = {
    :adapter => "postgresql",
    :host => "localhost",
    :username => "herd",
    :password => "herd",
    :database => "instiki_dev"
  }
  
  class Card < ActiveRecord::Base
    self.establish_connection DB
    belongs_to :web
    has_many :revisions, :order => 'id'
    #has_many :wiki_references, :order => 'referenced_name'
    has_one :current_revision, :class_name => 'Revision', :order => 'id DESC'
    
    def method_missing(method_id, *args, &block)
      method_name = method_id.to_s
      # Perform a hand-off to AR::Base#method_missing
      if @attributes.include?(method_name) or md = /(=|\?|_before_type_cast)$/.match(method_name)
        super(method_id, *args, &block)
      else
        current_revision.send(method_id)
      end
    end
  end

  class Revision < ActiveRecord::Base
    self.establish_connection DB
    belongs_to :card
    composed_of :author, :mapping => [ %w(author name), %w(ip ip) ]
  end  
  
  class Importer
    def initialize
      warn "Connecting to #{DB[:database]}"
      User.as :wagbot
    end
    
    def import_cards( add_to_existing=false)
      Card.find_all_by_web_id(4).each_with_index do |instiki_card,i|
        if wagn_card = ::Card.find_by_name( instiki_card.name )
          if add_to_existing
            warn "#{i} #{instiki_card.name} (update)"
            wagn_card.revise( wagn_card.content + instiki_card.content )
          end
        else
          warn "#{i} #{instiki_card.name}"
          card = ::Node.create( 'Wiki', instiki_card.name, '' ).tag.root_card
          begin
            card.revise( instiki_card.content )
          rescue Exception=>e
            warn "#{e.class} #{e.message}"
            card.revise("Card had errors on Import: please see http://staff/show/#{instiki_card.name}")
          end
        end
      end
    end
  end
  
end
