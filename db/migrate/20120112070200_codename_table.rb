class CodenameTable < ActiveRecord::Migration
  
  @@renames = {
    "AccountRequest"   => "InvitationRequest",
    "wagn_bot"         => "wagbot",    
  }
  
  def self.up
    cardnames = %w{
      
      *accountable *add_help *autoname *captcha *comment *content
      *create *default *delete *edit_help *input *layout *option *option_label
      *read *send *thank *table_of_content *update
      
      *all *all_plus *right *rstar *self *star *type *type_plus_right
      
      *account_link  *head *logo *navbox *sidebar *version
      
      *css *tiny_mce
      
      *attach *bcc *cc *from *subject *to 
       
      *account *email *home *invite *now *recent *related *request *role
      *search *signup *title *watcher *when_created *when_last_edited

      anyone_signed_in anyone administrator anonymous wagn_bot

      Basic Cardtype Date File Html Image AccountRequest Number Phrase
      PlainText Pointer Role Search Set Setting Toggle User
    }
    
    # left out: *community, *creator, *editor, *editing, *count,   *includer *inclusion *incoming, *last_edited
    #           *link  *linker *member *missing_link  *outgoing *plu_card *plu_part *pluss *referred_to_by *refer_to
    #           *tagged *watching 
    # delete: *alert, *foot, 
    
    
    #omitted: *session and *user
    
    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    cardnames.each do |name|
      if card = Card[name] # || Card.create!(:name=>name)
        Card::Codename.create :card_id=>card.id, :codename=>name2code(name)
      else
        raise "Missing codename #{name} card"
        #puts "missing card for #{name}"
      end
    end
    Wagn::Cache.reset_global
    Card::Codename.reset_cache

    Card.reset_column_information
  end


  def name2code(name)
    code = ?* == name[0] ? name[1..-1] : name
    code = @@renames[code] if @@renames[code]
    warn Rails.logger.warn("name2code: #{name}, #{code}, #{@@renames[code]}")
    code
  end


  def self.down
    execute %{
      update cards as c set typecode = code.codename
      from codename code
      where c.type_id = code.card_id
    }

    change_column "cards", "typecode", :string, :null=>false

    drop_table "card_codenames"
  end
end
