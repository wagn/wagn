card_reader :consumer_key
card_reader :consumer_secret
card_reader :access_token
card_reader :access_secret

card_reader :message

require 'twitter'

def deliver args={}
  client.update message_card.contextual_content(args[:context])
end

def client
  @client ||=
    ::Twitter::REST::Client.new do |config|
      config.consumer_key = consumer_key
      config.consumer_secret = consumer_secret
      config.access_token = access_token
      config.access_token_secret = access_secret
    end
end
