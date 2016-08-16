# -*- encoding : utf-8 -*-

class RemovePerformanceLogCard < Card::Migration::Core
  def up
    if card = Card[:performance_log]
      card.update_attributes! codename: nil
      card.delete
    end
  end
end
