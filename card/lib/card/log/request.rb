require 'csv'

class Card::Log

  class Request

    def self.path
      path = (Card.paths['request_log'] && Card.paths['request_log'].first) || File.dirname(Card.paths['log'].first)
      filename = "#{Date.today}_#{Rails.env}.csv"
      File.join path, filename
    end

    def self.write_log_entry controller
      return if controller.env["REQUEST_URI"] =~ %r{^/files?/}

      controller.instance_eval do
        log = []
        log << (Card::Env.ajax? ? "YES" : "NO")
        log << env["REMOTE_ADDR"]
        log << Card::Auth.current_id
        log << card.name
        log << action_name
        log << params['view'] || (s = params['success'] and  s['view'])
        log << env["REQUEST_METHOD"]
        log << status
        log << env["REQUEST_URI"]
        log << DateTime.now.to_s
        log << env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
        log << env["HTTP_REFERER"]

        File.open(Card::Log::Request.path, "a") do |f|
          f.write CSV.generate_line(log)
        end
      end
    end

  end
end