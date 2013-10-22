event :add_comment, :after=>:approve, :on=>:save, :when=> proc {|c| c.comment } do
  self.content = %{
    #{ content }
    #{ '<hr>' unless content.blank? }
    #{ comment.to_html }
    <div class="w-comment-author">--#{
      if Account.logged_in?
        "[[#{Account.current.name}]]"
      else
        Wagn::Env[:controller].session[:comment_author] = comment_author if Wagn::Env[:controller]
        "#{ comment_author } (Not signed in)"
      end
    }.....#{Time.now}</div>
  }
end

view( :comment_box, :denial=>:blank, :tags=>:unknown_ok, :perms=>lambda { |r| r.card.ok? :comment } ) do |args|
  
  
  %{<div class="comment-box nodblclick"> #{
    card_form :update do |f|
      %{
        #{ hidden_field_tag( 'card[name]', card.name ) if card.new_card? 
        # FIXME wish we had more generalized solution for names.  without this, nonexistent cards will often take left's linkname.  (needs test)
        }
        #{ f.text_area :comment, :rows=>3 }
        <div class="comment-buttons">
          #{
            unless Account.logged_in?
              card.comment_author= (session[:comment_author] || params[:comment_author] || "Anonymous") #ENGLISH
              %{<label>My Name is:</label> #{ f.text_field :comment_author }}
            end
          }
          <input type="submit" value="Comment"/>
        </div>
      }
    end}
  </div>}
end
