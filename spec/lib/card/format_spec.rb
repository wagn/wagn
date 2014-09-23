# -*- encoding : utf-8 -*-

describe Card::Format do

  describe '#show?' do
    before :all do
      @format = described_class.new Card.new
    end
    
    it "should respect defaults" do
      expect(@format.show_view?( :menu, :default_visibility=>:show )).to be_truthy
      expect(@format.show_view?( :menu, :default_visibility=>:hide )).to be_falsey
      expect(@format.show_view?( :menu, {}                          )).to be_truthy
    end
    
    it "should respect developer default overrides" do
      expect(@format.show_view?( :menu, :optional_menu=>:show, :default_visibility=>:hide )).to be_truthy
      expect(@format.show_view?( :menu, :optional_menu=>:hide, :default_visibility=>:show )).to be_falsey
      expect(@format.show_view?( :menu, :optional_menu=>:hide                             )).to be_falsey
    end
    
    it "should handle args from inclusions" do
      expect(@format.show_view?( :menu, :show=>'menu', :default_visibility=>:hide         )).to be_truthy
      expect(@format.show_view?( :menu, :hide=>'menu, paging', :default_visibility=>:show )).to be_falsey
      expect(@format.show_view?( :menu, :show=>'menu', :optional_menu=>:hide              )).to be_truthy      
    end
    
    it "should handle hard developer overrides" do
      expect(@format.show_view?( :menu, :optional_menu=>:always, :hide=>'menu' )).to be_truthy
      expect(@format.show_view?( :menu, :optional_menu=>:never,  :show=>'menu' )).to be_falsey
    end
    
  end

end
