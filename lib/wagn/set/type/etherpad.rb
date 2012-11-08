module Wagn::Set::Type::Etherpad
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
    warn(Rails.logger.debug "get_pad_options #{params.inspect}, #{pad_options}")
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
