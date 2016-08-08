
class Card
  class Query
    module Attributes
      def found_by val
        found_by_cards(val).compact.each do |c|
          if c && [SearchTypeID, SetID].include?(c.type_id)
            # FIXME: - move this check to set mods!

            subquery(
              c.get_query.merge(unjoined: true, context: c.name)
            )
          else
            raise BadQuery,
                  '"found_by" value must be valid Search, ' \
                  "but #{c.name} is a #{c.type_name}"
          end
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
          "(#{name_or_content.join ' OR '})"
        end
        add_condition "(#{val_list.join ' AND '})"
      end

      def complete val
        no_plus_card = (val =~ /\+/ ? "" : "and right_id is null")
        # FIXME: -- this should really be more nuanced --
        # it breaks down after one plus

        add_condition(
          " lower(#{table_alias}.name) LIKE" \
          " lower(#{quote(val.to_s + '%')}) #{no_plus_card}"
        )
      end

      def extension_type _val
        # DEPRECATED LONG AGO!!!
        Rails.logger.info "using DEPRECATED extension_type in WQL"
        interpret right_plus: AccountID
      end
    end
  end
end
