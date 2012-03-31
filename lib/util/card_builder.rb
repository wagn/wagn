module CardBuilderMethods
  ## ug
  WAGBOT_ID = 1

  def newcard(name, content="")
    Card.create! :name=>name, :content=>content
  end
  
  def card_content( cardname )
    render(Card.find_by_name(cardname))
  end      

  def create_cards( card_names )
    card_names.collect {|name| Card.create :name=>name }
  end

  def create_users( user_names )
    user_names.collect {|name| create_user(name) }
  end
  
  def create_roles( role_names )
    role_names.collect {|name| Card.create( :typecode=>'Role', :name=>name ) }
  end

  def create_user( username )
    #username = separate_wikiword(username)
    raise( "invalid username" ) if username.nil? or username.empty?
    if u = User.where(:card_id=>Card[username].id).first
      return u      
    elsif c = Card[username]
      return User.where(:card_id=>c.id).first
    else
      if c = Card[username]
        if c.type_id==Card::DefaultTypeID
          c.type_id = Card::UserID
        else
          raise "Can't create user card for #{username}: already points to different user"
        end
      else 
        c = Card.create!( :name=>username, :type_id=>Card::UserID )
      end
      c.save

      u = User.create!(
        :password=>'foofoo',
        :password_confirmation=>'foofoo',
        :email=>"#{username.gsub(/\s+/,'')}@grasscommons.org",
        :login=>username, 
        :blocked => true,
        :invite_sender_id=>WAGBOT_ID,
        :card_id=>c.id
      )

      return u
    end
  end      
    
  def admin
    User.admin
  end
  
  def as(admin)
    tmpuser = Card.user_id
    Card.user= admin
    yield
    Card.user= tmpuser
  end
end


class CardBuilder
  include CardBuilderMethods
  
  def initialize
  end
  
end



