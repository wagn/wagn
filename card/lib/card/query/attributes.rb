
class Card
  class Query
    module Attributes
      def found_by val
        found_by_cards(val).compact.each do |c|
          unless c && c.respond_to?(:wql_hash)
            raise Card::Error::BadQuery,
                              '"found_by" value must be valid Search, ' \
                              "but #{c.name} is a #{c.type_name}"
          end
          subquery c.wql_hash.merge(unjoined: true, context: c.name)
        end
      end

      def found_by_cards val
        if val.is_a? Hash
          Query.run val
        else
          Array.wrap(val).map do |v|
            Card.fetch v.to_name.to_absolute(context), new: {}
          end
        end
      end

      def match val
        cxn, val = match_prep val
        val.gsub!(/[^#{Card::Name::OK4KEY_RE}]+/, " ")
        return nil if val.strip.empty?

        val_list = val.split(/\s+/).map do |v|
          name_or_content = [
            "replace(#{table_alias}.name,'+',' ')",
            "#{table_alias}.db_content"
          ].map do |field|
            %(#{field} #{cxn.match quote("[[:<:]]#{v}[[:>:]]")})
          end
          or_join name_or_content
        end
        add_condition and_join(val_list)
      end

      def name_match val
        name_like "%#{val}%"
      end

      def complete val
        no_plus_card = (val =~ /\+/ ? "" : "and right_id is null")
        # FIXME: -- this should really be more nuanced --
        # it breaks down after one plus
        name_like "#{val}%",no_plus_card
      end

      def junction_complete val
        name_like ["#{val}%", "%+#{val}%"]
      end

      def extension_type _val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL"
        interpret right_plus: AccountID
      end

      private

      def name_like patterns, extra_cond=""
        likes = Array(patterns).map do |pat|
                  "lower(#{table_alias}.name) LIKE lower(#{quote pat})"
                end
        add_condition "#{or_join(likes)} #{extra_cond}"
      end

      def or_join conditions
        "(#{Array(conditions).join ' OR '})"
      end

      def and_join conditions
        "(#{Array(conditions).join ' AND '})"
      end
    end
  end
end
