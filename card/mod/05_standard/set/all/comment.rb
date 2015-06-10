event :add_comment, :after=>:approve, :on=>:save, :when=> proc {|c| c.comment } do
  self.content = %{
    #{ content }
    #{ '<hr>' unless content.blank? }
    #{ comment.split(/\n/).map {|line| "<p>#{line.strip.empty? ? '&nbsp;' : line}</p>"} * "\n" }
    <div class="w-comment-author">--#{
      if Auth.signed_in?
        "[[#{Auth.current.name}]]"
      else
        Env.session[:comment_author] = comment_author if Env.session
        "#{ comment_author } (Not signed in)"
      end
    }.....#{Time.now}</div>
  }
end

view( :comment_box, :denial=>:blank, :tags=>:unknown_ok, :perms=>lambda { |r| r.card.ok? :comment } ) do |args|
  
  
  %{<div class="comment-box nodblclick"> #{
    card_form :update do
      %{
        #{ hidden_field_tag( 'card[name]', card.name ) if card.new_card? 
        # FIXME wish we had more generalized solution for names.  without this, nonexistent cards will often take left's linkname.  (needs test)
        }
        #{ text_area :comment, :rows=>3 }
        <div class="comment-buttons">
          #{
            unless Auth.signed_in?
              card.comment_author= (session[:comment_author] || params[:comment_author] || "Anonymous") #ENGLISH
              %{<label>My Name is:</label> #{ text_field :comment_author }}
            end
          }
          #{ button_tag 'Comment', :type=>:submit, :disable_with=>"Commenting" }
        </div>
      }
    end}
  </div>}
end
