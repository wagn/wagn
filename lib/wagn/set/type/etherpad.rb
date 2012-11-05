module Wagn
  module Set::Type::Etherpad
    include Sets

    format :html

    define_view :current do |args| _render_raw end
    define_view :current_naked do |args| _render_naked end

    define_view :current, :fallback=>:raw, :type=>'Etherpad' do |args|
      #warn "current_pad view #{card}, #{card.inspect}"
      card.include_set_modules
      card.get_pad_content
    end

    define_view :current_naked, :fallback=>:naked, :type=>'Etherpad' do |args|
      process_content _render_current
    end

    define_view :open_content, :type=>'Etherpad' do |args|
      card.post_render(_render_current_naked { yield })
    end

  # edit views
=begin not sure anymore why we want/need this
    define_view :edit, :type=>'Etherpad' do |args|
      @state=:edit
      wrap :edit, args do
        self._render_editor
      end
    end
=end

    define_view :editor, :type=>'Etherpad' do |args|
      pad_opts = card.pad_options
      uid = unique_id
      %{#{ form.text_area :content, :rows=>3, :id=>uid, :style=>'display:none',
                       :class=>'etherpad-textarea card-content'
        }<iframe id="epframe-#{uid}" width="100%" height="500" src="#{
        pad_opts[:url]}#{card.key
        }?showControls=#{pad_opts[:showControls]
        }&showChat=#{pad_opts[:showChat]
        }&showLineNumbers=#{pad_opts[:showLineNumbers]
        }&useMonospaceFont=#{pad_opts[:useMonospaceFont]
        }&userName=#{Session.user_card.name
        }&noColors=#{pad_opts[:noColors]}"></iframe>
      }
    end


    module Model
      def before_save
        # this seems like more that we need, maybe ?
        self.content = CGI::unescapeHTML( URI.unescape(content) )
      end

      # This needs to be part of configs
      PAD_DEFAULTS = {
        :url              => 'http://brain.private.com/epad/p/',
        :apiurl           => '/api/1/',
        :showControls     => true,
        :showChat         => false,
        :showLineNumbers  => true,
        :useMonospaceFont => false,
        :noColors         => false
      }

      def pad_options(params={})
        get_pad_options(params)
      end

      def get_pad_options(params={})
        pad_options = rule(:pad_options) || {}
        #warn "get_pad_options #{params.inspect}, #{pad_options}"
        pad_options = pad_options.blank? ? PAD_DEFAULTS :
             PAD_DEFAULTS.merge(JSON.parse(pad_options).symbolize_keys)
        pad_options.merge params.symbolize_keys
      end


      def get_pad_content
        pad_opts = pad_options
        resp = Net::HTTP.get_response(
          URI.parse( "#{pad_opts[:url]}#{key}/export/html") )
        # probably should do more with errors here
        Net::HTTPSuccess === resp ? resp.body : nil
      end
    end
  end
end
