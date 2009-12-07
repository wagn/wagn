require File.dirname(__FILE__) + '/../spec_helper'

describe CardController do
  context "new" do    
    before do
      login_as :wagbot
    end
    it "assigns @args[:name] from id" do
      post :new, :id => "xxx"
      assigns[:args][:name].should == "xxx"
    end
  end     
  
  describe "- route generation" do
    it "gets name/id from /card/new/xxx" do
      params_from(:post, "/card/new/xxx").should == {
        :controller=>"card", :action=>'new', :id=>"xxx"
      }
    end
    
    it "should recognize .rss on /recent" do
      params_from(:get, "/recent.rss").should == {:controller=>"card", :view=>"content", :action=>"show", 
        :id=>"*recent_changes", :format=>"rss"
      }
    end

    ["/wagn",""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          params_from(:get, "#{prefix}/*recent_changes.rss").should == {
            :controller=>"card", :action=>"show", :id=>"*recent_changes", :format=>"rss"
          }
        end           
    
        it "should recognize .xml format" do
          params_from(:get, "#{prefix}/*recent_changes.xml").should == {
            :controller=>"card", :action=>"show", :id=>"*recent_changes", :format=>"xml"
          }
        end           

        it "should accept cards with dot sections that don't match extensions" do
          params_from(:get, "#{prefix}/random.card").should == {
            :controller=>"card",:action=>"show",:id=>"random.card"
          }
        end
    
        it "should accept cards without dots" do
          params_from(:get, "#{prefix}/random").should == {
            :controller=>"card",:action=>"show",:id=>"random"
          }
        end    
      end
    end
  end
end