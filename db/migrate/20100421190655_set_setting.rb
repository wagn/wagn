class SetSetting < ActiveRecord::Migration
  def self.up 
    User.as(:wagbot) do
      card = Card.fetch_or_create "Setting", :type=>"Cardtype"
      content =<<CONTENT
<p>{{+description}}</p>
<p>&nbsp;</p>
<h1>[[http://www.wagn.org/wagn/Help text|Help text]]<br></h1>
<blockquote>
<p>{{*add help|closed}}</p>
<p>{{*edit help|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>[[http://www.wagn.org/wagn/Formatting|Formatting]]<br></h1>
<blockquote>
<p>{{*content|closed}}</p>
<p>{{*default|closed}}</p>
</blockquote>
<p>&nbsp;</p>
<h1>[[http://www.wagn.org/wagn/Pointers|Pointers]]<br></h1>
<blockquote>
<p>{{*input|closed}}</p>
<p>{{*options|closed}}</p>
<p>{{*option label|closed}}</p>
<br></blockquote>
<h1>Other<br></h1>
<blockquote>
<p>{{*accountable|closed}}</p>
<p>{{*autoname|closed}}</p>
<p>{{*captcha|closed}}</p>
{{*layout|closed}}
<p>{{*send|closed}}</p>
{{*table of contents|closed}}
<p>{{*thanks|closed}}</p>
</blockquote>
CONTENT
      if card.content_template
        Card.create! :name => "Setting+*self+*content", :content => content
      else
        card.content = content
        card.permit('edit',Role[:admin])
        card.permit('delete',Role[:admin])
        card.save!
      end
    end
  end

  def self.down
  end
end
