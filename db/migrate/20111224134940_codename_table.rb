class CodenameTable < ActiveRecord::Migration
  def self.up
    create_table "codename", :force => true do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    change_column "cards", "typecode", :string, :null=>true

    codecards = %w{
        *account *accountable *account_link *add_help *alert *all *all_plu
        *attach *autoname Basic *bcc *captcha Cardtype *cc *comment *community
        *content *count *create *created *creator *css Date *default *delete
        *edit_help *editing *editor *email File *foot *from *head *home Html
        Image *includer *inclusion *incoming *input AccountRequest *invite
        *last_edited *layout *link *linker *logo *member *missing_link *navbox
        *now Number *option *option_label *outgoing Phrase PlainText *plu_card
        *plu_part *pluss Pointer *read *recent *referred_to_by *refer_to
        *related *request *right *role Role *rstar *search Search *self *send
        Set Setting *sidebar *signup *star *subject *table_of_content *tagged
        *thank *tiny_mce *title *to Toggle *type *type_plu_right *update
        User *version *watcher *watching *when_created *when_last_edited
    }
    renames = {"AccountRequest" => "InvitationRequest"}

    codecards.map { |name|
         c = Card[name] or raise "Missing codename #{name} card"
         name = renames[name] if renames[name]
         Wagn::Codename.insert(c.id, name)
       }
  end


  def self.down
    change_column "cards", "typecode", :string, :null=>false

    drop_table "codename"
  end
end
