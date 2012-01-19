require 'timecop'

Dir["#{Rails.root}/app/models/card/*.rb"].sort.each do |cardtype|
  require_dependency cardtype
end

class SharedData
  FUTURE = Time.local(2020,1,1,0,0,0)


  def self.add_test_data
    #Card.current_id = Card::WagbotID
    ::User.as :wagbot
    Wagn::Cache.reset_global

    joe_card = Card.create! :typecode=>'User', :name=>"Joe User", :content => "I'm number two"
    joe_user = ::User.create! :login=>"joe_user",:email=>'joe@user.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass', :invite_sender=>User[:wagbot], :card_id=>joe_card.id

    ja_card = Card.create! :typecode=>'User', :name=>"Joe Admin", :content => "I'm number one"
    joe_admin = ::User.create! :login=>"joe_admin",:email=>'joe@admin.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass', :invite_sender=>User[:wagbot], :card_id=>ja_card.id
    roles_card = ja_card.star_rule(:roles)
    #warn "roles card for #{ja_card.name} is #{roles_card.inspect}"
    roles_card << Card::AdminID
    # FIXME: improve API: roles_card = jc_card.star_rule(:roles) << ja_card
    #roles_card = Card.fetch_or_new(jc_card.cardname.star_rule(:roles),
    #                               :type_id=>Card::PointerID)
    #roles_card.add_item( ja_card.name )
    #jc_card.star_rule(:roles) << joe_admin
    #Role[:admin].users<< [ joe_admin ]

    jc_card = Card.create! :typecode=>'User', :name=>"Joe Camel", :content => "Mr. Buttz"
    joe_camel = ::User.create! :login=>"joe_camel",:email=>'joe@camel.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass', :invite_sender=>User[:wagbot], :card_id=>jc_card.id

    #bt = Card.find_by_name 'Basic+*type+*default'

    # generic, shared attribute card
    color = Card.create! :name=>"color"
    basic = Card.create! :name=>"Basic Card"

    # data for testing users and invitation requests
    ron_request = Card.create! :typecode=>'InvitationRequest', :name=>"Ron Request"  #, :email=>"ron@request.com"

    User.create_with_card({:email=>'ron@request.com', :password=>'ron_pass', :password_confirmation=>'ron_pass'}, ron_request)

    no_count = Card.create! :typecode=>'User', :name=>"No Count", :content=>"I got no account"

    # CREATE A CARD OF EACH TYPE
    user_card = Card.create! :typecode=>'User', :name=>"Sample User"
    user_user = ::User.create! :login=>"sample_user",:email=>'sample@user.com', :status => 'active', :password=>'sample_pass', :password_confirmation=>'sample_pass', :invite_sender=>User[:wagbot], :card_id=>user_card.id

    request_card = Card.create! :typecode=>'InvitationRequest', :name=>"Sample InvitationRequest" #, :email=>"invitation@request.com"
    Card.createable_typecodes.each do |typecode|
      next if %w{User InvitationRequest Set}.include? typecode
      Card.create! :type=>typecode, :name=>"Sample #{typecode}"
    end
    # data for role_test.rb
    u1 = Card.create! :typecode=>'User', :name=>"u1"
    u2 = Card.create! :typecode=>'User', :name=>"u2"
    u3 = Card.create! :typecode=>'User', :name=>"u3"

    ::User.create! :login=>"u1",:email=>'u1@user.com', :status => 'active', :password=>'u1_pass', :password_confirmation=>'u1_pass', :invite_sender=>User[:wagbot], :card_id=>u1.id
    ::User.create! :login=>"u2",:email=>'u2@user.com', :status => 'active', :password=>'u2_pass', :password_confirmation=>'u2_pass', :invite_sender=>User[:wagbot], :card_id=>u1.id
    ::User.create! :login=>"u3",:email=>'u3@user.com', :status => 'active', :password=>'u3_pass', :password_confirmation=>'u3_pass', :invite_sender=>User[:wagbot], :card_id=>u1.id


    r1 = Card.create!( :typecode=>'Role', :name=>'r1' )
    r2 = Card.create!( :typecode=>'Role', :name=>'r2' )
    r3 = Card.create!( :typecode=>'Role', :name=>'r3' )
    r4 = Card.create!( :typecode=>'Role', :name=>'r4' )

    u1.star_rule(:roles) << r1 << r2 << r3
    u2.star_rule(:roles) << r1 << r2 << r4
    u3_star = u3.star_rule(:roles) << r1 << r4
    #r1.users = [ u1, u2, u3 ]
    #r2.users = [ u1, u2 ]
    #r3.users = [ u1 ]
    #r4.users = [ u3, u2 ]

    u3_star << Card::AdminID
    #Role[:admin].users<< [ u3 ]

    c1 = Card.create! :name=>'c1'
    c2 = Card.create! :name=>'c2'
    c3 = Card.create! :name=>'c3'

    # cards for rename_test
    # FIXME: could probably refactor these..
    z = Card.create! :name=>"Z", :content=>"I'm here to be referenced to"
    a = Card.create! :name=>"A", :content=>"Alpha [[Z]]"
    b = Card.create! :name=>"B", :content=>"Beta {{Z}}"
    t = Card.create! :name=>"T", :content=>"Theta"
    x = Card.create! :name=>"X", :content=>"[[A]] [[A+B]] [[T]]"
    y = Card.create! :name=>"Y", :content=>"{{B}} {{A+B}} {{A}} {{T}}"
    ab = Card.create! :name => "A+B", :content => "AlphaBeta"

    c12345 = Card.create:name=>"One+Two+Three"
    c12345 = Card.create:name=>"Four+One+Five"

    # for wql & permissions
    %w{ A+C A+D A+E C+A D+A F+A A+B+C }.each do |name| Card.create!(:name=>name)  end

    Card.create! :typecode=>'Cardtype', :name=>"Cardtype A", :codename=>"CardtypeA"
    bt = Card.create! :typecode=>'Cardtype', :name=>"Cardtype B", :codename=>"CardtypeB"
    Card.create! :typecode=>'Cardtype', :name=>"Cardtype C", :codename=>"CardtypeC"
    Card.create! :typecode=>'Cardtype', :name=>"Cardtype D", :codename=>"CardtypeD"
    Card.create! :typecode=>'Cardtype', :name=>"Cardtype E", :codename=>"CardtypeE"
    Card.create! :typecode=>'Cardtype', :name=>"Cardtype F", :codename=>"CardtypeF"

    Card.create! :name=>'basicname', :content=>'basiccontent'
    Card.create! :typecode=>'CardtypeA', :name=>"type-a-card", :content=>"type_a_content"
    Card.create! :typecode=>'CardtypeB', :name=>"type-b-card", :content=>"type_b_content"
    Card.create! :typecode=>'CardtypeC', :name=>"type-c-card", :content=>"type_c_content"
    Card.create! :typecode=>'CardtypeD', :name=>"type-d-card", :content=>"type_d_content"
    Card.create! :typecode=>'CardtypeE', :name=>"type-e-card", :content=>"type_e_content"
    Card.create! :typecode=>'CardtypeF', :name=>"type-f-card", :content=>"type_f_content"

