class CodenameTable < ActiveRecord::Migration
  def self.up
    create_table "codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    codecards = %w{
        *account *accountable *account_link *add_help *alert *all *all_plu
        *attach *autoname *bcc *captcha *cc *comment *community *content *count
        *create *created *creator *css *default *delete *edit_help *editing
        *editor *email *foot *from *head *home *includer *inclusion *incoming
        *input *invite *last_edited *layout *link *linker *logo *member
        *missing_link *navbox *now *option *option_label *outgoing *plu_card
        *plu_part *pluss *read *recent *referred_to_by *refer_to *related
        *request *right *role *rstar *search *self *send *sidebar *signup *star
        *subject *table_of_content *tagged *thank *tiny_mce *title *to
        *type *watching *type_plu_right *update *user *version *watcher
        *when_created *when_last_edited

        anyone_signed_in anyone administrator anonymous wagn_bot

        Basic Cardtype Date File Html Image AccountRequest Number Phrase
        PlainText Pointer Role Search Set Setting Toggle User
    }

    renames = {
        "AccountRequest"   => "InvitationRequest",
        "wagn_bot"         => "wagbot",
      }

    codecards.each do |name|
      c = Card[name]
      c ||= Card.as Card::WagbotID do
        Card.create! :name=>name
      end
      c or raise "Missing codename #{name} card"
      name = name[1..-1] if name[0] == '*'
      name = renames[name] if renames[name]
      Card::Codename.create :card_id=>c.id, :codename=>name
    end

    Card.reset_column_information
  end


  def self.down
    execute %{update cards as c set typecode = code.codename
                from codename code
                where c.type_id = code.card_id
      }

    change_column "cards", "typecode", :string, :null=>false

    drop_table "codenames"
  end
end
