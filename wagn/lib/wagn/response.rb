module Wagn
  # methods for managing wagn responses
  module Response
    private

    def card_redirect url
      url = card_url url # make sure we have absolute url
      if Card::Env.ajax?
        # lets client reset window location
        # (not just receive redirected response)
        # formerly used 303 response, but that gave IE the fits
        render json: { redirect: url }
      else
        redirect_to url
      end
    end

    def reset_card new_card
      @card = new_card
      update_params_for_success
      @card.select_action_by_params params
    end

    def update_params_for_success
      success = Card::Env.success
      if success.soft_redirect?
        self.params = success.params
      else
        # need tests. insure we get slot, main...
        params.merge! success.params
      end
    end

    def send_deprecated_asset
      filename = [params[:filename], params[:format]].join(".")
      # for security, block relative paths
      raise Wagn::BadAddress if filename.include? "../"
      path = Decko::Engine.paths["gem-assets"].existent.first
      send_file File.join(path, filename), x_sendfile: true
    end
  end
end
