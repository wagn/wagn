require_dependency 'rich_html_renderer'
require_dependency 'models/wiki_reference'
require 'diff'

class Renderer
  module NoControllerHelpers
    def protect_against_forgery?
      # FIXME
      false
    end

    def logged_in?
      !(User.current_user.nil? || User.current_user.login == 'anon')
    end
  end

  include ReferenceTypes

  VIEW_ALIASES = {
    :view => :open,
    :card => :open,
    :line => :closed,
    :bare => :naked,
  }

  RENDERERS = {
    :html => :RichHtmlRenderer,
  }

  cattr_accessor :max_char_count, :max_depth, :set_views,
    :current_slot, :ajax_call, :fallback_methods
  self.max_char_count = 200
  self.max_depth = 10

  attr_reader :action, :inclusion_map, :params, :layout, :relative_content,
      :template, :root, :format
  attr_accessor :card, :main_content, :main_card, :context, :char_count,
      :depth, :item_view, :form, :view, :type, :base, :state, :sub_count,
      :render_args, :requested_view, :layout, :flash, :show_view

  # View definitions
  #
  #   When you declare:
  #     view(:view_name, "<set pattern>") do |args|
  #
  #   Methods are defined on the renderer
  #
  #     # The external api with checks, equivalent to
  #     def render_name(args={}) ... end
  #     render(_<name>)(:view_name, args)
  #
  #     # The internal call that skips the checks
  #     def _render(_<name>)(args={} ... end
  #
  #   Where <name> is the pattern key (i.e. '<type card>+type' of
  #     for patterns other than AllPattern ('*all')
  #
  class << self
    def view(view, opts={}, &final)
      @@set_views, @@fallback_methods = {},{} unless @@set_views
      fallback_methods[view] = opts[:fallback_method] if opts.has_key?(:fallback_method)

      def arg(a) opts.delete(a).gsub('+','_').to_key end
      pattern_key = case
        when name = arg(:name); '_self_'+name
        when type = arg(:type); '_type_'+type
        when (type = arg(:ltype)) and opts.has_key(:right);
          "_ltype_rt_#{type}_#{arg(:right)}"
        when right = arg(:right); '_right_'+right
        else ''
        end
      raise "Error extra args #{opts.inspect}" unless opts.empty?
      method_id = "render#{pattern_key}_#{view}"

Rails.logger.info "view declared: #{view}, #{set}, #{pattern_key.inspect}, #{method_id}"
      raise "Attempt to redefine view: #{view} #{set} #{method_id}" if @@set_views.has_key?(method_id)

      priv_name = @@set_views[method_id] = "_#{method_id}".to_sym
Rails.logger.info "define methods: #{method_id}, #{priv_name}, #{method_id.sub(/^render/,'_final')}"
      class_eval do

        define_method( method_id.sub(/^render/,'_final'), &final )
        define_method( priv_name ) do |*a| a = [{}] if a.empty?
          a[0][:view] ||= view  
          # this variable name is highly confusing (:view); it means the view to
          # return to after an edit.  it's about persistence. should do better.
          final_meth = view_method( view ).to_s.sub(/^_render/,'_final')
          send(final_meth.to_sym, *a) { yield }
        end

        define_method( method_id ) do |*a|
#Rails.logger.info "#{method_id}: #{card&&card.name}, #{a.inspect} #{caller.slice(0,4)*"\n"}"
          if refusal=render_check(method_id)
            return refusal
          end

raise "no method #{method_id}, #{view}: #{@@set_views.inspect}" unless view_method( view )
          send(view_method( view ), *a) { yield }
        end
      end
    end

    def new(card, opts=nil)
      fmt = (opts and opts[:format]) ? opts[:format] : :html
      if RENDERERS.has_key?(fmt)
        Renderer.const_get(RENDERERS[fmt]).new(card, opts)
      else
        new_renderer = self.allocate
        new_renderer.send :initialize, card, opts
        new_renderer
      end
    end

    def set_view(key) Renderer.set_views[key] end
    def view_aliases() VIEW_ALIASES end
  end

  FORMAT2VIEW = {
    :txt => :raw,
    :css => :naked,
    :kml => :show, # partial
    :xml => nil,
    :json => nil,
    :xhr => :naked,
    :html => :layout
  }

=begin
        ## fixme, we ought to be setting special titles (or all titles) in cards
        request.xhr? ? render(:action=>'show') : render(:text=>'', :layout=>true)
