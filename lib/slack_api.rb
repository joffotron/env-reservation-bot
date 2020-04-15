require 'slack-ruby-client'
require "ostruct"

class SlackAPI
  def initialize(slack_token:)
    Slack.configure do |config|
      config.token = slack_token
      raise 'Missing ENV[BOT_TOKEN]!' unless config.token
    end

    @client = Slack::Web::Client.new
    @client.auth_test
  end

  def user_details(user_id)
    user = client.users_info(user: user_id)&.user
    profile = user&.profile

    return 'Unknown' unless profile

    OpenStruct.new(name: (profile.display_name || profile.real_name), timezone: user.tz)
  end

  def talk_back(user_id:, channel:, message:)
    text = "<@#{user_id}> #{message}"
    client.chat_postMessage(channel: channel, text: text, as_user: true)
  end

  private

  attr_reader :client
end
