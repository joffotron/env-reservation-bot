#!/bin/bash

set -eo pipefail

GEM_HOME=${LAMBDA_TASK_ROOT}
bundle config set deployment true
bundle config set without 'test development'
bundle install
