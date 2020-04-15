require_relative 'reservation'
require "ostruct"

class Concierge
  def reserve(reservation:)
    # no-op
  end

  def reservations
    user = OpenStruct.new(name: 'Joseph', timezone: 'Australia/Canberra')

    [
      Reservation.new(environment: 'staging-nz', start_time: Time.now, end_time: nil, user: user),
      Reservation.new(environment: 'demo-au', start_time: Time.now, end_time: nil, user: user)
    ]
  end
end
