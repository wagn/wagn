require 'diff'
require_dependency 'models/wiki_reference'

class Renderer                
  include HTMLDiff
  include ReferenceTypes

  cattr_accessor :max_char_count, :max_depth
  self.max_char_count = 200
  self.max_depth = 10
  attr_reader :inclusion_map, :sob, :params, :layout, :context, :state, :card, :relative_content
  attr_accessor :char_count, :renders, :item_view, :view, :root, :main_content,
      :main_card, :depth, :type

  def initialize(context='main_1', opts=nil)
    @context = context
Rails.logger.info "Renderer.new[#{context}] #{opts.inspect}\nTrace #{Kernel.caller.slice(0,6).join("\n")}"
    if opts
      inclusion_map(opts.delete(:inclusion_view_overrides))
      @main_content = opts.delete(:main_content)
      @main_card = opts.delete(:main_card)
      @sob = opts[:base]
      @params = opts[:params]
Rails.logger.info "Renderer _keyword #{params[:_keyword]}" if params.has_key? :_keyword
      @relative_content = opts[:relative_content]
    end
Rails.logger.info "main_card #{@main_card&&@main_card.name} #{main_content}"
    @state = :view # when is is different?
    @char_count = 0
    @depth = - max_depth
    @root = self
    @layout = @params && @params[:layout]
Rails.logger.info "Renderer.new:#{@main_content}:#{@main_card&&@main_card.name}:#{@sob}:#{@layout}::#{opts&&opts.inspect}"
  end


  def subrenderer(card, context=nil)
    sub = self.clone
    #raise "Too deep" unless ++sub.depth < 0
    @main_content = @main_card = nil
    @char_count = 0
    @sub.context = context if context
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

  def render( card, content=nil, opts=nil, &block)
    # FIXME: this means if you had a card with content, but you WANTED to have it render 
    # the empty string you passed it, it won't work.  but we seem to need it because
    # card.content='' in set_card_defaults and if you make it nil a bunch of other
    # stuff breaks
    @card = card
Rails.logger.info "Renderer.render #{card.name}, #{content.inspect}, #{opts.inspect}, B:#{block_given?}"
    update_refs = case
      when Symbol===opts
        raw = true if opts == :raw
        opts == :skip_references ? false : 
          opts == :update_references ? true : nil
      when Hash===opts
        opts[:update_references] if opts[:update_references]
        raw = true if opts[:raw]
        if base = opts[:base]
          @sob = opts[:base]
        end
        if @params = opts[:params]
          @item  = param.to_sym if param = params[:item]
          @view  = param.to_sym if param = params[:view]
        end
      when Array===opts
        raw = true if opts.member?(:raw)
        opts.member?(:skip_references) ? false :
        opts.member?(:update_references) ? true : nil
      end
    content = content.blank? ? card.content : content 

    #block = default_block unless block
raise "no card" unless card
    wiki_content = WikiContent.new(card, content, self, opts, inclusion_map)
    if update_refs or card&&card.references_expired
    #if update_refs && card == card or (card&&card.references_expired)
      update_references(card, wiki_content)
    end
    wiki_content.render! do |tname, opts|
      unless raw
        full = opts[:fullname] = get_inclusion_fullname(card, tname, opts)
        #if block_given?
        #  block.call(tname, opts)
        #else
          @view = opts[:view].to_sym if view == nil and opts[:view] 
Rails.logger.info "wiki_render! proc R#{raw}V>#{view.inspect} #{full} #{opts.inspect}"
          rproc = Proc.new do |subcard, renderer, content|
Rails.logger.info "rproc sub #{card.name}[#{card.type}] Sub:#{subcard&&subcard.name}[#{subcard.type}] C:#{content}"; o=
            case subcard && subcard.type
            when 'Search' 
              Wql.new(subcard.get_spec(:return => 'name_content')).run.
                          keys.map {|x| pointee_subrender(x, &rproc)}.join
            when 'Pointer'
              subcard.pointees.map {|x| pointee_subrender(x, &rproc)}.join
            else rendered(subcard) end
