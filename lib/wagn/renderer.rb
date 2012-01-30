#WikiReference # is this needed?

module Wagn
  class Renderer
    include ReferenceTypes

    DEPRECATED_VIEWS = { :view=>:open, :card=>:open, :line=>:closed, :bare=>:core, :naked=>:core }
    UNDENIABLE_VIEWS = [ :deny_view, :denial, :errors, :edit_virtual, :too_slow, :too_deep, :missing, 
      :not_found, :closed_missing, :name, :link, :linkname, :url, :show, :layout, :bad_address, :server_error ]
    INCLUSION_MODES  = { :main=>:main, :closed=>:closed, :edit=>:edit, :layout=>:layout, :new=>:edit }
    DEFAULT_ITEM_VIEW = :link
  
    RENDERERS = {
      :html => :Html,
      :css  => :Text,
      :txt  => :Text
    }
    
    cattr_accessor :current_slot, :ajax_call

    @@max_char_count = 200
    @@max_depth = 10
    @@set_views = {}

    class << self
      def get_pattern(view,opts)
        unless pkey = Wagn::Model::Pattern.method_key(opts) #and opts.empty?
          raise "Bad Pattern opts: #{pkey.inspect} #{opts.inspect}"
        end
        return (pkey.blank? ? view : "#{pkey}_#{view}").to_sym
      end
  
      def register_view(view_key, nview_key)
        if @@set_views.has_key?(nview_key)
          raise "Attempt to redefine view: #{nview_key}, #{view_key}"
        end
        @@set_views[nview_key.to_sym] = "_final_#{view_key}".to_sym
      end
  
  
      def new(card, opts={})
        if self==Renderer
          fmt = (opts[:format] ? opts[:format].to_sym : :html)
          renderer = (RENDERERS.has_key?(fmt) ? RENDERERS[fmt] : fmt.to_s.camelize).to_sym
          if Renderer.const_defined?(renderer)
            return Renderer.const_get(renderer).new(card, opts) 
          end
        end
        new_renderer = self.allocate
        new_renderer.send :initialize, card, opts
        new_renderer
      end
  
      def set_view(key) @@set_views[key.to_sym] end
  
    # View definitions
    #
    #   When you declare:
    #     define_view(:view_name, "<set>") do |args|
    #
    #   Methods are defined on the renderer
    #
    #   The external api with checks:
    #     render(:viewname, args)
    #
    #   Roughly equivalent to:
    #     render_viewname(args)
    #
    #   The internal call that skips the checks:
    #     _render_viewname(args)
    # 
    #   Each of the above ultimately calls:
    #     _final(_set_key)_viewname(args)


      def define_view(view, opts={}, &final)
        view_key = get_pattern(view, opts)
        define_method( "_final_#{view_key}", &final )

        if !method_defined? "render_#{view}"
          define_method( "_render_#{view}" ) do |*a| a = [{}] if a.empty?
            if final_method = view_method(view)
              with_inclusion_mode(view) { send(final_method, *a) }
            else
              "<strong>#{card.name} - unknown card view: '#{view}'</strong>"
            end
          end

          define_method( "render_#{view}" ) do |*a|
            begin
              denial=deny_render(view, *a) and return denial
              msg = "render #{view} #{ card ? "called for #{card.name}" : '' }"
              ActiveSupport::Notifications.instrument 'wagn.render', :message=>msg do
                send( "_render_#{view}", *a)
              end
            rescue Exception=>e
              Rails.logger.debug "Error #{e.message} #{e.backtrace*"\n"}"
              raise e          
            end
          end
        end
        #end
      end

      def alias_view(view, opts={}, *aliases)
        view_key = get_pattern(view, opts)
        aliases.each do |aview|
          aview_key = case aview
            when String; aview
            when Symbol; (view_key==view ? aview.to_sym : view_key.to_s.sub(/_#{view}$/, "_#{aview}").to_sym)
            when Hash;   get_pattern( aview[:view] || view, aview)
            else; raise "Bad view #{aview.inspect}"
            end

          define_method( "_final_#{aview_key}".to_sym ) do |*a|
            send("_final_#{view_key}", *a)
          end
        end
      end
    end

    attr_reader :card, :root, :showname #should be able to factor out showname
    attr_accessor :form, :main_content, :main_card
  
  
    def initialize(card, opts={})
      Renderer.current_slot ||= self unless(opts[:not_current])
      @card = card
      opts.each { |key, value| instance_variable_set "@#{key}", value }
  
      @format ||= :html
      @char_count = @depth = 0
      @root = self
      
      if card && card.collection? && params[:item] && !params[:item].blank?
        @item_view = params[:item]
      end
      
    end


    def params()     @params     ||= controller.params                          end
    def flash()      @flash      ||= controller.request ? controller.flash : {} end
    def controller() @controller ||= StubCardController.new                     end

    def session
      CardController===controller ? controller.session : {}
    end
  
    def template
      @template ||= begin
        c = controller
        t = ActionView::Base.new c.class.view_paths, {:_routes=>c._routes}, c
        t.extend c.class._helpers
        t
      end
    end
    
    def render(view=:view, args={})
      send("render_#{canonicalize_view view}", args)
    end
    
    
    def method_missing(method_id, *args, &proc)
      proc = proc {|*a| raw yield *a } if proc
      template.send(method_id, *args, &proc) 
    end
    
  
    def ajax_call?() @@ajax_call end
    def outer_level?() @depth == 0 end
  
    def too_deep?() @depth >= @@max_depth end
  
    def subrenderer(subcard, opts={})
      subcard = Card.fetch_or_new(subcard) if String===subcard
      sub = self.clone
      sub.initialize_subrenderer(subcard, opts)
    end

    def initialize_subrenderer(subcard, opts)
      @card = subcard
      @char_count = 0
      @depth += 1
      @item_view = @main_content = @main_card = @showname = nil
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      self
    end
  
    def process_content(content=nil, opts={})
      return content unless card
      content = card.content if content.blank?
  
      wiki_content = WikiContent.new(card, content, self)
      update_references(wiki_content) if card.references_expired
  
      wiki_content.render! do |opts|
        expand_inclusion(opts) { yield }
      end
    end
    alias expand_inclusions process_content
  
  
    def deny_render(action, args={})
      return false if UNDENIABLE_VIEWS.member?(action)
      ch_action = case
        when too_deep?      ; :too_deep
        when !card          ; false
        when [:edit, :edit_in_form].member?(action)
          allowed = card.ok?(card.new_card? ? :create : :update)
          !allowed && :deny_view #should be deny_create or deny_update...
        else
          !card.ok?(:read) and :deny_view #should be deny_read
      end
      ch_action and render(ch_action, args)
    end
    
    def canonicalize_view( view )
      (v=!view.blank? && DEPRECATED_VIEWS[view.to_sym]) ? v : view
    end
  
    def view_method(view)
      return "_final_#{view}" unless card
      card.method_keys.each do |method_key|
        meth = "_final_"+(method_key.blank? ? "#{view}" : "#{method_key}_#{view}")
        return meth if respond_to?(meth.to_sym)
      end
      nil
    end
  
    def with_inclusion_mode(mode)
      if switch_mode = INCLUSION_MODES[ mode ]
        old_mode, @mode = @mode, switch_mode
      end
      result = yield
      @mode = old_mode if switch_mode
      result      
    end
  
    def expand_inclusion(opts)
      return opts[:comment] if opts.has_key?(:comment)
      # Don't bother processing inclusion if we're already out of view
      return '' if @mode == :closed && @char_count > @@max_char_count
  
      return expand_main(opts) if opts[:tname]=='_main' && !ajax_call? && @depth==0
      
      opts[:view] = canonicalize_view opts[:view]
      opts[:view] ||= ( @mode == :layout ? :core : :content )
      
      tcardname = opts[:tname].to_cardname
      opts[:fullname] = tcardname.to_absolute(card.cardname, params)
      opts[:showname] = tcardname.to_show(opts[:fullname])
      
      new_args = @mode == :edit ? new_inclusion_card_args(opts) : {}
      tcard ||= Card.fetch_or_new(opts[:fullname], new_args)
  
      result = process_inclusion(tcard, opts)
      @char_count += (result ? result.length : 0)
      result
    rescue Card::PermissionDenied
      ''
    end
  
    def expand_main(opts)
      return wrap_main( @root.main_content ) if @root.main_content
      [:item, :view, :size].each do |key|
        if val=params[key] and !val.to_s.empty?
          opts[key] = val.to_sym
        end
      end
      opts[:tname] = @root.main_card.cardname
      opts[:view] ||= @main_view || :open
      opts[:fullname] = opts[:showname] = @root.main_card.name
      with_inclusion_mode(:main) do
        wrap_main process_inclusion(@root.main_card, opts)
      end
    end
  
    def wrap_main(content)
      content  #no wrapping in base renderer
    end
  
    def process_inclusion(tcard, options)
      sub = subrenderer( tcard, 
        :item_view =>options[:item], 
        :type      =>options[:type],
#        :size      =>options[:size],
        :showname  =>(options[:showname] || tcard.cardname)
      )
      oldrenderer, Renderer.current_slot = Renderer.current_slot, sub  #don't like depending on this global var switch
  
      new_card = tcard.new_card? && !tcard.virtual?
  
      requested_view = (options[:view] || :content).to_sym
      options[:home_view] = [:closed, :edit].member?(requested_view) ? :open : requested_view
      approved_view = case

        when (UNDENIABLE_VIEWS + [ :new, :closed_rule, :open_rule ]).member?(requested_view)  ; requested_view
        when @mode == :edit
         tcard.virtual? ? :edit_virtual : :edit_in_form
        when new_card
          case
          when requested_view == :raw ; :blank
          when @mode == :closed       ; :closed_missing
          else                        ; :missing
          end
        when @mode==:closed     ; :closed_content
        else                    ; requested_view
        end
      #warn "rendering #{approved_view} for #{card.name}"
      result = raw( sub.render(approved_view, options) )
      Renderer.current_slot = oldrenderer
      result
    rescue Exception=>e
      Rails.logger.info "inclusion-error #{e.message}"
      Rails.logger.debug "Trace:\n#{e.backtrace*"\n"}"
      %{<span class="inclusion-error">error rendering #{link_to_page((tcard ? tcard.name : 'unknown card'), nil, :title=>CGI.escapeHTML(e.message))}</span>}
    end
  
    def get_inclusion_content(cardname)
      #Rails.logger.debug "get_inclusion_content(#{cardname.inspect})"
      content = params[cardname.to_s.gsub(/\+/,'_')]
  
      # CLEANME This is a hack to get it so plus cards re-populate on failed signups
      if p = params['cards'] and card_params = p[cardname.pre_cgi]
        content = card_params['content']
      end
      content if content.present?  #not sure I get why this is necessary - efm
    end
  
    def new_inclusion_card_args(options)
      args = { :type =>options[:type] }
      args[:loaded_trunk]=card if options[:tname] =~ /^\+/
      if content=get_inclusion_content(options[:tname])
        args[:content]=content
      end
      args
    end
    
    def path(action, opts={})
      pcard = opts.delete(:card) || card
      base = "#{Wagn::Conf[:root_path]}/card/#{action}"
      if pcard && ![:new, :create, :create_or_update].member?( action )
        base += '/' + (opts[:id] ? "~#{opts.delete(:id)}" : card.cardname.to_url_key)
      end
      if attrib = opts.delete( :attrib )
        base += "/#{attrib}"
      end
      query =''
      if !opts.empty?
        query = '?' + (opts.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&') )
      end
      base + query
    end

    def search_params
      @search_params ||= begin
        p = self.respond_to?(:paging_params) ? paging_params : {}
        p[:vars] = {}
        if self == @root
          params.each do |key,val|
            case key.to_s
            when '_wql'      ;  p.merge! val
            when /^\_(\w+)$/ ;  p[:vars][$1.to_sym] = val
            end
          end
        end
        #if w = params[:wql] and explicit_vars = w[card.key]
        #  p.merge! explicit_vars
        #end
        p
      end
    end
      
    def build_link(href, text)
      #Rails.logger.info "build_link(#{href.inspect}, #{text.inspect})"
      klass = case href
        when /^https?:/; 'external-link'
        when /^mailto:/; 'email-link'
        when /^\//
          href = Wagn::Conf[:root_path] + full_uri(href.to_s)      
          'internal-link'
        else
          known_card = !!Card.fetch(href)
          text = text.to_cardname.to_show card.name
          href = href.to_cardname
          href = Wagn::Conf[:root_path] + '/' + (known_card ? href.to_url_key : CGI.escape(href.escape))
          #href+= "?type=#{type.to_url_key}" if type && card && card.new_card?  WANT THIS; NEED TEST
          href = full_uri(href.to_s)
          known_card ? 'known-card' : 'wanted-card'
      end
      #Rails.logger.info "build_link(#{href.inspect}, #{text.inspect}) #{klass}"
      %{<a class="#{klass}" href="#{href.to_s}">#{text.to_s}</a>}      
    end
    
    def unique_id() "#{card.key}-#{Time.now.to_i}-#{rand(3)}" end

    def full_uri(relative_uri)
      relative_uri
    end
  
  
  
  

     ### FIXME -- this should not be here!   probably in WikiReference model?
    def replace_references( old_name, new_name )
      #warn "replacing references...card name: #{card.name}, old name: #{old_name}, new_name: #{new_name}"
      wiki_content = WikiContent.new(card, card.content, self)
    
      wiki_content.find_chunks(Chunk::Link).each do |chunk|
        if chunk.cardname
          link_bound = chunk.cardname == chunk.link_text
          chunk.cardname = chunk.cardname.replace_part(old_name, new_name)
          chunk.link_text=chunk.cardname.to_s if link_bound
          #Rails.logger.info "repl ref: #{chunk.cardname.to_s}, #{link_bound}, #{chunk.link_text}"
        end
      end
    
      wiki_content.find_chunks(Chunk::Transclude).each do |chunk|
        chunk.cardname =
          chunk.cardname.replace_part(old_name, new_name) if chunk.cardname
      end
    
      String.new wiki_content.unrender!
    end

    #FIXME -- should not be here.
    def update_references(rendering_result=nil)
      return unless card
      WikiReference.delete_all ['card_id = ?', card.id]

      if card.id
        card.connection.execute("update cards set references_expired=NULL where id=#{card.id}")
        rendering_result ||= WikiContent.new(card, _render_refs, self)
        rendering_result.find_chunks(Chunk::Reference).each do |chunk|
          reference_type =
            case chunk
              when Chunk::Link;       chunk.refcard ? LINK : WANTED_LINK
              when Chunk::Transclude; chunk.refcard ? TRANSCLUSION : WANTED_TRANSCLUSION
              else raise "Unknown chunk reference class #{chunk.class}"
            end

         #ref_name=> (rc=chunk.refcardname()) && rc.to_key() || '',
          #raise "No name to ref? #{card.name}, #{chunk.inspect}" unless chunk.refcardname()
          WikiReference.create!( :card_id=>card.id,
            :referenced_name=> (rc=chunk.refcardname()) && rc.to_key() || '',
            :referenced_card_id=> chunk.refcard ? chunk.refcard.id : nil,
            :link_type=>reference_type
           )
        end
      end
    end
  end

  # I was getting a load error from a non-wagn file when this was in its own file (renderer/json.rb).
  class Renderer::Json < Renderer
    define_view(:name_complete) do |args|
      JSON( card.item_cards( :complete=>params['term'], :limit=>8, :sort=>'name', :return=>'name', :context=>'' ) )
    end
  end
  
  # automate
  Wagn::Renderer::EmailHtml
  Wagn::Renderer::Html
  Wagn::Renderer::Kml
  Wagn::Renderer::Rss
  Wagn::Renderer::Text
  
  Wagn::Conf[:pack_dirs].split(/,\s*/).each do |dir|
    Wagn::Pack.dir File.expand_path( "#{dir}/**/*_pack.rb",__FILE__)
  end
  Wagn::Pack.load_all
  
end
