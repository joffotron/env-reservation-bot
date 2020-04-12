require 'json'
require 'aws-sdk-lambda'

class MentionHandler

  def self.incoming_mention(event:, context:)
    payload = JSON.parse(event['body'])

    raise 'Bad token data' unless token_verified?(payload)

    lambda_api = Aws::Lambda::Client.new
    lambda_api.invoke({
      function_name: ENV['CONCIERGE_FN'],
      invocation_type: "Event",
      payload:   payload.to_json
    })

    {statusCode: 200, body: { challenge: payload['challenge'] }.to_json }
  rescue StandardError => e
    puts e.message
    puts e.backtrace.inspect
    { statusCode: 500, body: { error: e.message, trace: e.backtrace&.join("\n") }.to_json }
  end

  def self.token_verified?(payload)
    ENV['VERIFICATION_TOKEN'] == payload['token']
  end
end
