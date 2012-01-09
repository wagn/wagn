#require_dependency 'rich_html_renderer'
require 'diff'

module WagnHelper
  require_dependency 'wiki_content'
  include HTMLDiff

  # FIXME: slot -> renderer (model)
  # Put the initialization in the controller and we no longer care here
  # whether it is a Slot or Renderer, and it will be from the parent class
  #   Now: Always a Renderer, and the subclass is selected by:
  #     :format => :html (default and only -> Wagn::Renderer::Html (was Slot))

#=begin
  def slot() Wagn::Renderer.current_slot end
  def card() @card ||= slot.card end
    
  def params()
    if controller
      controller.params 
    else
      slot and slot.params
    end
  end

  # FIXME: I think all this slot initialization should happen in controllers
  def get_slot(card=nil)
    nil_given = card.nil?
    card ||= @card

    slot = 
      if current = Wagn::Renderer.current_slot
        nil_given ? current : current.subrenderer(card)
      else
        opts = { :controller => self.controller }
        Wagn::Renderer.current_slot = Wagn::Renderer.new( card, opts )
      end
  end


  def truncatewords_with_closing_tags(input, words = 25, truncate_string = "...")
    if input.nil? then return end
    wordlist = input.to_s.split
    l = words.to_i - 1
    l = 0 if l < 0
    wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input
    # nuke partial tags at end of snippet
    wordstring.gsub!(/(<[^\>]+)$/,'')

    tags = []

    # match tags with or without self closing (ie. <foo />)
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\>/).each { |t| tags.unshift(t[0]) }
    # match tags with self closing and mark them as closed
    wordstring.scan(/\<([^\>\s\/]+)[^\>]*?\/\>/).each { |t| if !(x=tags.index(t[0])).nil? then tags.slice!(x) end }
    # match close tags
    wordstring.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t|  if !(x=tags.rindex(t[0])).nil? then tags.slice!(x) end  }

    tags.each {|t| wordstring += "</#{t}>" }

    wordstring +='<span class="closed-content-ellipses">...</span>' if wordlist.length > l
#    wordstring += '...' if wordlist.length > l
    wordstring.gsub! /<[\/]?br[\s\/]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring.gsub! /<[\/]?p[^>]*>/, ' ' ## Also a hack -- get rid of <br>'s -- they make line view ugly.
    wordstring
  end


  def formal_joint
    " <span class=\"wiki-joint\">+</span> "
  end

  def formal_title(card)
    card.cardname.parts * formal_joint
  end

  def fancy_title(card)
    cardname = (Card===card ? card.cardname : card.to_cardname)
    return cardname if cardname.simple?
    card_title_span(cardname.left_name) + %{<span class="joint">+</span>} +
       card_title_span(cardname.tag_name)
  end

  # Other snippets -------------------------------------------------------------


  def format_date(date, include_time = true)
    # Must use DateTime because Time doesn't support %e on at least some platforms
    if include_time
      DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
    else
      DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
    end
  end

  ## ----- for Linkers ------------------
  def typecode_options
    Cardtype.createable_types.map do |type|
      [type[:name], type[:name]]
    end.compact
  end

  def typecode_options_for_select(selected=Card.default_typecode_key)
    #warn "SELECTED = #{selected}"
    options_from_collection_for_select(typecode_options, :first, :last, selected)
  end


  def error_messages_for(object)
    if object && object.errors.any?
      %{<div class="errors-view">#{object.errors.full_messages.map{ |msg| "<div>#{msg}</div>"}.join("\n")}</div>}
    end
  end


  def wrap_slot(renderer=nil, args={}, &block)
    renderer ||= (Wagn::Renderer.current_slot || get_slot)
    content = with_output_buffer { yield(renderer) } 
    renderer.wrap(:open, args) { content }
  end
  # ------------( helpers ) --------------

end
