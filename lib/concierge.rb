require_relative 'reservation'

class Concierge
  def reserve(reservation:)
    # no-op
  end

  def reservations
    [
      Reservation.new(environment: 'staging-nz', start_time: Time.now, end_time: nil, user: 'Joseph'),
      Reservation.new(environment: 'demo-au', start_time: Time.now, end_time: nil, user: 'Joseph')
    ]
  end
end
