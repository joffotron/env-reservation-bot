FROM public.ecr.aws/lambda/ruby:3.2

WORKDIR ${LAMBDA_TASK_ROOT}
COPY . ${LAMBDA_TASK_ROOT}

ENV LANG=en_US.UTF-8

RUN #yum install -y ruby3.2.x86_64 ruby3.2-devel.x86_64 \
RUN yum install -y ruby3.2-devel.x86_64 libyaml-devel.x86_64
RUN yum groupinstall "Development Tools" -y

ENTRYPOINT "bash"
CMD ["/var/task/.buildkite/bundle.sh"]