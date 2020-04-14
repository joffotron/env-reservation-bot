require 'strscan'
require 'time'

class Reservation
  attr_reader :environment, :start_time, :end_time, :user, :comment

  def self.from_message(message:, user:)
    reservation = Reservation.new(user: user)
    reservation.parse_message!(message)
    reservation
  end

  def initialize(user:, environment: nil, start_time: nil, end_time: nil, comment: nil)
    @user = user
    @environment = environment
    @start_time = start_time
    @end_time = end_time
    @comment = comment
  end

  def human_readable
    end_msg = end_time.nil? ? 'with no specified end' : "until #{format_time(end_time)}"
    reason = comment.nil? ? 'No reason given' : "Reason: #{comment}"

    <<~MSG
      Environment #{environment} is reserved by #{user} 
      From #{format_time(start_time)}, #{end_msg}
      #{reason}
    MSG
  end

  # `@reservebot staging-nz now 1h just testing`
  # `@reservebot demo-au 13:00 -`
  # `@reservebot demo-au free`
  #
  def parse_message!(msg)
    s = StringScanner.new(msg)
    s.skip_until(/@\w+\s/)

    @environment = s.scan_until(/[a-z-]+/)&.strip
    start_input  = s.scan_until(/now|\d{2}:\d{2}|\d{1,2}h/)&.strip
    @start_time = parse_time(start_input)

    return if s.eos?
    end_input   = s.scan_until(/-|\d{2}:\d{2}|\d{1,2}h/)&.strip
    @end_time = parse_time(end_input)

    @comment     = s.rest&.strip
  end

  private

  def parse_time(input)
    case input
      when '-' then return nil
      when 'now' then return Time.now
      when /\d{1,2}h/
        hours = input.match(/\d{1,2}/)[0].to_i
        return Time.now + (hours * 60 * 60)
      else
        return Time.parse(input)
    end
  end

  def format_time(time)
    return '' unless time

    time.strftime('%R')
  end

end
