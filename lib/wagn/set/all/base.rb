
module Wagn
  module Set::All::Base
    include Sets

    format :base

    ### ---- Core renders --- Keep these on top for dependencies

    define_view :show, :perms=>:none  do |args|
      render( args[:view] || :core )
    end

    define_view :raw do |args|
#      scard = args[:structure] ? Card[ args[:structure] ] : card
#      Rails.logger.info "rendering raw for #{card.name}.  #{args[:structure]}  #{args[:structure].class}  "
      scard = case args[:structure]
        when nil    ; card
        when :blank ; nil
        else        ; Card[ args[:structure] ]
      end
      scard ? scard.raw_content : _render_blank
    end
    
    define_view :core     do |args|  process_content _render_raw(args)            end
    define_view :content  do |args|  _render_core args                            end
      # this should be done as an alias, but you can't make an alias with an unknown view,
      # and base renderer doesn't know "content" at this point
    define_view :titled   do |args|  card.name + "\n\n" + _render_core(args)      end
                                                                                  
    define_view :name,     :perms=>:none  do |args|  card.name                    end
    define_view :key,      :perms=>:none  do |args|  card.key                     end
    define_view :id,       :perms=>:none  do |args|  card.id                      end
    define_view :linkname, :perms=>:none  do |args|  card.cardname.url_key        end
    define_view :url,      :perms=>:none  do |args|  wagn_url _render_linkname    end

    define_view :link, :perms=>:none  do |args|
      card_link card.name, showname( args[:title] ), card.known?
    end

    define_view :open_content do |args|
      pre_render = _render_core(args) #{ yield args }
      card ? card.post_render(pre_render) : pre_render
    end

    define_view :closed_content do |args|
      truncatewords_with_closing_tags _render_core(args) #{ yield }
    end

###----------------( SPECIAL )
    define_view :array do |args|
      if card.collection?
        card.item_cards(:limit=>0).map do |item_card|
          subrenderer(item_card)._render_core(args)
        end
      else
        [ _render_core(args) ]#{ yield } ]
      end.inspect
    end

    define_view :blank, :perms=>:none do |args| "" end

    define_view :not_found, :perms=>:none, :error_code=>404 do |args|
      %{ Could not find #{card.name.present? ? %{"#{card.name}"} : 'the card requested'}. }
    end

    define_view :server_error, :perms=>:none do |args|
      %{ Wagn Hitch!  Server Error. Yuck, sorry about that.\n}+
      %{ To tell us more and follow the fix, add a support ticket at http://wagn.org/new/Support_Ticket }
    end

    define_view :denial, :perms=>:none, :error_code=>403 do |args|
      focal? ? 'Permission Denied' : ''
    end

    define_view :bad_address, :perms=>:none, :error_code=>404 do |args|
      %{ Bad Address }
    end

    define_view :no_card, :perms=>:none, :error_code=>404 do |args|
      %{ No Card! }
    end

    define_view :too_deep, :perms=>:none do |args|
      %{ Man, you're too deep.  (Too many levels of inclusions at a time) }
    end

    # The below have HTML!?  should not be any html in the base renderer


    define_view :closed_missing, :perms=>:none do |args|
      %{<span class="faint"> #{ showname } </span>}
    end

    define_view :missing, :perms=>:none do |args|
      %{<span class="faint"> #{ showname } </span>}
    end

    define_view :too_slow, :perms=>:none do |args|
      %{<span class="too-slow">Timed out! #{ showname } took too long to load.</span>}
    end
  end
end
