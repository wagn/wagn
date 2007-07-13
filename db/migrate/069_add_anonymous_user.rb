class AddAnonymousUser < ActiveRecord::Migration
  def self.up      
    #unless select_one( %{ select * from users where login='anonymous' })
       # FIXME: not finished
       ::User.reset_column_information
       ::User.create( 
         :login => 'anonymous',
         :crypted_password => '13d124f96e2953fea135c13df097fb3d754588be',
         :salt => 'c420fa40c65a38186deb25ba859edacd9bf7d8f8',
         :email => 'anonymous@grasscommons.org',
         :status => 'system',
         :invited_by=>1
       )   
       
       #create_user_card( 'Anonymous', 'anonymous' )
     #end
  end

  def self.down
  end
end
