module Wagn
  module Set::Self::HeadAndFoot
    include Sets

    format :base

    define_view :raw, :name=>'head' do |args|
      #rcard = card  # should probably be more explicit that this is really the *main* card.

      title = root.card && root.card.name
      title = nil if title.blank?
      title = params[:action] if title=='*placeholder'
      bits = ["<title>#{title ? "#{title} - " : ''}#{ Card.setting :title }</title>"]

      if favicon_card = Card[:favicon] and favicon_card.type_id == Card::ImageID
        bits << %{<link rel="shortcut icon" href="#{ subrenderer(favicon_card)._render_source :size=>:icon }" />}
      end

      #Universal Edit Button
      if root.card
        if !root.card.new_record? && root.card.ok?(:update)
          bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ root.path :edit }"/>}
        end

        # RSS # move to packs!
        if root.card.type_id == Card::SearchTypeID
          opts = { :format => :rss }
          root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
          rss_href = url_for_page root.card.name, opts
          bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{rss_href} />}
       end
      end

      # CSS

      bits << stylesheet_link_tag('application-all')
      bits << stylesheet_link_tag('application-print', :media=>'print')
      if css_card = Card[:css]
        local_css_path = wagn_path "*css.css?#{ css_card.current_revision_id }"
        bits << stylesheet_link_tag(local_css_path)
      end

      #Javscript
      bits << %(
      <script>
        var wagn = {}; window.wagn = wagn;
        wagn.rootPath = '#{Wagn::Conf[:root_path]}';
        window.tinyMCEPreInit = {base:"#{wagn_path 'assets/tinymce'}",query:"3.4.7",suffix:""};
        #{ Wagn::Conf[:recaptcha_on] ? %{wagn.recaptchaKey = "#{Wagn::Conf[:recaptcha_public_key]}";} : '' }
        #{ (c=Card[:double_click] and !Card.toggle(c.content)) ? 'wagn.noDoubleClick = true' : '' }
        #{ local_css_path ? %{ wagn.local_css_path = '#{local_css_path}'; } : '' }
        ) +
        #  TEMPORARY we probably want this back once we have fingerprinting on this file - EFM
        %( wagn.tinyMCEConfig = { #{ Card.setting :tiny_mce } };
      </script>
            )
      bits << javascript_include_tag('application')

      if ga_key=Card.setting("*google analytics key")
        bits << %(

        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{ga_key}']);
          _gaq.push(['_trackPageview']);

          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
        )
      end

      bits.join("\n")
    end
    alias_view(:raw, {:name=>'head'}, :core)




    define_view :raw, :name=>'foot' do |args|
      '<!-- *foot is deprecated. please remove from layout -->'
    end
    alias_view(:raw, {:name=>'foot'}, :core)
  end
end
