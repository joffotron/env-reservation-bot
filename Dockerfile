FROM lambci/lambda:build-ruby2.7

ENV BASE=/var/task/reservation-bot/

RUN mkdir ${BASE}
WORKDIR ${BASE}
COPY . ${BASE}
