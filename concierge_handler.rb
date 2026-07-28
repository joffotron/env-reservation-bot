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
        reply(nicer_env_list)
      when /@\w+ supported-envs/
        reply(supported_envs)
      when /@\w+ help$/
        reply(help_me_obi_wan)
      else
        reservation = Reservation.from_message(message: incoming_message, user: requesting_user)
        if reservation.valid_env?
          Concierge.new.reserve(reservation: reservation)
          reply(reservation.human_readable)
        else
          reply(supported_envs)
        end
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

  def nicer_env_list
    reservations = Concierge.new.reservations
    return 'All environments are free for use' if reservations.empty?

    the_list="\n"
    reservations.reduce('') do |acc, e|
      end_time = e.end_time.in_time_zone(e.timezone).strftime('%a %d, %R')
      the_list += <<~TEXT
        #{e.user_name} has `#{e.environment}` until #{end_time}. Reason: #{e.comment}

      TEXT
    end

    the_list
  end

  def help_me_obi_wan
    <<~TEXT
      Reservebot - Reserve staging environment stacks on a specific stack and time limited basis. 

      Basic Syntax is:
      @reservebot <env name> <start time> <end time> <comment>
    
      Example usages are:

      // Reserve for 1 hour starting now, with a comment
      `@reservebot #{env_list.sample} now 1h Just Testing`

      // Reserve starting at 1pm with no set end (i.e use '-') 
      `@reservebot #{env_list.sample} 13:00 - Reserving for good reasons`

      // Reserve starting at 1pm with a specific end time (and no comment)
      `@reservebot #{env_list.sample} 13:00 16:45`

      // Optionally specify a repo to reserve (arbitrary string)
      `@reservebot #{env_list.sample} now 1h Just Testing --repo my-app`

      // Release an environment again
      `@reservebot #{env_list.sample} free`

      // See what's currently held
      `@reservebot list`

      // List environments supported by CI
      `@reservebot supported-envs`
      TEXT
  end

  def env_list
    ENV['SUPPORTED_ENVS'].split(',')
  end

  def supported_envs
    message = <<~TEXT
      Environments that CI will recognise:
    TEXT
    message + env_list.map { |env| "* #{env}\n" }.join
  end
end
