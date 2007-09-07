class DefaultCreatePermissions < ActiveRecord::Migration
  def self.up
    User.as :admin
    Card.reset_column_information
    Card::Basic.reset_column_information
    anon = Role.find_by_codename 'anon'
    auth = Role.find_by_codename 'auth'
    def_perm = {:read=>anon, :edit=> auth, :comment=> nil, :delete=> auth, :create=> auth}
    perm = def_perm.keys.map do |key|
      Permission.new :task=>key.to_s, :party=>def_perm[key]
    end
    t = Card.create! :name=>'*template', :permissions=> perm
    bt = Card.create! :name=>'Basic+*template', :permissions=>perm
   # bt = Card.find_by_name 'Basic+*template'
  #  bt.permissions = perm
  #  bt.save!
  #  bt = Card.find_by_name 'Basic+*template'
  #  fail "oh god #{bt.permissions.inspect}"  if bt.permissions.empty?

    
  end

  def self.down
    User.as :admin
    bt = Card.find_by_name('Basic+*template')
    bt.destroy!
  end
end
