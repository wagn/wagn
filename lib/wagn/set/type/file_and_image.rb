# -*- encoding : utf-8 -*-


class Wagn::Renderer
  def handle_source args
    source = _render_source args
    source ? yield( source ) : ''
  rescue
    'File Error'
  end
end


