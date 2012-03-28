class CodenameTable < ActiveRecord::Migration
  
  @@renames = {
    "AccountRequest"   => "InvitationRequest",
    "wagn_bot"         => "wagbot",
  }
  
  
  def self.up
    codenames = %w{
        *account *accountable *account_link *add_help *alert *all *all_plu
        *attach *autoname *bcc *captcha *cc *comment *community *content *count
        *create *created *creator *css *default *delete *edit_help *editing
        *editor *email *foot *from *head *home *includer *inclusion *incoming
        *input *invite *last_edited *layout *link *linker *logo *member
        *missing_link *navbox *now *option *option_label *outgoing *plu_card
        *plu_part *pluss *read *recent *referred_to_by *refer_to *related
        *request *right *role *rstar *search *self *send  *sidebar
        *signup *star *subject *table_of_content *tagged *thank *tiny_mce
        *title *to *type *watching *type_plu_right *update *version
        *watcher *when_created *when_last_edited

        anyone_signed_in anyone administrator anonymous wagn_bot

        Basic Cardtype Date File Html Image AccountRequest Number Phrase
        PlainText Pointer Role Search Set Setting Toggle User
      }
    
    #omitted: *session and *user
    
    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    codenames.each do |name|
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
    execute %{update cards as c set typecode = code.codename
                from codename code
                where c.type_id = code.card_id
      }

    change_column "cards", "typecode", :string, :null=>false

    drop_table "card_codenames"
  end
end