=end

  def initialize(card, opts=nil)
    Renderer.current_slot ||= self
    @card = card
    if opts
      [:main_content, :main_card, :base, :action, :context, :template,
        :params, :relative_content, :format, :flash, :layout].
          map {|s| instance_variable_set "@#{s}", opts[s]}
    end
    inclusion_map( opts )
    @show_view = FORMAT2VIEW[format]
    @params ||= {}
    @relative_content ||= {}
    @action ||= 'view'
    @format ||= :html
    @template ||= begin
      t = ActionView::Base.new( CardController.view_paths, {} )
      t.helpers.send :include, CardController.master_helper_module
      t.helpers.send :include, NoControllerHelpers
      t
    end
    @sub_count = @char_count = 0
    @depth = 0
    @root = self
    if layout == :xhr
      @layout = 'none'
    elsif @params && @params[:layout]
      @layout = @params[:layout]
    end
  end

  def ajax_call?() @@ajax_call end
  def outer_level?() @depth == 0 end

  def too_deep?() @depth >= max_depth end

  def subrenderer(subcard, ctx_base=nil)
    subcard = Card.fetch_or_new(subcard) if String===subcard
    self.sub_count += 1
    sub = self.clone
    sub.depth = @depth+1
    sub.view = sub.item_view = sub.main_content = sub.main_card = nil
    sub.sub_count = sub.char_count = 0
    sub.context = "#{ctx_base||context}_#{sub_count}"
    sub.card = subcard
    sub
  end

  def inclusion_map(opts)
    return @inclusion_map if @inclusion_map
    return @inclusion_map = self.class.view_aliases unless opts and
      @inclusion_map = opts[:inclusion_view_overrides]
    self.class.view_aliases.each_pair do |known, canonical|
      if @inclusion_map.has_key?(canonical)
        @inclusion_map[known] = @inclusion_map[canonical]
      end
    end
    @inclusion_map
  end

  def process_content(content=nil, opts={})
    return content unless card
    content = card.content if content.blank?

    wiki_content = WikiContent.new(card, content, self, inclusion_map)
    if card&&card.references_expired
      update_references(wiki_content)
    end
    wiki_content.render! do |opts|
#      full = opts[:fullname] = get_inclusion_fullname(tname, opts)
      @view = opts[:view].to_sym if view == nil and opts[:view]
      expand_inclusion(opts) { yield }
    end
  end

  def render_check(action)
    ch_action = case
    when too_deep?;  :too_deep
    when card.new_card?; false # causes errors to check in current system.  
      #should remove this and add create check after we settingize permissions
    when [:edit, :edit_in_form, :multi_edit].member?(action)
      !card.ok?(:edit) and :deny_view #should be deny_edit
    else
      !card.ok?(:read) and :deny_view
    end
    (ch_action and render_partial("views/#{ch_action}"))
  end

  def render_deny(action, args)
    if [ :deny_view, :edit_auto, :too_slow, :too_deep, :open_missing,
         :closed_missing, :setting_missing].member?(action)
       render_partial("views/#{action}", args)
    elsif card.new_record?; return # need create check...
    else render_check(action) end
  end

  def canonicalize_view( view )
    (view and v=VIEW_ALIASES[view.to_sym]) ? v : view
  end

  def expand_inclusions(content)
    process_content(content) 
  end

### ---- Core renders --- Keep these on top for dependencies
  view(:raw) do card.raw_content end
  view(:core) do process_content(_render_raw) end

  view(:naked) do |args|
    case
      when card.name.template_name?  ; _render_raw
      when card.generic?             ; _render_core
      else render_card_partial(:content)
    end
  end

###----------------( NAME)
  view(:name)     do card.name end
  view(:key)      do card.key end
  view(:link)     do Chunk::Reference.standard_card_link(card.name) end
  view(:linkname) do card.name.to_url_key end

  view(:open_content) do |args|
    card.post_render(_render_naked(args) { yield })
  end

  view(:closed_content) do |args|
    if card.generic?
      truncatewords_with_closing_tags( _render_naked(args) { yield } )
    else
      render_card_partial(:line)   # in basic case: --> truncate( slot._render_open_content ))
    end
  end

###----------------( SPECIAL )
  view(:array) do |args|
    if card.is_collection?
      (card.each_name do |name|
        subrenderer(name)._render_core { yield }
      end.inspect)
    else
      [_render_naked(args) { yield }].inspect
    end
  end

  view(:blank) do "" end

  view(:rss_titled) do |args|
    # content includes wrap  (<object>, etc.) , which breaks at least safari rss reader.
    content_tag( :h2, fancy_title(card.name) ) + self._render_open_content(args) { yield }
  end

  view(:rss_change) do
    self.requested_view = 'content'
    render_partial('views/change')
  end

  def render(action=:view, args={})