Rails.logger.info "rproc res #{o}"; o
          end
          case view
          when nil
Rails.logger.info "wiki_content proc nil view: #{card.name} : #{full}"
            #tcard = Card.fetch_or_new(full) if full != card.name
            #renderer_content(card)
            rproc.call(card, self, renderer_content(card, content))
            #expand_inclusions(content)
            #block.call(full, opts)
          when :naked
            raise "<no card ? #{full}/>" unless card = Card.fetch(full)
            #rproc.call(card, self, renderer_content(card))
Rails.logger.info "rproc call #{card.name} C:#{content.inspect}"
            rproc.call(card, self, renderer_content(card, content))
	  else 
Rails.logger.info "render! yields #{tname} #{opts.inspect}"
            block.call(tname, opts)
          end
        #end
      else
raise "need block?" unless block_given?
Rails.logger.info "render! yields2 #{tname} #{opts.inspect}"
        block.call(tname, opts)
      end
    end
  end

###
=begin
  def default_block
    Proc.new do |tname, opts|
      @view = opts[:view].to_sym if view == nil and opts[:view] 
Rails.logger.info "default_block[#{view.inspect}]#{tname} :: #{card.name} Opts:#{opts.inspect}"
      case view
      when nil
        @card = Card.fetch_or_new(tname) if tname != card.name
        renderer_content(card)
      when :naked
       unless card = Card.fetch(tname)
        "<no card #{tname}/>"
       else
begin
r= 
        case card.type
        when 'Search'
Rails.logger.info "Search transclude #{tname} Spc:#{card.get_spec(:return => 'name_content').inspect}"
          Wql.new(card.get_spec(:return => 'name_content')).run.keys.map do |x|
Rails.logger.info "Search transclude #{tname}"
Rails.logger.info "Search item transclude #{x}"
          rendered(Card.fetch_or_new(x))
          end.join
        when 'Pointer'
Rails.logger.info "Pointer transclude #{tname}"
          card.pointees.map do |x|
Rails.logger.info "Pointer item transclude #{x.name}"
            rendered(Card.fetch_or_new(x))
          end.join
        else
          renderer_content(card)
        end
Rails.logger.info "Search transclude res #{r}"; r
rescue Exception => e
Rails.logger.info "Error transclude :#{e.class}, #{e.message}, #{e.backtrace.join("\n")}"
raise e
end
       end
else Rails.logger.info "Can't do that view here #{view.inspect}"
      #else raise "Can't do that view here #{view.inspect}"
      end
    end
  end
=end

  def rendered(card)
    r_content = renderer_content(card)
o=
    case item_view || view
    when :content, nil; r_content
    else                render(sob||card, r_content)
    #else                render(card, r_content)
    end
Rails.logger.info "P/S rendered transclude #{card.name}|#{sob&&sob.name},#{view}I#{item_view} C:#{r_content} > #{o}"; o
  end

  def renderer_content(card, content='')
    return "<no card #{self}/>" unless card
    #card.templated_content || card.content
    card.templated_content || content.blank? ? card.content : content 
  end

  def pointee_subrender(pointee, context=nil)
    sub = subrenderer( subcard = Card.fetch_or_new(pointee) )
Rails.logger.info "subrender #{pointee} #{card.name}, #{subcard.name}, #{sub.card.name}"
    sub.context = context if context
    sub.item_view = sub.view = item_view||view||:closed
    content = subcard.templated_content || subcard.content
#raise "loop? #{card.name}" if card == subcard
Rails.logger.info "Sub[#{card.type}]#{sub.item_view} #{sub.view} #{view} #{subcard.name}::#{card.name} C:#{content} S:#{sub}"
    yield subcard, sub, content
  end
