def chunk_list  #turn off autodetection of uri's 
  :inclusion_and_link
end

def process_email_addresses context, format_args, args
  format(format_args).render_email_addresses(args.merge(:context=>context.name))
end

format :email_text do
  view :email_addresses do |args|
    item_names(args).map do |item_name|
      if item_name.match /.+\@.+\..+/ 
        item_name
      elsif item_card = Card.fetch( item_name )
        if item_card.account
          item_card.account.email
        else
          item_card.contextual_content(context).split( /[,\n]/ )
        end
      end          
    end.flatten.compact.join(', ')
  end
end



# _user, info@mail.com, Ethan, Pointer -> ..., _left+email, my email address -> info@mail.com