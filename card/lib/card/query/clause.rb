
module Card::Query::Clause
  #    attr_accessor :clause

  def safe_sql txt
    txt = txt.to_s
    txt =~ /[^\w\*\(\)\s\.\,]/ ? raise("WQL contains disallowed characters: #{txt}") : txt
  end

    def quote v
      ActiveRecord::Base.connection.quote(v)
    end

    def match_prep v
      cxn ||= ActiveRecord::Base.connection
      [cxn, v]
    end
end
