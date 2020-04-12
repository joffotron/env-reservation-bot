#!/bin/bash

set -eo pipefail

cd "/var/task/reservation-bot"
bundle config set deployment true
bundle install --without test development
