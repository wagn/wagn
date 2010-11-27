require 'diff'
require_dependency 'models/wiki_reference'

class Renderer                
  include HTMLDiff
  include ReferenceTypes

  cattr_accessor :max_char_count, :max_depth
  self.max_char_count = 200
  self.max_depth = 10
  attr_reader :inclusion_map, :sob, :params, :layout, :context, :state
  attr_accessor :char_count, :renders, :item_view, :view, :root, :main_content,
      :main_card, :card, :depth, :type

  def initialize(context='main_1', opts=nil)
    @context = context
#Rails.logger.info "Renderer.new #{context} #{opts.inspect}"
    if opts
      inclusion_map(opts.delete(:inclusion_view_overrides))
      @main_content = opts.delete(:main_content)
      @main_card = opts.delete(:main_card)
      @sob = opts[:base]
      @params = opts[:params]
    end
    @state = :view # when is is different?
    @char_count = 0
    @depth = - max_depth
    @root = self
    @layout = @params && @params[:layout]
  end


  def subrenderer(card, context)
    sub = self.clone
    raise "Too deep" unless ++sub.depth < 0
    #@main_content = @main_card = nil
    @char_count = 0
    @card = card
    sub
  end

  def inclusion_map(overrides=nil)
    return @inclusion_map if @inclusion_map
    return @inclusion_map unless @inclusion_map = overrides
    Slot.view_aliases.each_pair do |known, canonical|
      if @inclusion_map.has_key?(canonical)
        @inclusion_map[known] = @inclusion_map[canonical]
      end
    end
    @inclusion_map
  end

  def render( card, content=nil, opts=true, &block)
    # FIXME: this means if you had a card with content, but you WANTED to have it render 
    # the empty string you passed it, it won't work.  but we seem to need it because
    # card.content='' in set_card_defaults and if you make it nil a bunch of other
    # stuff breaks
    @card = card
    update_refs = case
      when Symbol===opts
        opts == :skip_references ? false : 
	  opts == :update_references ? true : nil
      when Hash===opts
        opts[:update_references] if opts[:update_references]
        if @params = opts[:params]
          @item  = param.to_sym if param = params[:item]
          @view  = param.to_sym if param = params[:view]
        end
      when Array===opts
        opts.member(:skip_references) ? false :
        opts.member(:update_references) ? true : nil
      end
    content = content.blank? ? card.content : content 
    wiki_content = WikiContent.new(card, content, self, opts, inclusion_map)
    update_refs = (card&&card.references_expired) if update_refs == nil
    update_references(card, wiki_content) if update_refs
    wiki_content.render! &block
  end

  def render_diff( card, content1, content2 )
    c1 = WikiContent.new(card, content1, self).render!
    c2 = WikiContent.new(card, content2, self).render!
    diff c1, c2
  end

  def replace_references( card, old_name, new_name )
    #warn "replacing references...card name: #{card.name}, old name: #{old_name}, new_name: #{new_name}"
    content = content.blank? ? card.content : content 
    wiki_content = WikiContent.new(card, content, self)

    wiki_content.find_chunks(Chunk::Link).each do |chunk|
      link_bound = chunk.card_name == chunk.link_text          
      chunk.card_name.replace chunk.card_name.replace_part(old_name, new_name)
      chunk.link_text = chunk.card_name if link_bound
    end
    
    wiki_content.find_chunks(Chunk::Transclude).each do |chunk|
      chunk.card_name.replace chunk.card_name.replace_part(old_name, new_name)
    end

    String.new wiki_content.unrender!  
  end
      
  def expand_card(tname, options)
    # Don't bother processing inclusion if we're already out of view
    return '' if (options[:state]==:line && self.char_count > Renderer.max_char_count)

    case tname
    when '_main'
      if content = main_content and content != '~~render main inclusion~~'
        return layout == 'none' ? content : Slot.wrap_main(content)
      end
      tcard = @main_card
      options[:item] = item_view
      options[:view] = view
      options[:context] = 'main'
      options[:view] ||= :open
      @main_card = @main_content = nil
    end

    options[:view] ||= context == 'layout_0' ? :naked : :content
    options[:fullname] = fullname = get_inclusion_fullname(card, tname,options)
    options[:showname] = tname.to_show(fullname)

    tcard ||= case
    when state ==:edit
      Card.fetch_or_new(fullname, {}, new_inclusion_card_args(options))
    when sob.respond_to?(:name);   sob
    else
      Card.fetch_or_new(fullname, :skip_defaults=>true)
    end

    tcard.loaded_trunk=card if tname =~ /^\+/
    result = yield(tcard, options)
    result = resize_image_content(result, options[:size]) if options[:size]
    @char_count += (result ? result.length : 0) #should we strip html here?
    tname=='_main' ? Slot.wrap_main(result) : result
  rescue Card::PermissionDenied
    ''
  end

  def resize_image_content(content, size)
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end

  def inclusion(tcard, options)
    sub = subrenderer(tcard, options[:context])
    #old_slot, Slot.current_slot = Slot.current_slot, subslot

    # set item_view;  search cards access this variable when rendering their content.
    sub.item_view = options[:item] if options[:item]
    sub.type = options[:type] if options[:type]

    # FIXME! need a different test here
    new_card = tcard.new_record? && !tcard.virtual?

    vmode = (options[:view] || :content).to_sym
    action = case

      when [:name, :link, :linkname].member?(vmode)  ; vmode
      #when [:name, :link, :linkname].member?(vmode)  ; raise "Should be handled in chunks"
      when :edit == state
       tcard.virtual? ? :edit_auto : :edit_in_form
      when new_card
