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
    if u = User.find_by_login(username) 
      return u      
    elsif c = Card::User.find_by_name(username)
      return User.where(:card_id=>c.id).first
    else
      if c = Card.find_by_name(username)
        if c.type_id==Card::DefaultID #'Basic'
          c.type_id = Card::UserID
        else
          raise "Can't create user card for #{username}: already points to different user"
        end
      else 
        c = Card::User.create!( :name=>username )
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
    User[:wagbot]
  end
  
  def as(admin)
    tmpuser, User.current_user = User.current_user, admin
    yield
    User.current_user = tmpuser
  end
end


class CardBuilder
  include CardBuilderMethods
  
  def initialize
  end
  
end



