require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include WagnHelper
describe WagnHelper do
  #helper WagnHelper
  
  it "should truncate correctly" do
    content = <<CONTENT

    <div>Favicons are the little icons that appear in browser tabs, and Wagn lets you set yours to whatever you like</div> 
    <p>&nbsp;</p> 
    <h1>Examples</h1> 
    <blockquote> 
    <div>Here's the *favicon for this Wagn: 
     &nbsp; 
     <img src="http://s3.amazonaws.com/wagn.wagn.org/card_images/266/_favicon_medium.ico"> 
    </img></div> 
    <div>&nbsp;</div> 
    </blockquote> 
CONTENT

  truncatewords_with_closing_tags(content).should== %{<div>Favicons are the little icons that appear in browser tabs,} +
  %{ and Wagn lets you set yours to whatever you like</div>  &nbsp; } +
  %{ <h1>Examples</h1> <blockquote> <div>Here's the</div></blockquote>} +
  %{<span class=\"closed-content-ellipses\"> ...</span>}

  end
end