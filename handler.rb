require 'json'
require_relative 'lib/slack_api'
require_relative 'lib/reservation'
require_relative 'lib/concierge'

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
    @slack_api = SlackAPI.new(slack_token: ENV['BOT_TOKEN'])
  end
  attr_reader :payload, :slack_api

  #
  # @return [Hash] the response body
  #
  def action
    raise 'Bad token data' unless token_verified?

    requesting_user = slack_api.name_for_user(user_id)
    p "Received mention from #{requesting_user}"

    reservation = Reservation.from_message(message: incoming_message, user: requesting_user)
    # Concierge.new.reserve(reservation: reservation)

    slack_api.talk_back(user_id: user_id, channel: incoming_channel, message: reservation.human_readable)

    { challenge: payload['challenge'] }
  end

  private

  def token_verified?
    ENV['VERIFICATION_TOKEN'] == payload['token']
  end

  def user_id
    payload['event']['user']
  end

  def incoming_message
    Slack::Messages::Formatting.unescape(payload['event']['text'])
  end

  def incoming_channel
    Slack::Messages::Formatting.unescape(payload['event']['channel'])
  end
end
