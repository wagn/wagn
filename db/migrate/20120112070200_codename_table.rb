require 'wagn/cache'

class CodenameTable < ActiveRecord::Migration


  RENAMES = {
      "AccountRequest"   => "InvitationRequest",
      "wagn_bot"         => "wagbot",
    }
  CODENAMES = %w{
      *account *accountable *account_link *add_help *alert *all *all_plus
      *attach *autoname *bcc *captcha *cc *comment *community *content *count
      *create *created *creator *css *default *delete *edit_help *editing
      *editor *email *foot *from *head *home *includer *inclusion *incoming
      *input *invite *last_edited *layout *link *linker *logo *member
      *missing_link *navbox *now *options *option_label *outgoing *plus_card
      *plus_part *plus *read *recent *referred_to_by *refer_to *related
      *request *right *roles *rstar *search *self *send *session *sidebar
      *signup *star *subject *table_of_contents *tagged *thanks *tiny_mce
      *title *to *type *watching *type_plus_right *update *users *version
      *watchers *when_created *when_last_edited

      *declare *declare_help *sol *pad_options

      anyone_signed_in anyone administrator anonymous wagn_bot

      basic cardtype date file html image account_request number phrase
      plain_text pointer role search set setting toggle user
    } # FIXME: *declare, *sol ... need to be in packs

  def self.name2code(name)
    code = ?* == name[0] ? name[1..-1] : name
    code = RENAMES[code] if RENAMES[code]
    warn Rails.logger.warn("name2code: #{name}, #{code}, #{RENAMES[code]}"); code
  end
    
  def self.up
    Wagn::Cache.new_all

    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true
    change_column "cards", "type_id", :integer, :null=>false

    Card.as Card::WagbotID do
      CodenameTable::CODENAMES.each do |name|
        if card = Card[name] # || Card.create!(:name=>name)
          card or raise "Missing codename #{name} card"
        
          warn Rails.logger.warn("codename for #{name}, #{CodenameTable.name2code(name)}")
          Card::Codename.create :card_id=>card.id,
                                :codename=>CodenameTable.name2code(name)

        else warn Rails.logger.warn("missing card for #{name}")
        end
      end
    end

    Card.reset_column_information
  end


  def self.down
    execute %{update cards as c set typecode = code.codename
                from codename code
                where c.type_id = code.card_id
      }

    change_column "cards", "typecode", :string, :null=>false
    change_column "cards", "type_id", :integer, :null=>true

    drop_table "card_codenames"
  end
end
