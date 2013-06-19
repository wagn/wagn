# -*- encoding : utf-8 -*-

class Card
  class Format

    include LocationHelper
    
    cattr_accessor :current_slot, :ajax_call, :perms, :denial_views, :subset_views, :error_codes, :view_tags

    attr_reader :format, :card, :root, :parent
    attr_accessor :form, :main_content, :error_status


    DEPRECATED_VIEWS = { :view=>:open, :card=>:open, :line=>:closed, :bare=>:core, :naked=>:core }
    INCLUSION_MODES  = { :main=>:main, :closed=>:closed, :closed_content=>:closed, :edit=>:edit,
      :layout=>:layout, :new=>:edit, :normal=>:normal, :template=>:template } #should be set in views
    #DEFAULT_ITEM_VIEW = :link  # should be set in card?

    RENDERERS = { #should be defined in renderer
      :email => :EmailHtml,
      :txt  => :Text
    }

    @@max_char_count = 200 #should come from Wagn::Conf
    @@max_depth      = 10 # ditto
    @@perms          = {}
    @@denial_views   = {}
    @@subset_views   = {}
    @@error_codes    = {}
    @@view_tags      = {}

    class << self

      def get_renderer format
        const_get( RENDERERS[ format ] || format.to_s.camelize.to_sym )
      end

      def view view, *args, &final
        view = view.to_name.key.to_sym
        if block_given?
          define_view view, (args[0] || {}), &final
        else
          opts = Hash===args[0] ? args.shift : nil
          alias_view view, opts, args.shift
        end
      end

      def define_view view, opts, &final
        perms[view]       = opts.delete(:perms)      if opts[:perms]
        error_codes[view] = opts.delete(:error_code) if opts[:error_code]
        denial_views[view]= opts.delete(:denial)     if opts[:denial]

        if tags = opts.delete(:tags)
          Array.wrap(tags).each do |tag|
            view_tags[view] ||= {}
            view_tags[view][tag] = true
          end
        end

        if set_opts = Card::Set.current_set_opts
          opts.merge! set_opts
        end

        view_key = get_set_key view, opts
        #warn "defining view method[#{Card::Format.current_class}] _final_#{view_key}" if view_key =~ /stat/
        class_eval { define_method "_final_#{view_key}", &final }
        subset_views[view] = true if !opts.empty?

        if !method_defined? "render_#{view}"
          #warn "defining view method[#{Card::Format.renderer}] _render_#{view}"
          class_eval do
            define_method "_render_#{view}" do |*a|
              begin
                a = [{}] if a.empty?
                if final_method = view_method(view)
                  with_inclusion_mode view do
                    #Rails.logger.info( warn "rendering final method: #{final_method}" )
                    send final_method, *a
                  end
                else
                  unsupported_view view
                end
              rescue Exception=>e
                rescue_view e, view
              end
            end
          end

          #Rails.logger.warn "define_method render_#{view}"
          class_eval do
            define_method "render_#{view}" do |*a|
              send "_render_#{ ok_view view, *a }", *a
            end
          end
        end

      end

      def alias_view alias_view, opts, referent_view=nil

        subset_views[alias_view] = true if opts && !opts.empty?

        referent_view ||= alias_view
        alias_opts = Card::Set.current_set_opts || {}
        referent_view_key = get_set_key referent_view, (opts || alias_opts)
        alias_view_key = get_set_key alias_view, alias_opts

        #warn "alias = #{alias_view_key}, referent = #{referent_view_key}"

        #Rails.logger.info( warn "def view final_alias #{alias_view_key}, #{view_key}" )
        class_eval do
          define_method "_final_#{alias_view_key}".to_sym do |*a|
            send "_final_#{referent_view_key}", *a
          end
        end
      end




      def new card, opts={}
        format = ( opts[:format].send_if :to_sym ) || :html
        renderer = if self!=Format or format.nil? or format == :base
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
      
      
      private

      # the following is poorly named; the "selection_key" (really means view_key, no?) has nothing to do with the set
      def get_set_key selection_key, opts
        unless pkey = Card.method_key(opts)
          raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
        end
        key = pkey.blank? ? selection_key : "#{pkey}_#{selection_key}"
        #warn "gvkey #{selection_key}, #{opts.inspect} R:#{key}"
        key.to_sym
      end
    end

    def initialize card, opts={}
      Format.current_slot ||= self unless opts[:not_current]
      @card = card
      opts.each do |key, value|
        instance_variable_set "@#{key}", value
      end

      @format ||= :html
      @char_count = @depth = 0
      @root = self

      @context_names ||= if params[:slot] && context_name_list = params[:slot][:name_context]
        context_name_list.split(',').map &:to_name
      else [] end
    end

    def params()       @params     ||= controller.params                          end
    def flash()        @flash      ||= controller.request ? controller.flash : {} end
    def controller()   @controller ||= StubCardController.new                     end
    def session()      CardController===controller ? controller.session : {}      end
    def ajax_call?()   @@ajax_call                                                end

    def showname title=nil
      if title
        title.to_name.to_absolute_name(card.cardname).to_show *@context_names
      else
        @showname ||= card.cardname.to_show *@context_names
      end
    end
    
    def main?
      @depth == 0
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
      #Rails.logger.warn "mmiss #{self.class}, #{@card.inspect}, #{caller[0]}, #{method_id}"
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
      override = args[test] && args[test].split(/[\s\,]+/).member?( view.to_s )
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
      Rails.logger.debug "BT:  #{e.backtrace*"\n  "}"
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
    # ------------- Sub Format and Inclusion Processing ------------
    #

    def subrenderer subcard, mainline=false
      #should consider calling "child"
      subcard = Card.fetch( subcard, :new=>{} ) if String===subcard
      sub = self.clone
      sub.initialize_subrenderer subcard, self, mainline
    end

    def initialize_subrenderer subcard, parent, mainline=false
      @mainline ||= mainline
      @parent = parent
      @card = subcard
      @char_count = 0
      @depth += 1
      @main_content = @showname = @search = @ok = nil
      self
    end

    def process_content content=nil, opts={}
      process_content_object(content, opts).to_s
    end

    def process_content_object content=nil, opts={}
      return content unless card
      content = card.content if content.blank?

      obj_content = Card::Content===content ? content : Card::Content.new(content, {:card=>card, :renderer=>self})

      card.update_references( obj_content, true ) if card.references_expired  # I thik we need this genralized

      obj_content.process_content_object do |opts|
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
    
          case
          when @format==:html && focal? && ok?( :create )
            :new
          when @format==:html && comment_box?( view, args ) && ok?( :comment )
            view
          when focal?
            :not_found
          else
            :missing
          end

        # CHECK PERMISSIONS  ~~~~~~~~~~~~~~~~
        else
          perms_required = @@perms[view] || :read
          args[:denied_task] =
            if Proc === perms_required
              :read if !(perms_required.call self)  # read isn't quite right
            else
              [perms_required].flatten.find { |task| !ok? task }
            end
          args[:denied_task] ? (@@denial_views[view] || :denial) : view
        end

      if view != original_view
        args[:denied_view] = original_view
      end
      if focal? && error_code = @@error_codes[view]
        root.error_status = error_code
      end
      #warn "ok_view[#{original_view}] #{view}, #{args.inspect}, Cd:#{card.inspect}" #{caller[0..20]*"\n"}"
      view
    end
    
    def ok? task
      task = :create if task == :update && card.new_card?
      @ok ||= {}
      @ok[task] = card.ok? task if @ok[task].nil?
      @ok[task]
    end
    
    def comment_box? view, args
      self.class.tagged view, :comment and args[:show] =~ /comment_box/
    end

    def canonicalize_view view
      unless view.blank?
        view_key = view.to_name.key.to_sym
        DEPRECATED_VIEWS[view_key] || view_key
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
      case
      when opts.has_key?( :comment )                            ; opts[:comment]     # as in commented code
      when @mode == :closed && @char_count > @@max_char_count   ; ''                 # already out of view
      when opts[:include_name]=='_main' && !ajax_call? && @depth==0    ; expand_main opts
      else
        fullname = opts[:include_name].to_name.to_absolute card.cardname, :params=>params
        #warn "ex inc full[#{opts[:include_name]}]#{fullname}, #{params.inspect}"
        included_card = Card.fetch fullname, :new=>( @mode==:edit ? new_inclusion_card_args(opts) : {} )

        result = process_inclusion included_card, opts
        @char_count += result.length if @mode == :closed && result
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
      opts[:mainline] = true
      with_inclusion_mode :main do
        wrap_main process_inclusion( root.card, opts )
      end
    end

    def wrap_main content
      content  #no wrapping in base renderer
    end

    def process_inclusion tcard, opts
      sub = subrenderer tcard, opts[:mainline]
      oldrenderer, Format.current_slot = Format.current_slot, sub
      # don't like depending on this global var switch
      # I think we can get rid of it as soon as we get rid of the remaining rails views?


      view = canonicalize_view opts.delete :view
      view ||= ( @mode == :layout ? :core : :content )  #set defaults elsewhere!!

      opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      view = case
      when @mode == :edit
        if @@perms[view]==:none || tcard.hard_template || tcard.key.blank? # eg {{_self|type}} on new cards
          :blank
        else
          :edit_in_form
        end
      when @mode == :template   ; :template_rule
      when @@perms[view]==:none ; view
      when @mode == :closed     ; !tcard.known?  ? :closed_missing : :closed_content
      else                      ; view
      end

      result = sub.render(view, opts)
      Format.current_slot = oldrenderer
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
      args[:loaded_left]=card if options[:include_name] =~ /^\+/
      if content=get_inclusion_content(options[:include_name])
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
      query = opts.empty? ? '' : "?#{opts.to_param}"
      wagn_path( base + query )
    end
    #
    # ------------ LINKS ---------------
    #

    # FIXME: shouldn't this be in the html version of this?  this should give plain-text links.
    # Maybe like this:
    #def final_link klass, href, text=nil
    #  text = href if text.nil?
    #  %{[#{klass}]#{href}"#{text && "(#{text.to_s}_"})}
    #  # or
    #  %{[#{klass =~ /wanted/ && '[missing]'}#{href}"#{text && "(#{text.to_s}_"})}
    #end

    # and move this to the html renderer
    def final_link href, opts={}
      text = opts[:text] || href
      %{<a class="#{opts[:class]}" href="#{href}">#{text}</a>}
    end

    def build_link href, text=nil
      opts = {:text => text }

      opts[:class] = case href.to_s
        when /^https?:/                      ; 'external-link'
        when /^mailto:/                      ; 'email-link'
        when /^([a-zA-Z][\-+.a-zA-Z\d]*):/   ; $1 + '-link'
        when /^\//
          href = internal_url href           ; 'internal-link'
        else
          return href
          Rails.logger.debug "build_link mistakenly(?) called on #{href}, #{text}"
        end
          
      final_link href, opts
    end
 
    def card_link name, text, known
      text ||= name
      opts = {
        :class => ( known ? 'known-card' : 'wanted-card' ),
        :text  => ( text.to_name.to_show @context_names  )
      }
      relative_path = known ? name.to_name.url_key : encode_path(name)
      final_link internal_url( relative_path ), opts
    end
    
    def encode_path path
      ERB::Util.url_encode( path.to_s ).gsub('.', '%2E')
    end

    def unique_id() "#{card.key}-#{Time.now.to_i}-#{rand(3)}" end

    def internal_url relative_path
      wagn_path relative_path
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

  class Format::Html < Format                ; end
  
  class Format::File < Format                ; end

  class Format::Text < Format                ; end
  class Format::Csv < Format::Text           ; end
  class Format::Css < Format::Text           ; end
  
  class Format::Data < Format                ; end
  class Format::Json < Format::Data          ; end
  class Format::Xml < Format::Data           ; end

end

