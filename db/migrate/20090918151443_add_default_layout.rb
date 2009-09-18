class AddDefaultLayout < ActiveRecord::Migration
  def self.up
    User.as(:wagbot) do
      unless Card["*layout"] 
        Card.create!(:name=>"*layout", :content=><<-LAYOUT)
          <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
          <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
           {{**head}}
            <body class="wagn">	  		
          	  {{**top_menu}}
                <div id="page">
              	  <div id="page-left">
          	 	<div id="main" context="main">{{_main}}</div>
            		</div>  
            	  <div id="page-right">
            		  {{**logo}}
            			<div id="sidebar" context="sidebar"> 
          				{{*sidebar|naked}}
            			</div>
            	    {{**bottom_menu}}
            	    {{**alerts}}
            	</div>
            </div>
            {{**foot}}
            </body>
          </html>
        LAYOUT
      end
    end
  end

  def self.down
  end
end
