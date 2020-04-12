require_relative 'utils/kms'
require 'slack-ruby-client'

class SlackAPI
  def initialize(slack_token)
    Slack.configure do |config|
      config.token = slack_token
      raise 'Missing ENV[BOT_TOKEN]!' unless config.token
    end

    @client = Slack::Web::Client.new
    @client.auth_test
  end

  def name_for_user(user_id)
    profile = client.users_info(user: user_id)&.user&.profile
    return 'Unknown' unless profile

    profile.real_name || profile.display_name
  end

  private

  attr_reader :client
end

