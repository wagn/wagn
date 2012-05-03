#require 'wagn/cache'

class CodenameTable < ActiveRecord::Migration


  RENAMES = {
      "account_request"   => "invitation_request",
      "wagn_bot"          => "wagbot",
      "*search"           => "xsearch",
      "layout"            => "layout_type"
    }
  CODENAMES = %w{
      *account *accountable *account_link *add_help *alert *all *all_plus
      *attach *autoname *bcc *captcha *cc *comment *community *content *count
      *create *created *creator *css *default *delete *edit_help *editing
      *editor *email *foot *from *head *home *includer *inclusion *incoming
      *input *invite *last_edited *layout *link *linker *logo *member
      *missing_link *navbox *now *option *option_label *outgoing *plus_card
      *plus_part *plus *read *recent *referred_to_by *refer_to *related
      *request *right *roles *rstar *search *self *send *session *sidebar
      *signup *star *subject *table_of_contents *tagged *thanks *tiny_mce
      *title *to *type *watching *type_plus_right *update *users *version
      *watchers *when_created *when_last_edited

      *declare *declare_help *sol *pad_options etherpad

      anyone_signed_in anyone administrator anonymous wagn_bot

      *double_click *favicon

      basic cardtype date file html image account_request number phrase
      plain_text pointer role search set setting toggle user layout
    } # FIXME: *declare, *sol ... need to be in packs

  OPT_CODENAMES = %w{cardtype_a cardtype_b cardtype_c cardtype_d cardtype_e cardtype_f}

  def self.name2code name
    code = if RENAMES[name];  RENAMES[name]
       elsif '*' == name[0];  name[1..-1]
       else                   name end
    Rails.logger.warn("migr name2code: #{name}, #{code}, #{RENAMES[code]}"); code
  end
    
  def self.check_codename name
    card = Card[name] and card.id == Card::Codename[CodenameTable.name2code(name)]
  end

  def self.add_codename name, opt=false
    unless Card::Codename.no_db || !check_codename(name)
      Rails.logger.warn("migr good code #{name}, #{c=Card[name] and c.id}")
      return
    end
    if card = Card[name] || (!opt && Card.create!(:name=>name))
      card or raise "Missing codename #{name} card"

      # clear any duplicate on name or id
      newname = CodenameTable.name2code(name)
      Card::Codename.where(:card_id=>card.id).delete_all
      Card::Codename.where(:codename=>newname).delete_all

      Rails.logger.warn("migr codename for [#{card.id}] #{name}, #{newname}")
      Card::Codename.create :card_id=>card.id, :codename=>newname

    elsif !opt; warn(Rails.logger.warn "missing card for #{name}")
    end
  end

  def self.up
    create_table "card_codenames", :force => true, :id => false do |t|
      t.integer  "card_id", :null => false
      t.string   "codename", :null => false
    end

    remove_index "cards", :name=>"card_type_index"
    change_column "cards", "typecode", :string, :null=>true
    change_column "cards", "type_id", :integer, :null=>false
    add_index "cards", ["type_id"], :name=>"card_type_index"

    Card.reset_column_information
    Wagn::Cache.new_all

    Card.as Card::WagbotID do
      CodenameTable::CODENAMES.each { |name| CodenameTable.add_codename name }
      warn Rails.logger.warn("migr #{Rails.configuration.inspect}")
      if Rails.configuration == 'test'
        CodenameTable::OPT_CODENAMES.each { |name| CodenameTable.add_codename name, true }
      else warn Rails.logger.warn("migr skip optionals #{Rails.configuration.inspect}") end
    end
  end


  def self.down
    execute %{update cards as c set typecode = code.codename
                from codename code
                where c.type_id = code.card_id
      }

    remove_index "cards", :name=>"card_type_index"
    change_column "cards", "type_id", :integer, :null=>true
    change_column "cards", "typecode", :string, :null=>false
    add_index "cards", ["typecode"], :name=>"card_type_index"

    drop_table "card_codenames"
  end
end
