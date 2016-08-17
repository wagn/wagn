class Card
  module Auth
    # singleton methods for managing setup state
    module Setup
      @simulating_setup_need = nil
      SETUP_COMPLETED_KEY = "SETUP_COMPLETED".freeze

      # app is not totally set up yet
      # @return [true/false]
      def needs_setup?
        @simulating_setup_need || (
          !Card.cache.read(SETUP_COMPLETED_KEY) &&
          !Card.cache.write(SETUP_COMPLETED_KEY, account_count > 2)
        )
        # every deck starts with two accounts: WagnBot and Anonymous
      end

      # act as if site is not set up
      # @param mode [true/false] simulate setup need if true
      def simulate_setup_need! mode=true
        @simulating_setup_need = mode
      end

      # def instant_account_activation
      #   simulate_setup_need!
      #   yield
      # ensure
      #   simulate_setup_need! false
      # end

      private

      def account_count
        as_bot { Card.count_by_wql right: Card[:account].name }
      end
    end
  end
end
