class InvitationRequestPermissions < ActiveRecord::Migration
  def self.up
    User.as :admin
    User.reset_column_information
    Card::InvitationRequest.reset_column_information
    System.invite_request_alert_email = nil
    anon = Role.find_by_codename 'anon'
    auth = Role.find_by_codename 'auth'
    def_perm = {:read=>anon, :edit=> Role[:admin], :comment=> nil, :delete=> auth, :create=> anon}  
    perm = def_perm.keys.map do |key|
      Permission.new :task=>key.to_s, :party=>def_perm[key]
    end
    temp = Card::InvitationRequest.create! :name=>'InvitationRequest+*template', :permissions=> perm, :email=>'fake@fake.com'
  end

  def self.down
    User.as :admin
    bt = Card.find_by_name('InvitationRequest+*template')
    bt.destroy!
  end
end
 