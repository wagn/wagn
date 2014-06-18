# -*- encoding : utf-8 -*-
ActiveSupport::Notifications.subscribe /^wagn/ do |name, start, finish, id, payload|
  Rails.logger.debug "#{ (finish - start) * 1000 }ms: #{ name }: #{ payload[:message] }"
end