####

  def render_diff( card, content1, content2 )
    c1 = WikiContent.new(card, content1, self).render!
    c2 = WikiContent.new(card, content2, self).render!
    diff c1, c2
  end

  def replace_references( card, old_name, new_name )
    #warn "replacing references...card name: #{card.name}, old name: #{old_name}, new_name: #{new_name}"
    #content = content.blank? ? card.content : content 
    wiki_content = WikiContent.new(card, card.content, self)

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
      
  def expand_inclusions(content)
Rails.logger.info "expand_inclusions #{card.name} #{content}"
    render(card, content) do |cardname,opts|
      expand_card(cardname,opts) do |tcard, opts|
Rails.logger.info "expand_inclusions #{tcard.name} #{opts.inspect}"
        process_inclusion(tcard, opts)
      end
    end
  end

  def expand_card(tname, options)
    return options[:comment] if options.has_key?(:comment)
Rails.logger.info "expand_card(#{tname}, #{options.inspect}) #{options[:state]}:#{char_count}"
    # Don't bother processing inclusion if we're already out of view
    return '' if (options[:state]==:line && self.char_count > Renderer.max_char_count)

    if is_main = tname == '_main'
      if content = main_content and content != '~~render main inclusion~~'
Rails.logger.info "expand_card _main #{tname} C:#{content}"
        return layout == 'none' ? content : Slot.wrap_main(content)
      end
      tcard = @main_card
      tname = tcard.name
Rails.logger.info "expand_card _main2 #{tcard&&tcard.name} ST:#{state}"
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
Rails.logger.info "tcard result #{result}" if is_main
    is_main ? Slot.wrap_main(result) : result
  rescue Card::PermissionDenied
    ''
  end

  def resize_image_content(content, size)
Rails.logger.info "resize_image_content #{content} #{size}"
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end

  def process_inclusion(tcard, options)
#raise "process_inclusion(#{tcard.name}, #{options.inspect}"
Rails.logger.info "process_inclusion(#{tcard.name}, #{options.inspect}"
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
Rails.logger.info "S/P ? #{tcard.name} #{tcard.type}" if tcard.type == 'Pointer' or tcard.type == 'Search'
    sub.render(tcard, card.templated_content || card.content, options)
    #Slot.current_slot = old_slot
    #result
#  rescue
#    %{<span class="inclusion-error">error rendering #{link_to_page tcard.name}</span>}
  end

  def get_inclusion_fullname(card, name,options)
Rails.logger.info "get_inclusion_fullname(#{card.name}, #{name}, #{options.inspect}"
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
Rails.logger.info "param subs #{x} #{params.inspect} :: #{params and params[x]}" if x =~ /^_/
      if x =~ /^_/ and params and params[x]
        CGI.escapeHTML( params[x] )
      else x end
    end.join("+")
    fullname
  end

  def get_inclusion_content(cardname)
    #parameters = root.slot_options[:relative_content]
    content = relative_content[cardname.gsub(/\+/,'_')]

    # CLEANME This is a hack to get it so plus cards re-populate on failed signups
    if relative_content['cards'] and card_params = relative_content['cards'][cardname.gsub('+','~plus~')]
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
Rails.logger.info "update_references1 #{card.name}, #{rendering_result}"
    WikiReference.delete_all ['card_id = ?', card.id]

    if card.id and card.respond_to?('references_expired')
      card.connection.execute("update cards set references_expired=NULL where id=#{card.id}")
      rendering_result.find_chunks(Chunk::Reference).each do |chunk|
        reference_type =
          case chunk
            when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
            when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
            else raise "Unknown chunk reference class #{chunk.class}"
          end

Rails.logger.info "update_reference: ID:#{card.id}, RN:#{chunk.refcard_name.to_key}, RCID:#{chunk.refcard ? chunk.refcard.id : nil}, LT:#{reference_type}"

        WikiReference.create!( :card_id=>card.id,
          :referenced_name=>chunk.refcard_name.to_key,
          :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
          :link_type=>reference_type
         )
      end
    end
  end
end


