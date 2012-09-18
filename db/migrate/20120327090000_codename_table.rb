#require 'wagn/cache'

class CodenameTable < ActiveRecord::Migration

  RENAMES = {
      "search"            => "search_type",
      "layout"            => "layout_type"
    }
  CODENAMES = %w{
    
      *all *default basic
        
      cardtype date file html image account_request number phrase
      plain_text pointer role search set setting toggle user layout
    
      *all_plus *star *rstar *type *type_plus_right *right *self
      
      *add_help *accountable *autoname *captcha *comment *content *create *default *delete
      *edit_help *option *option_label *input *layout *read *send *table_of_contents *thanks *update 
      
      anyone_signed_in anyone administrator anonymous wagn_bot
      
      *account *roles *email
      
      *home *title *tiny_mce
      
      *account_links *alert *version *foot *head *when_created *when_last_edited *navbox
      
      *attach *bcc *cc *from *subject *to 
      
      *css *now *recent *related
      
      *watchers *search
      
      *invite *signup *request 

      *double_click *favicon *logo

    } 

# not referred to in code:
#  *incoming *tagged *community *count *editing *editor *outgoing *plus_part *refer_to *member *sidebar
#  *created *creator *includer   *inclusion  *last_edited *missing_link *session *link *linker 
#  *referred_to_by *plus_card *plus *watching *users 

# need to be in packs    
#  *declare *declare_help *sol *pad_options etherpad


  # still a bit of a wart, but at least it is mostly here in migrations
  @@have_codes = nil
  # I don't understand why this is needed.  At this point they shouldn't have codes.  -efm

  YML_CODE_FILE = 'db/bootstrap/cards.yml'
  
  
  
  def self.up
    remove_index "cards", :name=>"card_type_index"
    change_column "cards", "typecode", :string, :null=>true
    change_column "cards", "type_id", :integer, :null=>false
    add_index "cards", ["type_id"], :name=>"card_type_index"

    Card.reset_column_information
    Wagn::Cache.reset_global 

    @@have_codes = !Wagn::Codename[:wagn_bot].nil?
    warn Rails.logger.warn("have_codes #{@@have_codes}")
    CodenameTable.load_bootcodes unless @@have_codes

    Session.as_bot do
      CodenameTable::CODENAMES.each do |name|
        CodenameTable.add_codename name
      end
#      warn Rails.logger.warn("migr opt test #{Card['cardtype_a']}")
#      if Card['cardtype_a']
#        CodenameTable::OPT_CODENAMES.each { |name| CodenameTable.add_codename name, true }
#      else warn Rails.logger.warn("migr skip optionals") end
    end
    Wagn::Codename.reset_cache
  end


  def self.down
    execute %{update cards as c 
                 set typecode = code.codename
                from codename code
               where c.type_id = code.card_id }

    remove_index "cards", :name=>"card_type_index"
    change_column "cards", "type_id", :integer, :null=>true
    change_column "cards", "typecode", :string, :null=>false
    add_index "cards", ["typecode"], :name=>"card_type_index"
  end
  
  
  def self.load_bootcodes
    codehash = {}
    # seed the codehash so that we can bootstrap
    #puts "yml load, #{caller*"\n"}"
    if File.exists?( YML_CODE_FILE ) and yml = YAML.load_file( YML_CODE_FILE )
      yml.each do |p|
        next unless codename = p[1]['codename']
        code, id = codename.to_sym, p[1]['id'].to_i
        codehash[code.to_sym] = id.to_i; codehash[id.to_i] = code.to_sym
      end
    else
      puts Rails.logger.warn("no file? #{YML_CODE_FILE}")
    end

    #warn Rails.logger.warn("code cache: #{codehash.inspect}\n")
    Wagn::Codename.bootdata(codehash)
  end

  def self.name2code name
    code = if RENAMES[name];  RENAMES[name]
       elsif '*' == name[0];  name[1..-1]
       else                   name end
    Rails.logger.warn("migr name2code: #{name}, #{code}, #{RENAMES[code]}"); code
  end
    
  def self.check_codename name
    if @@have_codes == false
      false
    else
      @@have_codes = !Wagn::Codename[:wagn_bot].nil? and
        card = Card[name] and card.id == Wagn::Codename[CodenameTable.name2code(name)]
    end
  end

  # opt=true is: don't create when missing, default is to create it
  def self.add_codename name, opt=false
    if check_codename(name)
      Rails.logger.warn("migr good code #{name}, #{c=Card[name] and c.id}")
    else
      card = Card[name]
      
      if !card
        Wagn::Codename.reset_cache
#        return false if opt
        puts Rails.logger.warn "adding card for codename #{name}"
        card = if name=='*double_click'
          Card.create! :name=>'*double click', :type=>'Toggle', :content=>'1'
        else
          Card.create! :name=>name
        end
        card or raise "Missing codename #{name} card"
      end

      newname = CodenameTable.name2code(name)
      #Card.where(:id=>card.id).update_all(:codename=>nil) # should not be possible, right?

      Rails.logger.warn("migr codename for [#{card.id}] #{name}, #{newname}")
      Card.where(:id=>card.id).update_all(:codename=>newname)
    end
  end

end
