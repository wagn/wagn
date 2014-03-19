
describe AdminController, "admin functions" do

  it "should clear cache" do
    login_as :joe_admin
    get :clear_cache
  end

  it "should show cache" do
    login_as :joe_admin
    get :read, :id=>"A", :view=>:show_cache
  end
end
