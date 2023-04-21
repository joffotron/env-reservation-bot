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
    requesting_user = slack_api.user_details(user_id)
    p "Received mention from #{requesting_user.name}: #{incoming_message}"

    case incoming_message
      when /@\w+ list$/
        reply("Currently Reserved environments are: #{reserved_envs.join(', ')}")
      when /@\w+ supported-envs/
        reply(supported_envs)
      when /@\w+ help$/
        reply(help_me_obi_wan)
      else
        reservation = Reservation.from_message(message: incoming_message, user: requesting_user)
        Concierge.new.reserve(reservation: reservation)
        reply(reservation.human_readable)
    end
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

  def reply(message)
    slack_api.talk_back(user_id: user_id, channel: incoming_channel, message: message)
  end

  def reserved_envs
    Concierge.new.reservations.map(&:environment)
  end

  def help_me_obi_wan
    <<~TEXT
      Reservebot - Reserve staging environment stacks on a specific stack and time limited basis. 
    
      Example usages are:

      // Reserve for 1 hour starting now, with a comment
      `@reservebot user-experience now 1h Just Testing`

      // Reserve starting at 1pm with no set end (no comment)
      `@reservebot backend:lifecycle 13:00 -`

      // Release an environment again
      `@reservebot smartshift free`

      // See what's currently held
      `@reservebot list`

      // List environments supported by CI
      `@reservebot supported-envs`
      TEXT
  end

  def supported_envs
    <<~TEXT
      Environments that CI will recognise:
      * admin-web
      * cba-signup
      * mobile-app
      * webapp
      * api
      * cba-api
      * cognito-triggers
      * pg-migrations
      * internal-process
      
      * Backend stacks:
        * smartshift
        * smartshift-enrollments
        * demand-response
        * workflow
        * jump
        * office-signage
        * ux (user-experience)
        * forecasting
        * lifecycle
        * notifications
        * operations
        * telemetry
    TEXT
  end
end
