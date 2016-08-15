# -*- encoding : utf-8 -*-

class AddPerformanceLogCard < Card::Migration::Core
  def up
    Card.create! name: "*performance log", type_code: :pointer, codename: :performance_log
  end
end