#      warn "current user #{User.current_user.inspect}.  always ok?  #{Card.always_ok?}"

    c = Card.create! :name=>'revtest', :content=>'first'
    c.update_attributes! :content=>'second'
    c.update_attributes! :content=>'third'
    #Card.create! :typecode=>'Cardtype', :name=>'*priority'

    # for template stuff
    Card.create! :type_id=>Card::CardtypeID, :name=> "UserForm"
    Card.create! :name=>"UserForm+*type+*content", :content=>"{{+name}} {{+age}} {{+description}}"

    ::User.current_user = :joe_user
    Card.create!( :name=>"JoeLater", :content=>"test")
    Card.create!( :name=>"JoeNow", :content=>"test")

    ::User.current_user = :wagbot
    Card.create!(:name=>"AdminNow", :content=>"test")

    Card.create :name=>'Cardtype B+*type+*create', :type=>'Pointer', :content=>'[[r1]]'

    Card.create! :type=>"Cardtype", :name=>"Book"
    Card.create! :name=>"Book+*type+*content", :content=>"by {{+author}}, design by {{+illustrator}}"
    Card.create! :name => "Iliad", :type=>"Book"


    ### -------- Notification data ------------
    Timecop.freeze(FUTURE - 1.day) do
      # fwiw Timecop is apparently limited by ruby Time object, which goes only to 2037 and back to 1900 or so.
      #  whereas DateTime can represent all dates.

      john_card = Card.create! :name=>"John", :type=> "User"
      ::User.create! :login=>"john",:email=>'john@user.com', :status => 'active', :password=>'john_pass', :password_confirmation=>'john_pass', :invite_sender=>User[:wagbot], :card_id=>john_card.id

      sara_card = Card.create! :name=>"Sara", :type=> "User"
      ::User.create! :login=>"sara",:email=>'sara@user.com', :status => 'active', :password=>'sara_pass', :password_confirmation=>'sara_pass', :invite_sender=>User[:wagbot], :card_id=>john_card.id


      Card.create! :name => "Sara Watching+*watchers",  :content => "[[Sara]]"
      Card.create! :name => "All Eyes On Me+*watchers", :content => "[[Sara]]\n[[John]]"
      Card.create! :name => "John Watching", :content => "{{+her}}"
      Card.create! :name => "John Watching+*watchers",  :content => "[[John]]"
      Card.create! :name => "John Watching+her"
      Card.create! :name => "No One Sees Me"

      Card.create! :name => "Optic", :type => "Cardtype"
      Card.create! :name => "Optic+*watchers", :content => "[[Sara]]"
      Card.create! :name => "Sunglasses", :type=>"Optic", :content=>"{{+tint}}"
      Card.create! :name => "Sunglasses+tint"

      # TODO: I would like to setup these card definitions with something like Cucumbers table feature.
    end


    ## --------- create templated permissions -------------
    ctt = Card.create! :name=> 'Cardtype E+*type+*default'


    ## --------- Fruit: creatable by anon but not readable ---
    f = Card.create! :type=>"Cardtype", :name=>"Fruit"
    Card.create :name=>'Fruit+*type+*create', :type=>'Pointer', :content=>'[[Anyone]]'
    Card.create :name=>'Fruit+*type+*read', :type=>'Pointer', :content=>'[[Administrator]]'
  end
end
