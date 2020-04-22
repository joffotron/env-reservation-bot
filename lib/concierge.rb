require_relative 'reservation'
require "ostruct"
require 'time'
require 'active_support/core_ext/string'
require 'active_support/core_ext/time'
require 'aws-sdk-dynamodb'

class Concierge
  def reserve(reservation:)
    item = {
      environment: reservation.environment.strip,
      start_time:  reservation.start_time.rfc3339.strip,
      end_time:    reservation.end_time.rfc3339&.strip,
      user_name:   reservation.user_name.strip,
      timezone:    reservation.timezone.strip,
      comment:     reservation.comment&.strip
    }

    dynamo.put_item(table_name: ENV['DYNAMO_TABLE'], item: item )
  rescue Aws::DynamoDB::Errors::ServiceError => error
    puts 'Unable to add reservation:'
    puts error.message
  end

  def reservations
    all_rows = dynamo.scan(table_name: ENV['DYNAMO_TABLE'])

    saved = all_rows.items.map do |item|
      p item

      user = OpenStruct.new(name: item['user_name'], timezone: item['timezone'])
      Reservation.new(
        user:       user,
        environment: item['environment'],
        start_time: try_date_parse(item['start_time']),
        end_time:   try_date_parse(item['end_time']),
        comment:    item['comment']
      )
    end

    saved.select(&:current?)
  end

  private

  def dynamo
    @dynamo ||= Aws::DynamoDB::Client.new
  end

  def try_date_parse(date_time)
    date_time.to_datetime.in_time_zone
  rescue
    nil
  end

end
