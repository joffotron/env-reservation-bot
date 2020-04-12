require 'json'
require_relative 'lib/utils/kms'
require_relative 'lib/slack_api'

class Handler
  def self.action(event:, context:)
    payload = JSON.parse(event['body'])
    {statusCode: 200, body: Handler.new(payload).action.to_json }
  rescue StandardError => e
    puts e.message
    puts e.backtrace.inspect
    { statusCode: 500, body: { error: e.message, trace: e.backtrace&.join("\n") }.to_json }
  end

  def initialize(payload)
    @payload   = payload
    @kms       = Utils::KMS.new
    @slack_api = SlackAPI.new(kms.decrypt(ENV['BOT_TOKEN']))
  end
  attr_reader :payload, :kms, :slack_api

  #
  # @return [Hash] the response body
  #
  def action
    raise 'Bad token data' unless token_verified?

    requesting_user = slack_api.name_for_user(user_id)
    p "Received mention from #{requesting_user}"

    { challenge: payload['challenge'] }
  end

  private

  def token_verified?
    kms.decrypt(ENV['VERIFICATION_TOKEN']) == payload['token']
  end

  def user_id
    payload['event']['user']
  end
end
