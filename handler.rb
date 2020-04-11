require 'json'

class Handler

  # {
  #     'token': '0MkuolbPtPqTrGmkSvcKGksI',
  #     'team_id': 'T5MBG2JKG',
  #     'api_app_id': 'A5LL7G91B',
  #     'event': {
  #       "type": "app_mention",
  #       "user": "U061F7AUR",
  #       "text": "<@U0LAN0Z89> is it everything a river should be?",
  #       "ts": "1515449522.000016",
  #       "channel": "C0LAN2Q65",
  #       "event_ts": "1515449522000016"
  #     },
  #     'type': 'event_callback',
  #     'challenge': '3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P',
  #     'authed_users': ['U5MBXN7M4'],
  #     'event_id': 'Ev5PDV5YUS',
  #     'event_time': 1496764428
  # }
  def self.action(event:, context:)
    p event.inspect

    {
      statusCode: 200,
      body:    JSON.generate({ challenge: event['challenge'] }),
      headers: JSON.generate({ 'X-Slack-No-Retry': 1 })
    }
  end
end
