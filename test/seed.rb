#require File.expand_path('../db/migrate/20120327090000_codename_table', File.dirname(__FILE__))
require 'timecop'

require_dependency 'card'

Dir["#{Rails.root}/app/models/card/*.rb"].sort.each do |cardtype|
  require_dependency cardtype
end

class SharedData
  FUTURE = Time.local(2020,1,1,0,0,0)

  def self.add_test_data
    #Account.current_id = Card::WagnBotID
    CodenameTable.load_bootcodes unless !Wagn::Codename[:wagn_bot].nil?

    Wagn::Cache.reset_global
    Account.as(Card::WagnBotID)


    User.create_with_card(
      { :login=>"joe_user", :email=>'joe@user.com', :status=>'active', :password=>'joe_pass', :password_confirmation=>'joe_pass' },
      { :name=>"Joe User", :content => "I'm number two" }
    )    

    User.create_with_card(
      { :login=>"joe_admin", :email=>'joe@admin.com', :status=>'active', :password=>'joe_pass', :password_confirmation=>'joe_pass' },
      { :name=>"Joe Admin", :content => "I'm number one" }
    )

    roles_card = Card['Joe Admin'].fetch(:trait=>:roles, :new=>{})
    roles_card << Card::AdminID

    User.create_with_card(
      { :login=>"joe_camel",:email=>'joe@camel.com', :status => 'active', :password=>'joe_pass', :password_confirmation=>'joe_pass' },
      { :name=>"Joe Camel", :content => "Mr. Buttz" }
    )

    # generic, shared attribute card
    color = Card.create! :name=>"color"
    basic = Card.create! :name=>"Basic Card"

    # data for testing users and account requests

    User.create_with_card(
      { :email=>'ron@request.com', :password=>'ron_pass', :password_confirmation=>'ron_pass', :status=>'pending' },
      { :type_id=>Card::AccountRequestID, :name=>"Ron Request" }
    )
    
    Card.create! :typecode=>'user', :name=>"No Count", :content=>"I got no account"

    # CREATE A CARD OF EACH TYPE
    
    User.create_with_card(
      { :login=>"sample_user", :email=>'sample@user.com', :status=>'active', :password=>'sample_pass', :password_confirmation=>'sample_pass' },
      { :name=>"Sample User" }
    )

    request_card = Card.create! :typecode=>'account_request', :name=>"Sample AccountRequest" #, :email=>"invitation@request.com"

    Account.createable_types.each do |type|
      next if ['User', 'Account Request', 'Set'].include? type
      Card.create! :type=>type, :name=>"Sample #{type}"
    end

    # data for role_test.rb

    User.create_with_card(
      { :login=>"u1", :email=>'u1@user.com', :status=>'active', :password=>'u1_pass', :password_confirmation=>'u1_pass' },
      { :name=>"u1" }
    )
    User.create_with_card(
      { :login=>"u2", :email=>'u2@user.com', :status=>'active', :password=>'u2_pass', :password_confirmation=>'u2_pass' },
      { :name=>"u2" }
    )
    User.create_with_card(
      { :login=>"u3", :email=>'u3@user.com', :status=>'active', :password=>'u3_pass', :password_confirmation=>'u3_pass' },
      { :name=>"u3" }
    )


    r1 = Card.create!( :typecode=>'role', :name=>'r1' )
    r2 = Card.create!( :typecode=>'role', :name=>'r2' )
    r3 = Card.create!( :typecode=>'role', :name=>'r3' )
    r4 = Card.create!( :typecode=>'role', :name=>'r4' )

    Card['u1'].fetch(:trait=>:roles, :new=>{}) << r1 << r2 << r3
    Card['u2'].fetch(:trait=>:roles, :new=>{}) << r1 << r2 << r4
    u3_star = Card['u3'].fetch(:trait=>:roles, :new=>{}) << r1 << r4
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

    Card.create! :name=>"One+Two+Three"
    Card.create! :name=>"Four+One+Five"

    # for wql & permissions
    %w{ A+C A+D A+E C+A D+A F+A A+B+C }.each do |name| Card.create!(:name=>name)  end
    Card.create! :typecode=>'cardtype', :name=>"Cardtype A", :codename=>"cardtype_a"
    Card.create! :typecode=>'cardtype', :name=>"Cardtype B", :codename=>"cardtype_b"
    Card.create! :typecode=>'cardtype', :name=>"Cardtype C", :codename=>"cardtype_c"
    Card.create! :typecode=>'cardtype', :name=>"Cardtype D", :codename=>"cardtype_d"
    Card.create! :typecode=>'cardtype', :name=>"Cardtype E", :codename=>"cardtype_e"
    Card.create! :typecode=>'cardtype', :name=>"Cardtype F", :codename=>"cardtype_f"

    Card.create! :name=>'basicname', :content=>'basiccontent'
    Card.create! :typecode=>'cardtype_a', :name=>"type-a-card", :content=>"type_a_content"
    Card.create! :typecode=>'cardtype_b', :name=>"type-b-card", :content=>"type_b_content"
    Card.create! :typecode=>'cardtype_c', :name=>"type-c-card", :content=>"type_c_content"
    Card.create! :typecode=>'cardtype_d', :name=>"type-d-card", :content=>"type_d_content"
    Card.create! :typecode=>'cardtype_e', :name=>"type-e-card", :content=>"type_e_content"
    Card.create! :typecode=>'cardtype_f', :name=>"type-f-card", :content=>"type_f_content"

    #warn "current user #{User.session_user.inspect}.  always ok?  #{Account.always_ok?}"
    c = Card.create! :name=>'revtest', :content=>'first'
    c.update_attributes! :content=>'second'
    c.update_attributes! :content=>'third'
    #Card.create! :typecode=>'cardtype', :name=>'*priority'

    # for template stuff
    Card.create! :type_id=>Card::CardtypeID, :name=> "UserForm"
    Card.create! :name=>"UserForm+*type+*content", :content=>"{{+name}} {{+age}} {{+description}}"

    Account.current_id = Card['joe_user'].id
    Card.create!( :name=>"JoeLater", :content=>"test")
    Card.create!( :name=>"JoeNow", :content=>"test")

    Account.current_id = Card::WagnBotID
    Card.create!(:name=>"AdminNow", :content=>"test")

    Card.create :name=>'Cardtype B+*type+*create', :type=>'Pointer', :content=>'[[r1]]'

    Card.create! :type=>"Cardtype", :name=>"Book"
    Card.create! :name=>"Book+*type+*content", :content=>"by {{+author}}, design by {{+illustrator}}"
    Card.create! :name => "Iliad", :type=>"Book"


    ### -------- Notification data ------------
    Timecop.freeze(FUTURE - 1.day) do
      # fwiw Timecop is apparently limited by ruby Time object, which goes only to 2037 and back to 1900 or so.
      #  whereas DateTime can represent all dates.

      User.create_with_card(
        { :login=>"john",:email=>'john@user.com', :status => 'active', :password=>'john_pass', :password_confirmation=>'john_pass' },
        { :name=>"John" }
      )

      User.create_with_card(
        { :login=>"sara",:email=>'sara@user.com', :status => 'active', :password=>'sara_pass', :password_confirmation=>'sara_pass' },
        { :name=>"Sara" }
      )

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

    # -------- For toc testing: ------------

    Card.create :name=>"OnneHeading", :content => "<h1>This is one heading</h1>\r\n<p>and some text</p>"
    Card.create :name=>'TwwoHeading', :content => "<h1>One Heading</h1>\r\n<p>and some text</p>\r\n<h2>And a Subheading</h2>\r\n<p>and more text</p>"
    Card.create :name=>'ThreeHeading', :content =>"<h1>A Heading</h1>\r\n<p>and text</p>\r\n<h2>And Subhead</h2>\r\n<p>text</p>\r\n<h1>And another top Heading</h1>"

    c=Card.fetch 'Basic+*type+*table_of_contents', :new=>{}
    c.content='2'
    c.save

  end
end
