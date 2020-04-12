require_relative 'lib/slack_api'
require_relative 'lib/reservation'
require_relative 'lib/concierge'

class ConciergeHandler
  def self.handle(event:, context:)
    ConciergeHandler.new(event).action
  end

  def initialize(payload)
    @payload   = payload
    @slack_api = SlackAPI.new(slack_token: ENV['BOT_TOKEN'])
  end

  attr_reader :payload, :slack_api

  def action
    requesting_user = slack_api.name_for_user(user_id)
    p "Received mention from #{requesting_user}"

    reservation = Reservation.from_message(message: incoming_message, user: requesting_user)
    # Concierge.new.reserve(reservation: reservation)

    slack_api.talk_back(user_id: user_id, channel: incoming_channel, message: reservation.human_readable)
  end

  private

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
