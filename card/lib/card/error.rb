# -*- encoding : utf-8 -*-

class Card
  # exceptions and errors.
  # (arguably most of these should be Card::Exception)
  class Error < StandardError
    cattr_accessor :current

    class Oops < Error # wagneer problem (rename!)
    end

    class BadQuery < Error
    end

    class NotFound < StandardError
    end

    # permission errors
    class PermissionDenied < Error
      attr_reader :card

      def initialize card
        @card = card
        super build_message
      end

      def build_message
        if (msg = @card.errors[:permission_denied])
          "for card #{@card.name}: #{msg}"
        else
          super
        end
      end
    end

    # exception class for aborting card actions
    class Abort < StandardError
      attr_reader :status

      def initialize status, msg=""
        @status = status
        super msg
      end
    end

    class << self
      def exception_view card, exception
        Card::Error.current = exception

        case exception
        ## arguably the view and status should be defined in the error class;
        ## some are redundantly defined in view
        when Card::Error::Oops, Card::Error::BadQuery
          card.errors.add :exception, exception.message
          # these error messages are visible to end users and are generally not
          # treated as bugs.
          # Probably want to rename accordingly.
          :errors
        when Card::Error::PermissionDenied
          :denial
        when Card::Error::NotFound, ActiveRecord::RecordNotFound,
             ActionController::MissingFile
          :not_found
        when Wagn::BadAddress
          :bad_address
        else
          problematic_exception_view card, exception
        end
      end

      # indicates a code problem and therefore require full logging
      def problematic_exception_view card, exception
        card.notable_exception_raised

        if exception.is_a? ActiveRecord::RecordInvalid
          :errors
        # could also just check non-production mode...
        elsif Rails.logger.level.zero?
          raise exception
        else
          :server_error
        end
      end

      # card view and HTTP status code associate with errors on card
      # @todo  should prioritize certain error classes
      def view_and_status card
        card.errors.keys.each do |key|
          if (view_and_status = Card.error_codes[key])
            return view_and_status
          end
        end
        nil
      end
    end
  end
end
