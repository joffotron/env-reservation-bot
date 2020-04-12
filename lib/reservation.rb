class Reservation
  attr_reader :environment, :start_time, :end_time, :user

  def self.from_message(message:, user:)
    Reservation.new(environment: 'staging-nz', start_time: Time.now, end_time: nil, user: user)
  end

  def initialize(environment:, start_time:, end_time:, user:)
    @environment = environment
    @start_time = start_time
    @end_time = end_time
    @user = user
  end

  def human_readable
    "Environment #{environment} is reserved by #{user} from #{format_time(start_time)}"
  end

  private

  def format_time(time)
    return '' unless time

    time.strftime('%R')
  end

end
