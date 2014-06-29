# -*- encoding : utf-8 -*-

describe Card::Format do

  describe '#show?' do
    before :all do
      @format = described_class.new Card.new
    end
    
    it "should respect defaults" do
      @format.show_view?( :menu, :default_visibility=>:show ).should be_true
      @format.show_view?( :menu, :default_visibility=>:hide ).should be_false
      @format.show_view?( :menu, {}                          ).should be_true
    end
    
    it "should respect developer default overrides" do
      @format.show_view?( :menu, :optional_menu=>:show, :default_visibility=>:hide ).should be_true
      @format.show_view?( :menu, :optional_menu=>:hide, :default_visibility=>:show ).should be_false
      @format.show_view?( :menu, :optional_menu=>:hide                             ).should be_false
    end
    
    it "should handle args from inclusions" do
      @format.show_view?( :menu, :show=>'menu', :default_visibility=>:hide         ).should be_true
      @format.show_view?( :menu, :hide=>'menu, paging', :default_visibility=>:show ).should be_false
      @format.show_view?( :menu, :show=>'menu', :optional_menu=>:hide              ).should be_true      
    end
    
    it "should handle hard developer overrides" do
      @format.show_view?( :menu, :optional_menu=>:always, :hide=>'menu' ).should be_true
      @format.show_view?( :menu, :optional_menu=>:never,  :show=>'menu' ).should be_false
    end
    
  end

end
