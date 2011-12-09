module Wagn::Set::Type::Etherpad
  def before_save
    escape_content
  end

  PAD_DEFAULTS = {
    :url              => 'http://brain/epad/p/',
    :apiurl           => '/api/1/',
    :showControls     => true,
    :showChat         => false,
    :showLineNumbers  => true,
    :useMonospaceFont => false,
    :noColors         => false
  }

  def pad_options(params={})
    #@pad_options ||= {}
    #@pad_options[params.to_s] ||=
      get_pad_options(params)
  end

  def get_pad_options(params={})
    pad_options = setting('*epad') || {}
    Rails.logger.debug "get_pad_options #{params.inspect}, #{pad_options}"
    pad_options = PAD_DEFAULTS.merge JSON.parse(pad_options).symbolize_keys
    pad_options.merge params.symbolize_keys
  end
  
  def escape_content
    self.content = CGI::unescapeHTML( URI.unescape(content) )
  end

  def get_pad_content
    epad_opts = pad_options
    resp = Net::HTTP.get_response(
      URI.parse( "#{epad_opts[:url]}#{key}/export/html") )
    Net::HTTPSuccess === resp ? resp.body : nil
  end
end
