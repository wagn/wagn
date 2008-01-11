class OrgParser
  include ActionView::Helpers::TextHelper
  attr_accessor :stream, :records, :current_record, :garbage
  TYPE=0
  VAL=1  
    
  def do_all
    User.as :admin
    count = 0
    get_cards.each do |card|
      extract_records(card).each do |rec|
        count += 1
        print "#{count} "
        create_org_card(rec)
      end
    end
  end
  
  
  def get_cards
    cs =  Card.search( :part=>"Oregon Resources and Contacts" ) + Card.search( :part=>"who knows most" )
    cs.reject! {|c| c.content.size < 12 }
    cs
  end


  def parse(tokens)
    self.garbage = {}
    self.stream = tokens.clone
    self.records=[]
    get_records
    records
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
    Card::PlainText.find_or_create!( :name=>"#{name}+email",            :content=>o[:email]   ) if o[:email]
    Card::PlainText.find_or_create!( :name=>"#{name}+website",          :content=>o[:website] ) if o[:website]
    Card::PlainText.find_or_create!( :name=>"#{name}+main contact",     :content=>o[:person]  ) if o[:person]
    Card.find_or_create!( :name=>"#{name}+description",                 :content=>o[:desc]    ) if o[:desc]
    Card.find_or_create!( :name=>"#{name}+address",                     :content=>o[:address] ) if o[:address]
    topic_pointer = Card::Pointer.find_or_create! :name=>"#{name}+topics of interest", :content=>""
    topic_pointer.content += "\n[[#{o[:topic]}]]"
    topic_pointer.save!
    puts "#{o[:topic]}: #{name}"
  rescue Exception=>e
    puts "BUSTED ON #{name}: #{e.message}"
  end

  
  def lexify(chunks)
    chunks.map do |chunk|
      stripped = strip_tags(chunk).strip
      type = case
        when stripped == 'Amy Ward';    'AUTHOR'         
        when stripped == '';            'BLANK' 
        when stripped =~ /^[\d\.\-]+$/; 'PHONE'
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
  
  
  # parser toolset
  def non_blank
    %w{ phone web email address person name desc unknown author }.plot(:to_sym)
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
      garbage[type]||=""
      garbage[type]+=val
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
        raise "expected type #{cursym}"
      end
    end
  end

  def get_garbage
    while accept( *non_blank ); end
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
  
  def text2
    %{
      
      <span><em></em><strong>Oregon Media Insiders</strong><br>This
      is a news blog common-ground that can be subscribed to, contributed to,
      and viewed by everyone, covering mainly only Oregon news.<br><br><a class="external-link" href="http://www.oregonmediainsiders.com">http://www.oregonmediainsiders.com</a><br><a class="email-link" href="mailto:desk@oregonmediainsiders.com">desk@oregonmediainsiders.com</a><br><br><strong>Portland Independent Media Center</strong><br>"Portland
      Indymedia is an IMC for the southern Cascadia region of Turtle Island
      (an area temporarily demarcated as "Oregon" and southern "Washington"
      on some maps). Indymedia activism can take many forms, but is rooted in
      the Indymedia Principles of Unity which profess that the open exchange
      of and open access to information is a prerequisite to the building of
      a more free and just society."<br><br><a class="external-link" href="http://portland.indymedia.org">http://portland.indymedia.org</a><br><a class="email-link" href="mailto:imc-portland-requests@lists.indymedia.org">imc-portland-requests@lists.indymedia.org</a><br><br><strong>Oregon Alliance to Reform Media</strong><br>"Oregon
      ARM is a working group that was created to promote a responsive and
      responsible, public-interest media environment in Oregon.&nbsp; Oregon ARM
      offers educational opportunities, forums, advocacy opportunities and
      initiatives so that Oregon ARM members and the local community stay
      current on public policy media reforms that promote localism and
      diversity."<br><br><a class="external-link" href="http://www.oregonarm.org">http://www.oregonarm.org</a><br><b>Contact: Janice Thompson</b><br><strong>503.283.1922</strong><br><a class="email-link" href="mailto:jthompson@oregonfollowthemoney.org">jthompson@oregonfollowthemoney.org</a><br><br><strong>Portland Media Works</strong><br>"Our
      mission is to energize democracy through the production and
      distribution of public interest videos and new media. Our documentary
      stories, civic art projects and screening events provide
      under-represented voices the opportunity to speak and be heard, while
      inspiring audiences to become deeply engaged in their communities."<br><br><a class="external-link" href="http://www.publicmediaworks.org">http://www.publicmediaworks.org</a><br>333 SE 2nd Ave, Second Floor<br>Portland, Oregon 97214<br><strong>971.404.1760 </strong><br><a class="email-link" href="mailto:info@publicmediaworks.org">info@publicmediaworks.org</a><br><br><strong>Cinema Project</strong><br></span>"Cinema Project is a collectively run, nonprofit organization committed
      to promoting innovative film and video art from the past and present.
      Through screenings and lectures we work to foster an informed viewing
      public that will support the wider circulation and critical
      appreciation of film and video art."<br><br><a class="external-link" href="http://cinemaproject.org">http://cinemaproject.org</a><br>PO Box 5991 <br>
      							Portland, OR 97228 <br><strong>503.232.8269</strong><br><span><a class="email-link" href="mailto:info@cinemaproject.org">info@cinemaproject.org</a><br><br></span><a class="known-card" href="/wagn/Amy_Ward">Amy Ward</a><br><br>
    }    
  end
  
  
  def text1
    %{
    <em></em><strong>Oregon Center for Public Policy</strong><br>
    OCPP does in-depth research and
    analysis on budget, tax, and economic issues. The goal is to improve
    decision making and generate more opportunities for all
    Oregonians.&nbsp; OCPP uses research and analysis to advance policies
    and practices that
    improve the economic and social opportunities of all Oregonians. - <a class="known-card" href="/wagn/Amy_Ward">Amy Ward</a><br>
    <br>
    <a class="external-link" href="http://www.ocpp.org/cgi-bin/display.cgi?page=resources">http://www.ocpp.org/cgi-bin/display.cgi?page=resources</a><br><strong>
    503.873.1201</strong><br>
    OCPP, PO Box 7, Silverton, OR 97381-0007<br>
    <a class="email-link" href="mailto:info@ocpp.org">info@ocpp.org</a>
    <br>
    <br>
    <p><strong>University of Oregon - Department of Public Policy</strong></p><br>
    <p>" The Department of Planning, Public Policy &amp;
    Management prepares future public leaders, creates and disseminates new
    knowledge, and assists communities and organizations. PPPM's faculty,
    staff, and students seek to understand and improve economic,
    environmental, and social conditions through our teaching, scholarship,
    and public service."<br>
     </p><br>
    <p> <a class="external-link" href="http://pppm.uoregon.edu/index.cfm">http://pppm.uoregon.edu/index.cfm</a><br>
     <strong>541.346.3635</strong><br>
    <span>Department of Planning, Public Policy &amp; Management<br>
    						1209 University of Oregon<br>
    						119 Hendricks Hall<br>
    </span><span>
    						Eugene, OR 97403-1209<br>
    </span><span></span><a class="email-link" href="mailto:pppm@uoregon.edu">pppm@uoregon.edu</a><br>
    </p><br>
    <br>
    <strong>Portland State University - Hatfield School of Government</strong><br>
    "The Division of Public Administration offers a professionally oriented
    program that focuses on the study of government, health, and non-profit
    organizations and their management."<br>
    <br>
    <a class="external-link" href="http://www.hatfieldschool.pdx.edu/PA/pub_admin.php">http://www.hatfieldschool.pdx.edu/PA/pub_admin.php</a><br><b>
    Department Chair:  
    Neal Wallace</b><br><strong>

    503-725-8248</strong><br>
    <a class="email-link" href="mailto:shinnc@pdx.edu">nwallace@pdx.edu</a><br><br>
    <a class="known-card" href="/wagn/Amy_Ward">Amy Ward</a><br>
    <strong></strong>
    <br> 
    }
  end
  
end