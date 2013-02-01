
module Wagn
  class Renderer

    cattr_accessor :current_slot, :ajax_call, :perms, :denial_views, :subset_views, :error_codes, :view_tags, :renderer
    @@renderer = Renderer

    DEPRECATED_VIEWS = { :view=>:open, :card=>:open, :line=>:closed, :bare=>:core, :naked=>:core }
    INCLUSION_MODES  = { :main=>:main, :closed=>:closed, :closed_content=>:closed, :edit=>:edit,
      :layout=>:layout, :new=>:edit, :normal=>:normal, :template=>:template } #should be set in views
    DEFAULT_ITEM_VIEW = :link  # should be set in card?

    RENDERERS = { #should be defined in renderer
      :email => :EmailHtml,
      :css  => :Text,
      :txt  => :Text
    }

    @@max_char_count = 200 #should come from Wagn::Conf
    @@max_depth      = 10 # ditto
    @@perms          = {}
    @@denial_views   = {}
    @@subset_views   = {}
    @@error_codes    = {}
    @@view_tags      = {}

    def self.get_renderer format
      const_get( if RENDERERS.has_key? format
          RENDERERS[ format ]
        else
          format.to_s.camelize.to_sym
        end )
    end

    attr_reader :format, :card, :root, :parent
    attr_accessor :form, :main_content, :error_status

    Card::Reference
    Card
    include LocationHelper

  end

  class Renderer
    # these won't be here for long, but I moved them up in dealing with loading order issues relating so subclass renderers
    def replace_references old_name, new_name
      #Rails.logger.warn "replacing references...card name old name: #{old_name}, new_name: #{new_name} C> #{card.inspect}"
      #warn "replacing references...card name old name: #{old_name}, new_name: #{new_name} C> #{card.inspect}"
      wiki_content = WikiContent.new(card, card.content, self)

      wiki_content.find_chunks(Chunks::Reference).each do |chunk|
        
        if was_name = chunk.cardname and new_cardname = was_name.replace_part(old_name, new_name) and
             was_name != new_cardname
          Chunks::Link===chunk and link_bound = chunk.cardname == chunk.link_text
          chunk.cardname = new_cardname
          #Card::Reference.where(:referee_key => was_name.key).update_all( :referee_key => new_cardname.key )
          chunk.link_text=chunk.cardname.to_s if link_bound
        end
      end

      String.new wiki_content.unrender!
    end

    def update_references rendered_content = nil, refresh = false
      #Rails.logger.warn "update references...card:#{card.inspect}, rr: #{rendered_content}, refresh: #{refresh} where:#{caller[0..6]*', '}"
      #warn "update references...card: #{card.inspect}, rr: #{rendered_content}, refresh: #{refresh}, #{caller*"\n"}"
      if card
        Card::Reference.delete_all_from card
        # FIXME: why not like this: references_expired = nil # do we have to make sure this is saved?
        #Card.where( :id => referer_id ).update_all( :references_expired=>nil )
        card.connection.execute("update cards set references_expired=NULL where id=#{card.id}")
        card.expire if refresh
        
        rendered_content ||= WikiContent.new(card, card.raw_content, self).render! do |opts|
          expand_inclusion(opts) { yield }
        end

        rendered_content.find_chunks(Chunks::Reference).inject({}) do |hash, chunk|
          if referee_name = chunk.refcardname # name is referenced 
            referee_key = referee_name.key
            if !hash.has_key? referee_key     # not already tracked  !! FIXME: but what if it's a different ref_type?!
              referee_id  = chunk.refcard.send_if :id
              if card.id != referee_id        # not self reference
                hash[ referee_key ] = {
                    :referer_id  => card.id,
                    :referee_id  => referee_id,
                    :referee_key => referee_key,
                    :ref_type    => Chunks::Link===chunk ? 'L' : 'I',
                    :present     => chunk.refcard.nil?   ?  0  :  1  # more and more convince field should be boolean
                  }
              end
            end
          end
          hash
        end.each_value do |reference_hash|
          Card::Reference.create! reference_hash
        end
      end

    end

    class << self

      def new card, opts={}
        format = ( opts[:format].send_if :to_sym ) || :html
        renderer = if self!=Renderer or format.nil? or format == :base
              self
            else
              get_renderer format
            end

        opts[:format] = format
        new_renderer = renderer.allocate
        new_renderer.send :initialize, card, opts
        new_renderer
      end
      
      
      def tagged view, tag
        view && tag && @@view_tags[view.to_sym] && @@view_tags[view.to_sym][tag.to_sym]
      end
    end

    def initialize card, opts={}
      Renderer.current_slot ||= self unless(opts[:not_current])
      @card = card
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      @format ||= :html
      @char_count = @depth = 0
      @root = self

      @context_names ||= if context_name_list = params[:name_context]
        context_name_list.split(',').map &:to_name
      else [] end

      if card && card.collection? && params[:item] && !params[:item].blank?
        @item_view = params[:item]
      end
    end

    def params()       @params     ||= controller.params                          end
    def flash()        @flash      ||= controller.request ? controller.flash : {} end
    def controller()   @controller ||= StubCardController.new                     end
    def session()      CardController===controller ? controller.session : {}      end
    def ajax_call?()   @@ajax_call                                                end
      
    def showname
      @showname ||= card.cardname.to_show *@context_names
    end

    def main?
      if ajax_call?
        @depth == 0 && params[:is_main]
      else
        @depth == 1 && @mode == :main
      end
    end

    def focal? # meaning the current card is the requested card
      if ajax_call?
        @depth == 0
      else
        main?
      end
    end

    def template
      @template ||= begin
        c = controller
        t = ActionView::Base.new c.class.view_paths, {:_routes=>c._routes}, c
        t.extend c.class._helpers
        t
      end
    end

    def method_missing method_id, *args, &proc
      proc = proc {|*a| raw yield *a } if proc
      #warn "mmiss #{self.class}, #{card.name}, #{method_id}"
      response = template.send method_id, *args, &proc
      String===response ? template.raw( response ) : response
    end

    #
    # ---------- Rendering ------------
    #

    def render view = :view, args={}
      prefix = args.delete(:allowed) ? '_' : ''
      method = "#{prefix}render_#{canonicalize_view view}"
      if respond_to? method
        send method, args
      else
        unknown_view view
      end
    end

    def _render view, args={}
      args[:allowed] = true
      render view, args
    end

    def optional_render view, args, default_hidden=false
      test = default_hidden ? :show : :hide
      override = args[test] && args[test].member?(view.to_s)
      return nil if default_hidden ? !override : override
      render view, args
    end

    def _optional_render view, args, default_hidden=false
      args[:allowed] = true
      optional_render view, args, default_hidden
    end

    def rescue_view e, view
      controller.send :notify_airbrake, e if Airbrake.configuration.api_key
      Rails.logger.info "\nError rendering #{error_cardname} / #{view}: #{e.class} : #{e.message}"
      Rails.logger.debug "  #{e.backtrace*"\n  "}"
      rendering_error e, view
    end

    def error_cardname
      card && card.name.present? ? card.name : 'unknown card'
    end
    
    def unknown_view view
      "unknown view: #{view}"
    end

    def unsupported_view view
      "view (#{view}) not supported for #{error_cardname}"
    end

    def rendering_error exception, view
      "Error rendering: #{error_cardname} (#{view} view)"
    end

    #
    # ------------- Sub Renderer and Inclusion Processing ------------
    #

    def subrenderer subcard, opts={}
      subcard = Card.fetch( subcard, :new=>{} ) if String===subcard
      sub = self.clone
      sub.initialize_subrenderer subcard, self, opts
    end

    def initialize_subrenderer subcard, parent, opts
      @parent=parent
      @card = subcard
      @char_count = 0
      @depth += 1
      @item_view = @main_content = @showname = nil
      opts.each { |key, value| instance_variable_set "@#{key}", value }
      self
    end


    def process_content content=nil, opts={}
      return content unless card
      content = card.content if content.blank?

      wiki_content = WikiContent.new(card, content, self)

      update_references( wiki_content, true ) if card.references_expired

      wiki_content.render! do |opts|
        expand_inclusion(opts) { yield }
      end
    end

    def ok_view view, args={}
      original_view = view

      view = case
        when @depth >= @@max_depth   ; :too_deep
        # prevent recursion.  @depth tracks subrenderers (view within views)
        when @@perms[view] == :none  ; view
        # This may currently be overloaded.  always allowed = skip modes = never modified.  not sure that's right.
        when !card                   ; :no_card
        # This should disappear when we get rid of admin and account controllers and all renderers always have cards

        # HANDLE UNKNOWN CARDS ~~~~~~~~~~~~
        when !card.known? && !self.class.tagged( view, :unknown_ok )
          if focal?
            if @format==:html && card.ok?(:create) ;  :new
            else                                   ;  :not_found
            end
          else                                     ;  :missing
          end

        # CHECK PERMISSIONS  ~~~~~~~~~~~~~~~~
        else
          perms_required = @@perms[view] || :read
          if Proc === perms_required
            args[:denied_task] = !(perms_required.call self)
          else
            args[:denied_task] = [perms_required].flatten.find do |task|
              task = :create if task == :update && card.new_card?
              !card.ok? task
            end
          end
          args[:denied_task] ? (@@denial_views[view] || :denial) : view
        end


      if view != original_view
        args[:denied_view] = original_view

        if focal? && error_code = @@error_codes[view]
          root.error_status = error_code
        end
      end
      #warn "ok_view[#{original_view}] #{view}, #{args.inspect}, Cd:#{card.inspect}" #{caller[0..20]*"\n"}"
      view
    end

    def canonicalize_view view
      unless view.blank?
        DEPRECATED_VIEWS[view.to_sym] || view.to_sym
      end
    end

    def view_method view
      return "_final_#{view}" unless card && @@subset_views[view]
      card.method_keys.each do |method_key|
        meth = "_final_"+(method_key.blank? ? "#{view}" : "#{method_key}_#{view}")
        #warn "looking up #{method_key}, M:#{meth} for #{card.name}"
        return meth if respond_to?(meth.to_sym)
      end
      nil
    end

    def with_inclusion_mode mode
      if switch_mode = INCLUSION_MODES[ mode ]
        old_mode, @mode = @mode, switch_mode
      end
      result = yield
      @mode = old_mode if switch_mode
      result
    end

    def expand_inclusion opts
      #warn "ex inc #{card.inspect}, #{opts.inspect}"
      case
      when opts.has_key?( :comment )                            ; opts[:comment]     # as in commented code
      when @mode == :closed && @char_count > @@max_char_count   ; ''                 # already out of view
      when opts[:tname]=='_main' && !ajax_call? && @depth==0    ; expand_main opts
      else
        fullname = opts[:tname].to_name.to_absolute card.cardname, :params=>params
        included_card = Card.fetch fullname, :new=>( @mode==:edit ? new_inclusion_card_args(opts) : {} )

        result = process_inclusion included_card, opts
        @char_count += result.length if result
        result
      end
    end

    def expand_main opts
      return wrap_main( @main_content ) if @main_content
      [:item, :view, :size].each do |key|
        if val=params[key] and val.to_s.present?
          opts[key] = val.to_sym   #to sym??  why??
        end
      end
      opts[:view] = @main_view || opts[:view] || :open #FIXME configure elsewhere
      opts[:tname] = root.card.name
      with_inclusion_mode :main do
        wrap_main process_inclusion( root.card, opts )
      end
    end

    def wrap_main content
      content  #no wrapping in base renderer
    end

    def process_inclusion tcard, opts
      sub_opts = { :item_view =>opts[:item] }
      [ :type, :size ].each { |key| sub_opts[key] = opts[key] }
      sub = subrenderer tcard, sub_opts

      oldrenderer, Renderer.current_slot = Renderer.current_slot, sub
      # don't like depending on this global var switch
      # I think we can get rid of it as soon as we get rid of the remaining rails views?


      view = canonicalize_view opts.delete :view
      view ||= ( @mode == :layout ? :core : :content )  #set defaults elsewhere!!

      opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions
      
      view = case
      when @mode == :edit       ; @@perms[view]==:none || tcard.hard_template ? :blank : :edit_in_form
      when @@perms[view]==:none ; view
      when @mode == :closed     ; !tcard.known?  ? :closed_missing : :closed_content
      when @mode == :template   ; :template_rule
      else                      ; view
      end  

      result = raw sub.render( view, opts )
      Renderer.current_slot = oldrenderer
      result
    end

    def get_inclusion_content cardname
      content = params[cardname.to_s.gsub(/\+/,'_')]

      # CLEANME This is a hack to get it so plus cards re-populate on failed signups
      if p = params['cards'] and card_params = p[cardname.pre_cgi]
        content = card_params['content']
      end
      content if content.present?  # why is this necessary? - efm
    end

    def new_inclusion_card_args options
      args = { :type =>options[:type] }
      args[:loaded_left]=card if options[:tname] =~ /^\+/
      if content=get_inclusion_content(options[:tname])
        args[:content]=content
      end
      args
    end

    def path opts={}
      pcard = opts.delete(:card) || card
      base = opts[:action] ? "/card/#{ opts.delete :action }" : ''
      if pcard && !pcard.name.empty? && !opts.delete(:no_id) && ![:new, :create].member?(opts[:action]) #generalize. dislike hardcoding views/actions here
        base += '/' + ( opts[:id] ? "~#{ opts.delete :id }" : pcard.cardname.url_key )
      end
      if attrib = opts.delete( :attrib )
        base += "/#{attrib}"
      end
      query =''
      if !opts.empty?
        query = '?' + ( opts.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&') )
      end
      wagn_path( base + query )
    end

    def search_params
      @search_params ||= begin
        p = self.respond_to?(:paging_params) ? paging_params : { :default_limit=> 100 }
        p[:vars] = {}
        if self == @root
          params.each do |key,val|
            case key.to_s
            when '_wql'      ;  p.merge! val
            when /^\_(\w+)$/ ;  p[:vars][$1.to_sym] = val
            end
          end
        end
        p
      end
    end

    #
    # ------------ LINKS ---------------
    #

    def build_link href, text, known_card = nil
      # Rails.logger.info( "~~~~~~~~~~~~~~~ bl #{href.inspect}, #{text.inspect}, #{known_card.inspect}" )
      klass = case href.to_s
        when /^https?:/; 'external-link'
        when /^mailto:/; 'email-link'
        when /^\//
          href = full_uri href.to_s
          'internal-link'
        else
          known_card = !!Card.fetch(href, :skip_modules=>true) if known_card.nil?
          if card
            text = text.to_name.to_absolute_name(card.name).to_show *@context_names
          end

          #href+= "?type=#{type.url_key}" if type && card && card.new_card?  WANT THIS; NEED TEST
          cardname = href.to_name
          href = known_card ? cardname.url_key : ERB::Util.url_encode( cardname.to_s )
          #note - CGI.escape uses '+' to escape space.  that won't work for us.
          href = full_uri href.to_s
          known_card ? 'known-card' : 'wanted-card'

      end
      %{<a class="#{klass}" href="#{href}">#{text.to_s}</a>}
    end

    def unique_id() "#{card.key}-#{Time.now.to_i}-#{rand(3)}" end

    def full_uri relative_uri
      wagn_path relative_uri
    end

    def format_date date, include_time = true
      # Must use DateTime because Time doesn't support %e on at least some platforms
      if include_time
        DateTime.new(date.year, date.mon, date.day, date.hour, date.min, date.sec).strftime("%B %e, %Y %H:%M:%S")
      else
        DateTime.new(date.year, date.mon, date.day).strftime("%B %e, %Y")
      end
    end

    def add_name_context name=nil
      name ||= card.name
      @context_names += name.to_name.part_names
      @context_names.uniq!
    end

  end

  class Renderer::Json < Renderer
  end

  class Renderer::Text < Renderer
  end

  class Renderer::Html < Renderer
  end

  class Renderer::Csv < Renderer::Text
  end

end

