require 'json'
require_relative 'lib/concierge'

class ListHandler

  def self.list_reservations(event:, context:)
    puts event

    {statusCode: 200, body: reservations.to_json}
  end

  private

  def self.reservations
    Concierge.new.reservations.map { |r| present_reservation(r) }
  end

  def self.present_reservation(reservation)
    {
      environment: reservation.environment,
      user: reservation.user_name,
      reason: reservation.comment,
      end_time: reservation.end_time&.iso8601,
    }
  end
end
