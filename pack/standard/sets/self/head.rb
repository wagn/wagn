# -*- encoding : utf-8 -*-

format :html do

  view :raw do |args|
    %(
      <meta charset="UTF-8">  
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>    
      #{ head_title     }
      #{ head_buttons     }
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
    bits.join "\n      "
  end
  
  def head_stylesheets
    if params[:style]
      args = { :format=>:css }
      args[:item] = :import if params[:import_styles]
      @css_path = page_path params[:style], args
    elsif style_rule = card.rule_card(:style) and style_file = style_rule.fetch( :trait=>:file )
      @css_path = style_file.attach.url
    end 

    if @css_path
      %{<link href="#{@css_path}" media="all" rel="stylesheet" type="text/css" />}
    end
  end
  
  def head_javascript
    # tinyMCE doesn't load on non-root wagns w/o preinit line
    
    varvals = [
      'var wagn={}',
      "wagn.rootPath='#{Wagn::Conf[:root_path]}'",
      'window.wagn=wagn',
      "window.tinyMCEPreInit={base:\"#{wagn_path 'assets/tinymce'}\",query:'3.5.8',suffix:''}",
      "wagn.tinyMCEConfig={#{ Card.setting(:tiny_mce).to_s.gsub /\s+/, ' ' }}"      
    ]
    Wagn::Conf[:recaptcha_on]                        and varvals << "wagn.recaptchaKey='#{Wagn::Conf[:recaptcha_public_key]}'"
    c=Card[:double_click] and !Card.toggle c.content and varvals << 'wagn.noDoubleClick=true'
    @css_path                                        and varvals << "wagn.cssPath='#{@css_path}'"
    
    ga_key = Card.setting("*google analytics key")
    %(#{ javascript_tag do varvals * ';' end  }      
      #{ javascript_include_tag 'application' }
      <!--[if lt IE 9]>#{ javascript_include_tag 'html5shiv-printshiv' }<![endif]-->
      #{ javascript_tag do %{wagn.initGoogleAnalytics('#{ga_key}');} end })
  end
end


