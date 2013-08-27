# -*- encoding : utf-8 -*-

format :html do

  view :raw do |args|
    %(
      #{ head_title     }
      #{ head_buttons     }
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      #{ head_stylesheets }
      #{ head_javascript  }      
    )
  end

  view :core, :raw
  
  def head_title
    title = root.card && root.card.name
    title = nil if title.blank?
    title = params[:action] if title=='*placeholder'
    %(<title>#{title ? "#{title} - " : ''}#{ Card.setting :title }</title>) 
  end
  
  def head_buttons
    bits = []
    [:favicon, :logo].each do |name|
      if c = Card[name] and c.type_id == Card::ImageID and !c.content.blank?
        bits << %{<link rel="shortcut icon" href="#{ subformat(c)._render_source :size=>:icon }" />}
        break
      end
    end

    #Universal Edit Button
    if root.card
      if !root.card.new_record? && root.card.ok?(:update)
        bits << %{<link rel="alternate" type="application/x-wiki" title="Edit this page!" href="#{ root.path :view=>:edit }"/>}
      end

      # RSS # move to packs!
      if root.card.type_id == Card::SearchTypeID
        opts = { :format => :rss }
        root.search_params[:vars].each { |key, val| opts["_#{key}"] = val }
        rss_href = page_path root.card.name, opts
        bits << %{<link rel="alternate" type="application/rss+xml" title="RSS" href=#{wagn_path rss_href} />}
      end
    end
    bits.join "\n"
  end
  
  def head_stylesheets
    if params[:style]
      @css_path = wagn_path params[:style].to_name.url_key
    elsif style_rule = card.rule_card(:style) and style_file = style_rule.fetch( :trait=>:file )
      @css_path = style_file.attach.url
    end 

    if @css_path
      stylesheet_link_tag @css_path
    end
  end
  
  def head_javascript
    # tinyMCE doesn't load on non-root wagns w/o preinit line
    
    %(
      <script>
        var wagn = {};
        window.wagn = wagn;
        wagn.rootPath = '#{Wagn::Conf[:root_path]}';
        #{ Wagn::Conf[:recaptcha_on] ? %{wagn.recaptchaKey = "#{Wagn::Conf[:recaptcha_public_key]}";} : '' }
        #{ (c=Card[:double_click] and !Card.toggle(c.content)) ? 'wagn.noDoubleClick = true' : '' }
        #{ #@local_css_path ? %{ wagn.local_css_path = '#{@local_css_path}'; } : '' 
        }
        window.tinyMCEPreInit = {base:"#{wagn_path 'assets/tinymce'}",query:"3.5.8",suffix:""};
        wagn.tinyMCEConfig = { #{ Card.setting :tiny_mce } };
      </script>
      
      #{ javascript_include_tag 'application' }
      <!--[if lt IE 9]>
        #{ javascript_include_tag 'html5shiv-printshiv' }
      <![endif]-->

      #{
        if ga_key=Card.setting("*google analytics key")
          %(

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
      }
    )
  end
end


