require 'strscan'
require 'time'
require 'active_support'
require 'active_support/core_ext/time'
require 'active_support/core_ext/numeric/time'

class Reservation
  attr_reader :environment, :start_time, :end_time, :user_name, :timezone, :comment

  def self.from_message(message:, user:)
    reservation = Reservation.new(user: user)
    reservation.parse_message!(message)
    reservation
  end

  def initialize(user:, environment: nil, start_time: nil, end_time: nil, comment: nil)
    @user_name = user.name
    @timezone = user.timezone
    @environment = environment
    @start_time = start_time
    @end_time = end_time
    @comment = comment
  end

  def human_readable
    return "#{environment} is now free for use" if start_time.nil?

    end_msg = end_time.nil? ? 'with no specified end' : "until #{format_time(end_time)}"
    reason = comment.nil? ? 'No reason given' : "Reason: #{comment}"

    <<~MSG
      Environment `#{environment}` is reserved by #{user_name}
      From #{format_time(start_time)}, #{end_msg}
      #{reason}
    MSG
  end

  def current?
    return false if start_time.nil?

    start_time <= Time.now && (end_time.nil? || end_time >= Time.now)
  end

  # `@reservebot staging-nz now 1h just testing`
  # `@reservebot demo-au 13:00 -`
  # `@reservebot demo-au free`
  #
  def parse_message!(msg)
    s = StringScanner.new(msg)
    s.skip_until(/@\w+\b/)

    @environment = sanitize(s.scan_until(/[a-z-:]+/))
    start_input  = sanitize(s.scan_until(/now|\d{1,2}:\d{2}|\d{1,2}[hrs]+/))
    @start_time  = parse_time(start_input)
    p "Set start time as #{@start_time}"

    return if s.eos?
    end_input = sanitize(s.scan_until(/-|\d{2}:\d{2}|\d{1,2}[hrs]+/))
    @end_time = parse_time(end_input)
    p "Set end time as #{@end_time}"

    @comment = s.rest&.strip
  end

  private

  def parse_time(input)
    case input
      when '-', 'free', '', nil then return nil
      when 'now' then return DateTime.now
      when /\d{1,2}[hrs]+/
        return parse_offset_time(input)
      else
        return parse_today_or_tomorrow(input)
    end
  end

  def parse_today_or_tomorrow(input)
    time = tz_parse(input, Date.today)
    time < Time.now.utc ? tz_parse(input, Date.tomorrow) : time
  end

  def parse_offset_time(input)
    hours = input.match(/\d{1,2}/)[0].to_i
    return @start_time + hours.hours if @start_time

    DateTime.now + hours.hours
  end

  def tz_parse(*args)
    ActiveSupport::TimeZone[timezone]&.parse(*args).utc
  end

  def format_time(time)
    return '' unless time

    time.in_time_zone(timezone).strftime('%a %d, %R')
  end

  def sanitize(string)
    return '' unless string

    string.gsub(/[^a-zA-Z0-9:\-_]/, '')
  end
end
