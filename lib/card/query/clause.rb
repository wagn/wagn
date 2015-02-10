
class Card::Query::Clause
  attr_accessor :clause

  def safe_sql(txt)
    txt = txt.to_s
    txt.match( /[^\w\*\(\)\s\.\,]/ ) ? raise( "WQL contains disallowed characters: #{txt}" ) : txt
  end

  def quote(v)  ActiveRecord::Base.connection.quote(v)  end

  def match_prep(v)
    cxn ||= ActiveRecord::Base.connection
    [cxn, v]
  end

  def cast_type(type)
    cxn ||= ActiveRecord::Base.connection
    (val = cxn.cast_types[type.to_sym]) ? val[:name] : safe_sql(type)
  end
end