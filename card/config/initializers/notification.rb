# -*- encoding : utf-8 -*-
ActiveSupport::Notifications.subscribe(/^card/) do |name, start, finish, _id, payload|
  Rails.logger.debug "#{(finish - start) * 1000}ms: #{name}: #{payload[:message]}"
end
