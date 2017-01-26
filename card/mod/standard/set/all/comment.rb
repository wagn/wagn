def commenting?
  comment && @action != :delete
end

event :add_comment, :prepare_to_store, on: :save, when: :comment do
  Env.session[:comment_author] = comment_author if Env.session
  self.content =
    [content, format.comment_with_signature].compact.join "\n<hr\>\n"
end

attr_writer :comment_author

def comment_author
  @comment_author ||=
    Env.session[:comment_author] || Env.params[:comment_author] || "Anonymous"
end

def clean_comment
  comment.split(/\n/).map do |line|
    "<p>#{line.strip.empty? ? '&nbsp;' : line}</p>"
  end * "\n"
end

format do
  def comment_with_signature
    card.clean_comment + "\n" + comment_signature
  end

  def comment_signature
    wrap_with :div, class: "w-comment-author" do
      "#{comment_author}.....#{Time.zone.now}"
    end
  end

  def comment_author
    if Auth.signed_in?
      "[[#{Auth.current.name}]]"
    else
      "#{card.comment_author} (Not signed in)"
    end
  end

  view :comment_box,
       denial: :blank, tags: :unknown_ok,
       perms: ->(r) { r.card.ok? :comment } do
    wrap_with :div, class: "comment-box nodblclick" do
      action = card.new_card? ? :create : :update
      card_form action do
        [hidden_comment_fields, comment_box, comment_buttons]
      end
    end
  end

  def hidden_comment_fields
    return unless card.new_card?
    hidden_field_tag "card[name]", card.name
    # FIXME: wish we had more generalized solution for names.
    # without this, nonexistent cards will often take left's linkname.
    # (needs test)
  end

  def comment_box
    text_area :comment, rows: 3
  end

  def comment_buttons
    wrap_with :div, class: "comment-buttons" do
      [comment_author_label, comment_submit_button]
    end
  end

  def comment_author_label
    return if Auth.signed_in?
    %(<label>My Name is:</label> #{text_field :comment_author})
  end

  def comment_submit_button
    submit_button text: "Comment", type: :submit, disable_with: "Commenting"
  end
end
