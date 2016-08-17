class Card
  module Auth
    # singleton permission methods
    module Permissions
      RECAPTCHA_DEFAULTS = {
        recaptcha_public_key: "6LeoHfESAAAAAN1NdQeYHREq4jTSQhu1foEzv6KC",
        recaptcha_private_key: "6LeoHfESAAAAAHLZpn7ijrO4_KGLEr2nGL4qjjis"
      }.freeze

      # user has "root" permissions
      # @return [true/false]
      def always_ok?
        usr_id = as_id
        return false unless usr_id
        always_ok_usr_id? usr_id
      end

      # specified user has root permission
      # @param usr_id [Integer]
      # @return [true/false]
      def always_ok_usr_id? usr_id
        return true if usr_id == Card::WagnBotID # cannot disable

        always = Card.cache.read("ALWAYS") || {}
        if always[usr_id].nil?
          always = always.dup if always.frozen?
          always[usr_id] = admin? usr_id
          Card.cache.write "ALWAYS", always
        end
        always[usr_id]
      end

      # list of names of cardtype cards that current user has perms to create
      # @return [Array of strings]
      def createable_types
        type_names =
          Auth.as_bot do
            Card.search(
              { type: Card::CardtypeID, return: :name,
                not: { codename: ["in"] + Card.config.non_createable_types } },
              "find createable types"
            )
          end

        type_names.select do |name|
          Card.new(type: name).ok? :create
        end.sort
      end

      # test whether user is an administrator
      # @param user_id [Integer]
      # @return [true/false]
      def admin? user_id
        !Card[user_id].all_roles.find do |r|
          r == Card::AdministratorID
        end.nil?
      end
    end
  end
end
