class Card
  class Cache
    # pre-populate cache for testing purposes
    module Prepopulate
      def restore
        reset_soft
        prepopulate
      end

      private

      def prepopulate
        return unless @prepopulating
        soft = Card.cache.soft
        @rule_cache ||= Card.rule_cache
        @user_ids_cache ||= Card.user_ids_cache
        @read_rule_cache ||= Card.read_rule_cache
        @rule_keys_cache ||= Card.rule_keys_cache
        soft.write "RULES", @rule_cache
        soft.write "READRULES", @read_rule_cache
        soft.write "USER_IDS", @user_ids_cache
        soft.write "RULE_KEYS", @rule_keys_cache
      end
    end
  end
end
