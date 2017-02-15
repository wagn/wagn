class Card
  class Query
    module Interpretation
      # normalize and extract meaning from a clause
      # @param clause [Hash, String, Integer] statement or chunk thereof
      def interpret clause
        interpret_by_key normalize_clause(clause)
      end

      def interpret_by_key clause
        clause.each do |key, val|
          case
          when OPERATORS.key?(key.to_s) && !ATTRIBUTES[key]
            # eg "match" is both operator and attribute;
            # interpret as attribute when "match" is key
            interpret content: [key, val]
          when MODIFIERS.key?(key) && !clause[key].is_a?(Hash)
            # eg when "sort" is hash, it can have subqueries
            # and must be interpreted like an attribute
            @mods[key] = val.is_a?(Array) ? val : val.to_s
          else
            interpret_attributes key, val
          end
        end
      end

      def interpret_attributes key, val
        case ATTRIBUTES[key]
        when :basic            then add_condition key, val
        when :conjunction      then send key, val
        when :relational       then relate key, val
        when :special          then relate key, val
        when :ref_relational   then relate key, val, method: :join_references
        when :plus_relational  then relate_compound key, val
        when :ignore           then # noop
        else
          raise Card::Error::BadQuery, "Invalid attribute #{key}"
        end
      end

      def normalize_clause clause
        clause = clause_to_hash clause
        clause.symbolize_keys!
        clause.each do |key, val|
          next if key.to_sym == :return
          clause[key] = normalize_value val
        end
        clause
      end

      def clause_to_hash clause
        case clause
        when Hash              then clause
        when String, SmartName then { key: clause.to_name.key }
        when Integer           then { id: clause }
        else raise Card::Error::BadQuery, "Invalid query args #{clause.inspect}"
        end
      end

      def normalize_value val
        case val
        when Integer, Float, Symbol, Hash then val
        when String, SmartName            then normalize_string_value val
        when Array                        then val.map { |v| normalize_value v }
        else raise Card::Error::BadQuery, "unknown WQL value type: #{val.class}"
        end
      end

      def normalize_string_value val
        case val.to_s
        when /^\$(\w+)$/                       # replace from @vars
          @vars[Regexp.last_match[1].to_sym].to_s.strip
        when /\b_/                             # absolutize based on @context
          val.to_name.to_absolute(context)
        else
          val
        end
      end

      def add_condition *args
        @conditions <<
          if args.size > 1
            [args.shift, Value.new(args.shift, self)]
          else
            args[0]
          end
      end

      def relate_compound key, val
        has_multiple_values =
          val.is_a?(Array) &&
          (val.first.is_a?(Array) || conjunction(val.first).present?)
        relate key, val, multiple: has_multiple_values
      end

      def relate key, val, opts={}
        multiple = opts[:multiple].nil? ? val.is_a?(Array) : opts[:multiple]
        method = opts[:method] || :send
        if multiple
          relate_multi_value method, key, val
        else
          send method, key, val
        end
      end

      def relate_multi_value method, key, val
        conj = conjunction(val.first) ? conjunction(val.shift) : :and
        if conj == current_conjunction
          # same conjunction as container, no need for subcondition
          val.each { |v| send method, key, v }
        else
          send conj, val.map { |v| { key => v } }
        end
      end

      def current_conjunction
        @mods[:conj].blank? ? :and : @mods[:conj]
      end

      def all_joins
        @all_joins ||=
          (joins + subqueries.select(&:unjoined).map(&:all_joins)).flatten
      end
    end
  end
end
