event :add_comment, after: :approve, on: :save, when: proc { |c| c.comment } do
  cleaned_comment =
    comment.split(/\n/).map do |line|
      "<p>#{line.strip.empty? ? '&nbsp;' : line}</p>"
    end * "\n"

  signature =
    if Auth.signed_in?
      "[[#{Auth.current.name}]]"
    else
      Env.session[:comment_author] = comment_author if Env.session
      "#{comment_author} (Not signed in)"
    end

  self.content = %{
    #{content}
    #{'<hr>' unless content.blank?}
    #{cleaned_comment}
    <div class="w-comment-author">--#{signature}.....#{Time.zone.now}</div>
  }
end

format do
  view :comment_box,
       denial: :blank, tags: :unknown_ok,
       perms: lambda { |r| r.card.ok? :comment } do |_args|
    <<-HTML
      <div class="comment-box nodblclick">#{comment_form}</div>
    HTML
  end

  def comment_form
    card_form :update do
      %{
        #{hidden_field_tag('card[name]', card.name) if card.new_card?
          # FIXME: wish we had more generalized solution for names.
          # without this, nonexistent cards will often take left's linkname.
          # (needs test)
        }
        #{text_area :comment, rows: 3}
        #{comment_buttons}
      }
    end
  end

  def comment_buttons
    <<-HTML
      <div class="comment-buttons">
        #{
          unless Auth.signed_in?
            card.comment_author = session[:comment_author] ||
                                  params[:comment_author] || 'Anonymous' # ENGLISH
            %{<label>My Name is:</label> #{text_field :comment_author}}
          end
        }
        #{submit_button text: 'Comment', type: :submit,
                        disable_with: 'Commenting'}
      </div>
    HTML
  end
end