raise "Missed _main?" if tcard.name == '_main'
        case
          when vmode==:naked  ; :blank
          when vmode==:setting; :setting_missing
          when state==:line   ; :closed_missing
          else                ; :open_missing
        end
      when state==:line       ; :expanded_line_content
      else                    ; vmode
      end
    #result =
    ## content templates
    sub.render(tcard, card.templated_content || card.content, options)
    #Slot.current_slot = old_slot
    #result
#  rescue
#    %{<span class="inclusion-error">error rendering #{link_to_page tcard.name}</span>}
  end

  def get_inclusion_fullname(card, name,options)
    fullname = name+'' #weird.  have to do this or the tname gets busted in the options hash!!
    context = case
    when sob; (sob.respond_to?(:name) ? sob.name : sob)
    when options[:base]=='parent'
      card.parent_name
    else
      card.name
    end
    fullname = fullname.to_absolute(context)
    fullname.gsub!('_user') { User.current_user.cardname }
    fullname = fullname.particle_names.map do |x|
      if x =~ /^_/ and params and params[x]
        CGI.escapeHTML( params[x] )
      else x end
    end.join("+")
    fullname
  end

  def get_inclusion_content(cardname)
    #parameters = root.slot_options[:relative_content]
    content = params[cardname.gsub(/\+/,'_')]

    # CLEANME This is a hack to get it so plus cards re-populate on failed signups
    if params['cards'] and card_params = params['cards'][cardname.gsub('+','~plus~')]
      content = card_params['content']
    end
    content if content.present?  #not sure I get why this is necessary - efm
  end

  def new_inclusion_card_args(options)
    args = { :type =>options[:type],  :permissions=>[] }
    if content=get_inclusion_content(options[:tname])
      args[:content]=content
    end
    args
  end

  protected
  def update_references(card, rendering_result)
    WikiReference.delete_all ['card_id = ?', card.id]

	 if card.id and card.respond_to?('references_expired')
    	card.connection.execute("update cards set references_expired=NULL where id=#{card.id}")
    end
    rendering_result.find_chunks(Chunk::Reference).each do |chunk|
      reference_type =
        case chunk
          when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
          when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
          else raise "Unknown chunk reference class #{chunk.class}"
        end
      WikiReference.create!(
        :card_id=>card.id,
        :referenced_name=>chunk.refcard_name.to_key,
        :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
        :link_type=>reference_type
      )
    end
  end
end


