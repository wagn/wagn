require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../pattern_spec_helper')

describe Pattern do
  it "module exists and autoloads" do
    Pattern.should be_true
  end
end

describe RightNamePattern do
  it_accepts :right => "author"
  it_rejects :type => "Book", :right => "author"
end
                              
describe TypePattern do
  it_accepts :type => "Book"
  it_rejects :type => "Book", :right => "author"
end

describe TypeRightNamePattern do
  it_accepts :type => "Book", :right => "author"
  it_rejects :type => "Book"
  it_rejects :right => "author"
end



# 
# describe Pattern do
#   context "create" do
#     it "returns a pattern of the proper type" do
#       Pattern.create( :right=>"color" ).should === Pattern::Base 
#     end
#   end
# end
#        