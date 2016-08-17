class Card
  module Auth
    module Permissions

      # user has "root" permissions
      # @return [true/false]
      def always_ok?
        usr_id = as_id
        return false unless usr_id
        always_ok_usr_id? usr_id
      end

      # specified user has root permission
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

      def admin? user_id
        !Card[user_id].all_roles.find do |r|
          r == Card::AdministratorID
        end.nil?
      end
    end
  end
end
