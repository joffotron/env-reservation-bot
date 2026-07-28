require_relative 'reservation'
require "ostruct"
require 'time'
require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/time'
require 'aws-sdk-dynamodb'

class Concierge
  def reserve(reservation:)
    if reservation.start_time.nil?
      cancel_reservation(reservation)
      return
    end

    make_reservation(reservation)
  end

  def reservations
    all_rows = dynamo.scan(table_name: ENV['DYNAMO_TABLE'])

    saved = all_rows.items.map do |item|
      p item

      user = OpenStruct.new(name: item['user_name'], timezone: item['timezone'])
      Reservation.new(
        user:       user,
        environment: item['environment'],
        repo:       item['repo'],
        start_time: try_date_parse(item['start_time']),
        end_time:   try_date_parse(item['end_time']),
        comment:    item['comment']
      )
    end

    saved.select(&:current?)
  end

  private

  def make_reservation(reservation)
    item = {
      environment: empty_check(reservation.environment),
      repo:        empty_check(reservation.repo),
      start_time:  empty_check(reservation.start_time&.rfc3339),
      end_time:    empty_check(reservation.end_time&.rfc3339),
      user_name:   empty_check(reservation.user_name),
      timezone:    empty_check(reservation.timezone),
      comment:     empty_check(reservation.comment)
    }

    dynamo.put_item(table_name: ENV['DYNAMO_TABLE'], item: item)
  rescue Aws::DynamoDB::Errors::ServiceError => error
    puts 'Unable to add reservation:'
    puts error.message
  end

  def cancel_reservation(reservation)
    dynamo.delete_item(
      key: { 'environment' => reservation.environment},
      table_name: ENV['DYNAMO_TABLE']
    )
  rescue Aws::DynamoDB::Errors::ServiceError => error
    puts 'Unable to remove reservation:'
    puts error.message
  end

  def dynamo
    @dynamo ||= Aws::DynamoDB::Client.new
  end

  def try_date_parse(dynamo_date_string)
    DateTime.parse(dynamo_date_string).utc
  rescue
    nil
  end

  def empty_check(string)
    return nil if string.nil? || string.length == 0

    string
  end
end
