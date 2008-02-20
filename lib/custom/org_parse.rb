require 'config/environment.rb'

class OrgParser
  include ActionView::Helpers::TextHelper
  attr_accessor :stream, :records, :current_record, :garbage, :broken
  TYPE=0
  VAL=1  
   
  module ::Card
    class Category < Base
      def topics
        Card.search( :type=>"Topic", :plus=>"_self", :_card=>self )
      end
    end

    class Category < Base
      def topics
        Card.search( :type=>"Topic", :plus=>"_self", :_card=>self )
      end
    end
  end
   
  def self.do_foundations
    Card.search( :type=>"Foundations", :limit=>20 ).each do |f|  
      puts "#{f.name}"
      Card.search( :type=>"Category", :plus=>"_self", :_card=>f).each do |cat|
        puts "  cat: #{cat.name}"
        cat.topics.each do |t|
          puts "    t: #{t.name}"
        end
      end
    end
  end

  def self.do_all    
    User.as :admin
    p = OrgParser.new
    p.do_cards( p.who_knows_cards, false ); ''
    p.do_cards( p.resource_and_contacts_cards, false ); ''

    p.do_address_cards
    p.do_counties
    p.do_cities

    Card['who knows most'].update_attributes! :name=>'who knows most old', :confirm_rename=>true
    Card['who knows most new'].update_attributes! :name=>'who knows most', :confirm_rename=>true
  end

  def initialize
    self.garbage = []
    self.broken = []
  end
     

  def do_counties
    Card.search( :type=>"County" ).each_with_index do |card,index|
      card.name = card.name + ", OR"
      card.confirm_rename = true
      card.save!
      
      Card::Pointer.create! :name=>"#{card.name}+in state", :content=>"[[Oregon]]"
      
      puts "#{index} #{card.name}"
    end
  end
  
  def do_cities
    Card.search( :type=>"Community" ).each_with_index do |card,index|
      county = Card.search( :type=>"County", :plus=>card.name ).first
      cities = Card.search( :type=>"City", :plus=>card.name)
      
      incorporated = (card.name =~ /^Inc/) ? "yes" : "no"
      
      cities.each do |city|
        city.name = city.name + ", OR"
        city.confirm_rename = true
        city.save!
        
        Card::Pointer.create! :name=>"#{city.name}+in county", :content=>"[[#{county.name}]]"
        
        Card::PlainText.create! :name=>"#{city.name}+incorporated", :content=>incorporated
      end
      puts "#{index} #{card.name}"
    end
  end
   
  def do_address_cards
    Card.search( :right=>"address", :left=>{:type=>"Organization"}).each_with_index do |card, index|
      begin
		 orgname, city, zip = card.name.parent_name, nil, nil  
      
      new_content = card.content.split("<br>").map {|x| x.gsub(/&nbsp;/,' ')}.map do |line|
        if line=~/^(.*)(\d{5}$|\d{5}-\d{4})$/
          zip = $2.strip
          city = $1.strip.gsub(/Oregon/i,'OR').gsub(/D\.C\./,'DC')
          nil
        else 
          line
        end
      end.compact.join("<br>")

      Card::Pointer.create!( :name=>"#{orgname}+location", :content=>"[[#{city}]]")  unless city.nil?
      #Card::PlainText.create!( :name=>"#{orgname}+zip", :content=>zip  )  unless zip.nil?    
      #card.content = new_content
      #card.save!
      
      puts "#{index} #{orgname}"
		rescue Exception=>e
		  puts "#{index} #{orgname} **Error** #{e.message}"
		end
    end
    ''
  end
   
   
  def who_knows_cards
    Card.search( :part=>"who knows most", :sort=>"alpha" ).reject{|c| c.content.size < 12 }.sort_by{|x| x.name} 
  end
  
  def resource_and_contacts_cards
    Card.search( :part=>"Oregon Resources and Contacts", :sort=>"alpha" ).reject{|c| c.content.size < 12 }.sort_by{|x| x.name}  
  end
  
  def do_cards(cards, who_knows_most=false)
    User.as :admin
    count = 0
    cards.each do |card|
      begin 
        names=""
        topic = card.name.parent_name
        extract_records(card).each do |rec|
          names << "[[#{rec[:name]}]]\n"
          rec[:topic]=topic
          count += 1; print "#{count} "
          c = create_org_card(rec)    
          puts "#{topic}: #{rec[:name]}"
        end                                                                                    
        if who_knows_most
          Card::Pointer.find_or_create!( :name=>"#{topic}+who knows most new", :content=>names )    
          #puts "   created #{topic}+who knows most new, #{names}"
        end
      rescue Exception=>e
        puts "BUSTED ON #{topic}: #{e.message}"   
        self.broken << "#{topic}: #{e.message}"
      end
    end
    true
  end
  
  def get_cards
    cs =  Card.search( :part=>"Oregon Resources and Contacts" ) + Card.search( :part=>"who knows most" )
    cs
  end

  
  def extract_records(card)
    orgs = parse(lexify(chunk(card.content)))
    orgs.each {|o| o[:topic]=card.name.parent_name }
    orgs
  end
  
  def create_org_card(o)
    name=o[:name]
    Card::Organization.find_or_create! :name=>name
    Card::PlainText.find_or_create!( :name=>"#{name}+phone",            :content=>o[:phone]   ) if o[:phone]  
    Card.find_or_create!( :name=>"#{name}+email",            :content=>o[:email]   ) if o[:email]
    Card.find_or_create!( :name=>"#{name}+website",          :content=>o[:web]     ) if o[:web]
    Card::PlainText.find_or_create!( :name=>"#{name}+main contact",     :content=>o[:person]  ) if o[:person]
    Card.find_or_create!( :name=>"#{name}+description",                 :content=>o[:desc]    ) if o[:desc]
    Card.find_or_create!( :name=>"#{name}+address",                     :content=>o[:address] ) if o[:address]
    if o[:topic]
      topic_pointer = Card::Pointer.find_or_create! :name=>"#{name}+topics of interest", :content=>""
      topic_pointer.content += "\n[[#{o[:topic]}]]"
      topic_pointer.save!
    end
  end

  
  def lexify(chunks)
    chunks.map do |chunk|
      stripped = strip_tags(chunk).strip
      type = case
        when stripped == 'Amy Ward';    'AUTHOR'         
        when stripped == '';            'BLANK' 
        when stripped =~ /^[x\d\.\-\(\)\s]+$/; 'PHONE'
        when stripped =~ /http/;        'WEB'
        when stripped =~ /^\S+\@\S+$/;  'EMAIL' 
        when stripped =~ /(^\d+|\d+$)/; 'ADDRESS'
        when chunk =~ /<strong>|<b>/
          stripped =~ /:/ ? 'PERSON' : 'NAME'
        when (stripped =~ /^\"/ or  stripped.length > 100);        'DESC'            
        else;                           'UNKNOWN'
      end
      #puts "#{type}: #{stripped}" if type
      [type.downcase.to_sym, stripped]
    end<< [:eof,nil]
  end
  
  def chunk(text)
    text.split(/<br>/).map{ |x| x.strip.gsub(/\s+/, ' ') }.compact
  end
                 
  ## foundation parser -------------------------------------------- ##
  def parse_foundation(tokens)
    self.stream = tokens.clone
    self.records=[]
    get_foundations
    records
  end       
  
  def get_foundation()
    # FIXME: this is not done
    start_record
    while cursym!=:eof
      if cursym==:blank
        accept(:blank)
      elsif cursym==:name
        accept(:name)
      elsif non_blank.include?(cursym)
        get_garbage()
      else
        raise "parse error: expected type #{cursym}"
      end
    end
    finish_record
  end

  ## org parser toolset --------------------------------------------------- ##
  def parse(tokens)
    self.stream = tokens.clone
    self.records=[]
    get_records
    records
  end

  def non_blank
    %w{ phone web email address person desc unknown author }.plot(:to_sym)
  end                                                     
  
  def get_record
    start_record
    accept(:name)
    while accept( *non_blank ); end
    
    accept( :blank )
    if accept( :web )
      while accept( *non_blank ); end
      accept( :blank )
    end
    finish_record
  end       
  

  def expect( *types )
    if accept( *types )
      return true
    end
    raise "Parser error: wasn't expecting #{cursym}"      
  end

  def accept( *types )
    if types.include?(cursym) 
      add_to_record(cursym, curval)  
      gone = stream.shift
      #warn "-#{gone[TYPE]}: #{gone[VAL]}"
      return cursym
    end
    return false
  end                    
  
  def cursym() stream.first[TYPE]; end
  def curval() stream.first[VAL]; end

  def start_record
    raise "start_record: current_record already exists" unless current_record.nil?
    self.garbage << {}
    self.current_record = {}
  end
   
  def add_to_record(type, val) 
    return if [:author,:unknown,:blank].include?(type)
    if current_record
      current_record[type]||=""
      if !current_record[type].blank?
        current_record[type]+="<br>"
      end
      current_record[type]+=val
    else
      garbage.last[type]||=""
      garbage.last[type]+=val
    end
  end
     
  def finish_record
    raise "finish_record: current_record does not exist" unless current_record
    records.push current_record
    self.current_record = nil
  end
  
  # parser states   
  def get_records()
    while cursym!=:eof
      if cursym==:blank
        accept(:blank)
      elsif cursym==:name
        get_record()
      elsif non_blank.include?(cursym)
        get_garbage()
      else
        raise "parse error: expected type #{cursym}"
      end
    end
  end

  def get_garbage
    while accept( *non_blank ); end
  end
  
end
