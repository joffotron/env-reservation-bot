# env-reservation-bot

## Deployment instructions

1. `docker compose run --rm compile`
  - Download and compile gems into the `vendor` directory using the same Ruby environment as the lambda runtime
1. `aws-vault exec <Shared-Services profile> docker -- compose run --rm serverless /bin/sh -c 'sls login && sls deploy --verbose'`
  - Deploy the lambdas with serverless

The application depends on the following parameters to be available in the parameter store of the account and region:

- /reservationbot/slack.bot.oauth.token - from https://api.slack.com/apps/YOURAPP/oauth
- /reservationbot/slack.verification.token from https://api.slack.com/apps/YOURAPP/general
- /reservationbot/supported.envs - set this as a comma separated list
