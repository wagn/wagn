# -*- encoding : utf-8 -*-
require 'diff'

module WagnHelper
  include Card::Diff

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
    wordstring = wordlist.length > l ? wordlist[0..l].join(" ") : input.to_s
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

  def error_messages_for(object)
    if object && object.errors.any?
      %{<div class="errors-view">#{object.errors.full_messages.map{ |msg| "<div>#{msg}</div>"}.join("\n")}</div>}
    end
  end


  def wrap_slot(renderer=nil, args={}, &block)
    renderer ||= (Wagn::Renderer.current_slot || get_slot)
    content = with_output_buffer { yield(renderer) }
    renderer.wrap(:open, args.merge(:frame=>true)) { content }
  end
  # ------------( helpers ) --------------

end