raise "???" if Hash===action
    args[:view] ||= action
    self.render_args = args.clone
    denial = render_deny(action, args)
    return denial if denial

    action = canonicalize_view(action)
    @state ||= case action
      when :edit, :multi_edit; :edit
      when :closed; :line
      else :view
    end

    result = if render_meth = view_method(action)
        send(render_meth, args) { yield }
      else
        "<strong>#{card.name} - unknown card view: '#{action}' M:#{render_meth.inspect}</strong>"
      end

    result << javascript_tag("setupLinksAndDoubleClicks();") if args[:add_javascript]
    result.strip
  rescue Exception=>e
    Rails.logger.debug "Error #{e.inspect} #{e.backtrace*"\n"}"
    raise e unless Card::PermissionDenied===e
    return "Permission error: #{e.message}"
  end

  def view_method(view)
    Wagn::Pattern.set_names( card ).each do |setname|
      setname = setname.sub(/all/,'').gsub(/(\+|^)_*\*/,'_').to_key
      setname = setname.blank? ? view.to_s : "#{setname}_#{view}"
      meth = self.class.set_view("render_#{setname}")
Rails.logger.info "view_method( #{setname}, #{view} ) #{meth}" if meth
      return meth if meth
    end
#Rails.logger.info "view_method( #{view} ) F: #{@@fallback_methods[view]}\nTrace #{caller.slice(0,6)*"\n"}"
    return @@fallback_methods[view]
  end
  
  def form_for_multi
    #Rails.logger.info "card = #{card.inspect}"
    options = {} # do I need any? #args.last.is_a?(Hash) ? args.pop : {}
    block = Proc.new {}
    builder = options[:builder] || ActionView::Base.default_form_builder
    card.name.gsub!(/^#{Regexp.escape(root.card.name)}\+/, '+') if root.card.new_record?  ##FIXME -- need to match other relative inclusions.
    fields_for = builder.new("cards[#{card.name.pre_cgi}]", card, template, options, block)
  end

  def form
    @form ||= form_for_multi
  end

  def resize_image_content(content, size)
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end

  def render_partial( partial, locals={} )
    template.render(:partial=>partial, :locals=>{ :card=>card, :slot=>self }.merge(locals))
  end

  def card_partial(action)
    # FIXME: I like this method name better- maybe other calls should resolve here instead
    partial_for_action(action, card)
  end

  def render_card_partial(action, locals={})
     render_partial card_partial(action), locals
  end

  def method_missing(method_id, *args, &proc)
    # silence Rails 2.2.2 warning about binding argument to concat.  tried detecting rails 2.2
    # and removing the argument but it broken lots of integration tests.
    ActiveSupport::Deprecation.silence { @template.send(method_id, *args, &proc) }
  end

  def replace_references( old_name, new_name )
    #warn "replacing references...card name: #{card.name}, old name: #{old_name}, new_name: #{new_name}"
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

  def expand_inclusion(options)

    return options[:comment] if options.has_key?(:comment)

    # Don't bother processing inclusion if we're already out of view
    return '' if (state==:line && self.char_count > Renderer.max_char_count)

    tname=options[:tname]
    if is_main = tname=='_main'
      tcard, tcont = root.main_card, root.main_content
      return tcont if tcont
      return "{{#{options[:unmask]}}}" || '{{_main}}' unless @depth == 0 and tcard
      tname = tcard.name
      item  = symbolize_param(:item) and options[:item] = item
      pview = symbolize_param(:view) and options[:view] = pview
      options[:context] = 'main'
      options[:view] ||= :open
    end

    options[:view] ||= context == 'layout_0' ? :naked : :content
    options[:fullname] = fullname = get_inclusion_fullname(tname,options)
    options[:showname] = tname.to_show(fullname)

    tcard ||= begin
      case
      when state ==:edit   ;  Card.fetch_or_new(fullname, {}, new_inclusion_card_args(options))
      when base.respond_to?(:name);   base
      else                 ;  Card.fetch_or_new(fullname, :skip_defaults=>true)
      end
    end

    tcard.loaded_trunk=card if tname =~ /^\+/
    result = process_inclusion(tcard, options)
    result = resize_image_content(result, options[:size]) if options[:size]
    @char_count += (result ? result.length : 0) #should we strip html here?
    (is_main and respond_to?(:wrap_main)) ? self.wrap_main(result) : result
  rescue Card::PermissionDenied
    ''
  end

  def symbolize_param(param)
    val = params[param]
    (val && !val.to_s.empty?) ? val.to_sym : nil
  end

  def resize_image_content(content, size)
    size = (size.to_s == "full" ? "" : "_#{size}")
    content.gsub(/_medium(\.\w+\")/,"#{size}"+'\1')
  end


  def process_inclusion(tcard, options)
    sub = subrenderer(tcard, options[:context])
    oldrenderer, Renderer.current_slot = Renderer.current_slot, sub

    # set item_view;  search cards access this variable when rendering their content.
    sub.item_view = options[:item] if options[:item]
    sub.type = options[:type] if options[:type]
    options[:showname] ||= tcard.name

    new_card = tcard.new_record? && !tcard.virtual?

    vmode = (options[:view] || :content).to_sym
    sub.requested_view = vmode
    action = case

      when [:name, :link, :linkname].member?(vmode)  ; vmode
      when :edit == state
       tcard.virtual? ? :edit_auto : :edit_in_form
      when new_card
        case
          when vmode==:raw    ; :blank
          when vmode==:setting; :setting_missing
          when state==:line   ; :closed_missing
          else                ; :open_missing
        end
      when state==:line       ; :closed_content
      else                    ; vmode
      end
    result = sub.render(action, options)
    Renderer.current_slot = oldrenderer
    result
  rescue Exception=>e
    Rails.logger.info "inclusion-error #{e.inspect}"
    Rails.logger.debug "Trace:\n#{e.backtrace*"\n"}"
    %{<span class="inclusion-error">error rendering #{link_to_page((tcard ? tcard.name : 'unknown card'), nil, :title=>CGI.escapeHTML(e.inspect))}</span>}
  end

  def get_inclusion_fullname(name,options)
    fullname = name+'' #weird.  have to do this or the tname gets busted in the options hash!!
    context = case
    when base; (base.respond_to?(:name) ? base.name : base)
    when options[:base]=='parent'
      card.parent_name
    else
      card.name
    end
    fullname = fullname.to_absolute(context)
    fullname = fullname.particle_names.map do |x|
      if x =~ /^_/ and params and params[x]
        CGI.escapeHTML( params[x] )
      else x end
    end.join("+")
    fullname
  end

  def get_inclusion_content(cardname)
    content = relative_content[cardname.gsub(/\+/,'_')]

    # CLEANME This is a hack to get it so plus cards re-populate on failed signups
    if relative_content['cards'] and card_params = relative_content['cards'][cardname.pre_cgi]
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

  def update_references(rendering_result=nil)
    return unless card
    WikiReference.delete_all ['card_id = ?', card.id]

    if card.id and card.respond_to?('references_expired')
      card.connection.execute("update cards set references_expired=NULL where id=#{card.id}")
      rendering_result ||= WikiContent.new(card, _render_raw, self)
      rendering_result.find_chunks(Chunk::Reference).each do |chunk|
        reference_type =
          case chunk
            when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
            when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
            else raise "Unknown chunk reference class #{chunk.class}"
          end


        WikiReference.create!( :card_id=>card.id,
          :referenced_name=>chunk.refcard_name.to_key,
          :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
          :link_type=>reference_type
         )
      end
    end
  end

  ### ------  from wagn_helper ----
  def partial_for_action( name, card=nil )
    # FIXME: this should look up the inheritance hierarchy, once we have one
    # wow this is a steaming heap of dung.
    cardtype = (card ? card.type : 'Basic').underscore
    if Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR <=1
      finder.file_exists?("/types/#{cardtype}/_#{name}") ?
        "/types/#{cardtype}/#{name}" :
        "/types/basic/#{name}"
    elsif   Rails::VERSION::MAJOR >=2 && Rails::VERSION::MINOR > 2
      ## This test works for .rhtml files but seems to fail on .html.erb
      begin
        @template.view_paths.find_template "types/#{cardtype}/_#{name}"
        "types/#{cardtype}/#{name}"
      rescue ActionView::MissingTemplate => e
        "/types/basic/#{name}"
      end
    else
      @template.view_paths.find { |template_path| template_path.paths.include?("types/#{cardtype}/_#{name}") } ?
        "/types/#{cardtype}/#{name}" :
        "/types/basic/#{name}"
    end
  end

  def paging_params
    s = {}
    if p = root.params
      [:offset,:limit].each{|key| s[key] = p.delete(key)}
    end
    s[:offset] = s[:offset] ? s[:offset].to_i : 0
    s[:limit]  = s[:limit]  ? s[:limit].to_i  : (main_card? ? 50 : 20)
    s
  end

  def main_card?() context=~/^main_\d$/ end
end

