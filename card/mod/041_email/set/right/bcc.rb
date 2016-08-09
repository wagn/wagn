
def process_email_addresses context_card, format_args, args
  format(format_args).render_email_addresses(args.merge(context: context_card))
end

format do
  def chunk_list  # turn off autodetection of uri's
    :references
  end
end

format :html do
  view :pointer_items do |args|
    card.item_names(context: :raw).map do |iname|
      wrap_item iname, args
    end.join ", "
  end
end

format :email_text do
  view :email_addresses do |args|
    context = args[:context] || self
    card.item_names(context: context.cardname).map do |item_name|
      # note that context is processed twice here because pointers absolutize
      # item_names by default while other types can return relative names.
      # That's poor default behavior and should be fixed!
      item_name = item_name.to_name.to_absolute(context).to_s
      if item_name =~ /.+\@.+\..+/
        item_name
      elsif (item_card = Card.fetch(item_name))
        if item_card.account
          item_card.account.email
        else
          item_card.contextual_content(context, format: :email_text)
                   .split(/[,\n]/)
        end
      end
    end.flatten.compact.join(", ")
  end
end
