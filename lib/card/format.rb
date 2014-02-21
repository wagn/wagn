# -*- encoding : utf-8 -*-

class Card
  class Format
    include Wagn::Location

    DEPRECATED_VIEWS = { :view=>:open, :card=>:open, :line=>:closed, :bare=>:core, :naked=>:core }
    INCLUSION_MODES  = { :closed=>:closed, :closed_content=>:closed, :edit=>:edit,
      :layout=>:layout, :new=>:edit, :normal=>:normal, :template=>:template } #should be set in views
    
    cattr_accessor :ajax_call, :perms, :denial_views, :subset_views, :error_codes, :view_tags, :aliases, :registered
    [ :perms, :denial_views, :subset_views, :error_codes, :view_tags, :aliases ].each { |acc| self.send "#{acc}=", {} }
    @@max_char_count = 200 #should come from Wagn.config
    @@max_depth      = 20 # ditto
    
    attr_reader :card, :root, :parent, :vars
    attr_accessor :form, :error_status, :inclusion_opts
  
    class << self
      @@registered = []

      def register format
        @@registered << format.to_s
      end

      def get_format format
        fkey = @@aliases[ format ] || format
        Card.const_get( "#{fkey.to_s.camelize}Format" )
      end

      def view view, *args, &final
        view = view.to_name.key.to_sym
        if block_given?
          define_view view, args[0], &final
        else
          opts = Hash===args[0] ? args.shift : nil
          alias_view view, opts, args.shift
        end
      end

      def define_view view, opts, &final
        opts ||= {}
        opts.merge! Card::Set.current[:opts]
        
        extract_class_vars view, opts
        view_key = get_set_key view, opts
        
        define_method "_final_#{view_key}", &final
        define_render_methods view
      end

      def alias_view alias_view, opts, referent_view=nil
        subset_views[alias_view] = true if opts && !opts.empty?

        referent_view ||= alias_view
        alias_opts = Card::Set.current[:opts]
        referent_view_key = get_set_key referent_view, (opts || alias_opts)
        alias_view_key    = get_set_key alias_view, alias_opts

        define_method "_final_#{alias_view_key}" do |*a|
          send "_final_#{referent_view_key}", *a
        end
        define_render_methods alias_view
      end

      def define_render_methods view
        # note: this could also be done with method_missing. is this any faster?
        if !method_defined? "render_#{view}"
          define_method "_render_#{view}" do |*a|
            send_final_render_method view, *a
          end

          define_method "render_#{view}" do |*a|
            send "_render_#{ ok_view view, *a }", *a
          end
        end
      end
      

      

      def new card, opts={}
        klass = self != Format ? self : get_format( (opts[:format] || :html).to_sym )
        new_format = klass.allocate
        new_format.send :initialize, card, opts
        new_format
      end
    
      def tagged view, tag
        view and tag and view_tags = @@view_tags[view.to_sym] and view_tags[tag.to_sym]
      end
        
      private
      
      def extract_class_vars view, opts
        perms[view]       = opts.delete(:perms)      if opts[:perms]
        error_codes[view] = opts.delete(:error_code) if opts[:error_code]
        denial_views[view]= opts.delete(:denial)     if opts[:denial]

        if tags = opts.delete(:tags)
          Array.wrap(tags).each do |tag|
            view_tags[view] ||= {}
            view_tags[view][tag] = true
          end
        end
        
        if !opts.empty?
          subset_views[view] = true
        end
      end
      
      def get_set_key selection_key, opts
        unless pkey = Card.method_key(opts)
          raise "bad method_key opts: #{pkey.inspect} #{opts.inspect}"
        end
        key = pkey.blank? ? selection_key : "#{pkey}_#{selection_key}"
        #warn "gvkey #{selection_key}, #{opts.inspect} R:#{key}"
        key.to_sym
      end
    end
    
    
    #~~~~~ INSTANCE METHODS

    def initialize card, opts={}
      @card = card
      opts.each do |key, value|
        instance_variable_set "@#{key}", value
      end

      @mode ||= :normal      
      @char_count = @depth = 0
      @root = self
      @vars = {}

      @context_names ||= if params[:slot] && context_name_list = params[:slot][:name_context]
        context_name_list.split(',').map &:to_name
      else [] end
    end
    

    
    def inclusion_defaults
      @inclusion_defaults ||= begin
        defaults = get_inclusion_defaults.clone
        defaults.merge! @inclusion_opts if @inclusion_opts
        defaults
      end
    end
    
    def get_inclusion_defaults
      { :view => :name }
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
    
    

    def render view, args={}
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

    def optional_render view, args, default=:show
      if show_view? view, args, default
        view = args["optional_#{ canonicalize_view view }_view".to_sym] || view
        render view, args
      end
    end

    def _optional_render view, args, default=:show
      args[:allowed] = true
      optional_render view, args, default
    end
    
    def show_view? view, args, default=:show
      view_key = canonicalize_view view
      api_option = args["optional_#{ view_key }".to_sym]
      case 
      # args remove option
      when api_option == :always                   ; true
      when api_option == :never                    ; false
      # wagneer's choice                           
      when show_views( args ).member?( view_key )  ; true
      when hide_views( args ).member?( view_key )  ; false
      # args override default                      
      when api_option == :show                     ; true
      when api_option == :hide                     ; false
      # default                                    
      else                                         ; default==:show
      end        
    end
    
    def show_views args
      parse_view_visibility args[:show]
    end
    
    def hide_views args
      parse_view_visibility args[:hide]
    end
    
    def parse_view_visibility val
      (val || '').split( /[\s\,]+/ ).map { |view| canonicalize_view view }
    end
    

    def send_final_render_method view, *a
      @current_view = view
      args = default_render_args view, *a
      if final_method = view_method(view)
        with_inclusion_mode view do
          send final_method, args
        end
      else
        unsupported_view view
      end
    rescue Exception=>e
      if Rails.env =~ /^cucumber|test$/
        raise e
      else
        rescue_view e, view
      end
    end

    def default_render_args view, a=nil
      args = case a
      when nil   ; {}
      when Hash  ; a.clone
      when Array ; a[0].merge a[1]
      else       ; raise Card::Error, "bad render args: #{a}"
      end
      
      view_key = canonicalize_view view
      default_method = "default_#{ view }_args"
      if respond_to? default_method
        send default_method, args
      end
      args
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

    def subformat subcard
      #should consider calling "child"
      subcard = Card.fetch( subcard, :new=>{} ) if String===subcard
      sub = self.clone
      sub.initialize_subformat subcard, self
    end

    def initialize_subformat subcard, parent
      @parent = parent
      @card = subcard
      @vars = {}
      @char_count = 0
      @depth += 1
      @inclusion_defaults = @inclusion_opts = @showname = @ok = nil
      self
    end

    def process_content content=nil, opts={}
      process_content_object(content, opts).to_s
    end

    def process_content_object content=nil, opts={}
      return content unless card
      content = card.content if content.blank?

      obj_content = Card::Content===content ? content : Card::Content.new( content, format=self )

      card.update_references( obj_content, true ) if card.references_expired  # I thik we need this genralized

      obj_content.process_content_object do |chunk_opts|
        expand_inclusion chunk_opts.merge(opts) { yield }
      end
    end

    def ok_view view, args={}
      approved_view = case
        when @depth >= @@max_depth      ; :too_deep                    # prevent recursion. @depth tracks subformats
        when @@perms[view] == :none     ; view                         # view requires no permissions
        when !card.known? &&
          !tagged( view, :unknown_ok )  ; view_for_unknown view, args  # handle unknown cards (where view not exempt)
        else                            ; permitted_view view, args    # run explicit permission checks
        end

      args[:denied_view] = view if approved_view != view
      if focal? && error_code = @@error_codes[ approved_view ]
        root.error_status = error_code
      end
      approved_view
    end
  
    def tagged view, tag
      self.class.tagged view, tag
    end
  
    def permitted_view view, args
      perms_required = @@perms[view] || :read
      args[:denied_task] =
        if Proc === perms_required
          :read if !(perms_required.call self)  # read isn't quite right
        else
          [perms_required].flatten.find { |task| !ok? task }
        end
      
      if args[:denied_task]
        @@denial_views[view] || :denial
      else
        view
      end
    end
  
    def ok? task
      task = :create if task == :update && card.new_card?
      @ok ||= {}
      @ok[task] = card.ok? task if @ok[task].nil?
      @ok[task]
    end
  
    def view_for_unknown view, args
      # note: overridden in HTML
      focal? ? :not_found : :missing
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
      if switch_mode = INCLUSION_MODES[ mode ] and @mode != switch_mode
        old_mode, @mode = @mode, switch_mode
        @inclusion_defaults = nil
      end
      result = yield
      if old_mode
        @inclusion_defaults = nil
        @mode = old_mode
      end
      result
    end

    def expand_inclusion opts
      case
      when opts.has_key?( :comment )                            ; opts[:comment]     # as in commented code
      when @mode == :closed && @char_count > @@max_char_count   ; ''                 # already out of view
      when opts[:inc_name]=='_main' && !ajax_call? && @depth==0    ; expand_main opts
      else
        included_card = Card.fetch opts[:inc_name], :new=>new_inclusion_card_args(opts)
        result = process_inclusion included_card, opts
        @char_count += result.length if @mode == :closed && result
        result
      end
    end

    def expand_main opts
      [:item, :view, :size].each do |key|
        if val=params[key] and val.to_s.present?
          opts[key] = val.to_sym   #to sym??  why??
        end
      end
      opts[:view] = @main_view || opts[:view] || :open
      with_inclusion_mode :normal do
        @mainline = true
        result = wrap_main process_inclusion( root.card, opts )
        @mainline = false
        result
      end
    end

    def wrap_main content
      content  #no wrapping in base format
    end

    def process_inclusion tcard, opts={}
      opts.delete_if { |k,v| v.nil? }
      opts.reverse_merge! inclusion_defaults
      
      sub = subformat tcard
      if opts[:item] #currently needed to handle web params
        opts[:items] = (opts[:items] || {}).reverse_merge :view=>opts[:item]
      end
      sub.inclusion_opts = opts[:items] 

      view = canonicalize_view opts.delete :view
      opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      view = case
      when @mode == :edit
        if @@perms[view]==:none || tcard.structure || tcard.key.blank? # eg {{_self|type}} on new cards
          :blank
        else
          :edit_in_form
        end
      when @mode == :template   ; :template_rule
      when @@perms[view]==:none ; view
      when @mode == :closed     ; !tcard.known?  ? :closed_missing : :closed_content
      else                      ; view
      end
      
      sub.render view, opts
    end

    def get_inclusion_content cardname
      content = params[cardname.to_s.gsub(/\+/,'_')]

      # CLEANME This is a hack to get it so plus cards re-populate on failed signups
      if p = params['cards'] and card_params = p[cardname.to_s]
        content = card_params['content']
      end
      content if content.present?  # why is this necessary? - efm  
                                   # probably for blanks?  -- older/wiser efm
    end

    def new_inclusion_card_args options
      args = { :name=>options[:inc_name], :type=>options[:type], :supercard=>card }
      args.delete(:supercard) if options[:inc_name].strip.blank? # special case.  gets absolutized incorrectly. fix in smartname?
      if options[:inc_name] =~ /^_main\+/
        # FIXME this is a rather hacky (and untested) way to get @superleft to work on new cards named _main+whatever
        args[:name] = args[:name].gsub /^_main\+/, '+'
        args[:supercard] = root.card
      end
      if content=get_inclusion_content(options[:inc_name])
        args[:content]=content
      end
      args
    end
    
    def default_item_view
      :name
    end

    def path opts={}
      pcard = opts.delete(:card) || card
      base = opts[:action] ? "card/#{ opts.delete :action }/" : ''
      if pcard && !pcard.name.empty? && !opts.delete(:no_id) && ![:new, :create].member?(opts[:action]) #generalize. dislike hardcoding views/actions here
        base += ( opts[:id] ? "~#{ opts.delete :id }" : pcard.cardname.url_key )
      end
      query = opts.empty? ? '' : "?#{opts.to_param}"
      wagn_path( base + query )
    end
    #
    # ------------ LINKS ---------------
    #

    def final_link href, opts
      if text = opts[:text]
        "#{text}[#{href}]"
      else
        href
      end
    end

    def build_link href, text=nil
      opts = {:text => text }

      opts[:class] = case href.to_s
        when /^https?:/                      ; 'external-link'
        when /^mailto:/                      ; 'email-link'
        when /^([a-zA-Z][\-+.a-zA-Z\d]*):/   ; $1 + '-link'
        when /^\//
          href = internal_url href[1..-1]    ; 'internal-link'
        else
          return href
          Rails.logger.debug "build_link mistakenly(?) called on #{href}, #{text}"
        end
        
      final_link href, opts
    end

    def card_link name, text, known, type=nil
      text ||= name
      linkname = name.to_name.url_key
      opts = {
        :class => ( known ? 'known-card' : 'wanted-card' ),
        :text  => ( text.to_name.to_show @context_names  )
      }
      if !known
        link_params = {}
        link_params['name'] = name.to_s if name.to_s != linkname
        link_params['type'] = type      if type
        linkname += "?#{ { :card => link_params }.to_param }" if !link_params.empty?
      end
      final_link internal_url( linkname ), opts
    end
  
    def unique_id
      "#{card.key}-#{Time.now.to_i}-#{rand(3)}" 
    end

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
end

