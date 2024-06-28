FROM lambci/lambda:build-ruby3.3

ENV BASE=/var/task/reservation-bot/

RUN mkdir ${BASE}
WORKDIR ${BASE}
COPY . ${BASE}
