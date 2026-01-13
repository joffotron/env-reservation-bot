FROM public.ecr.aws/lambda/ruby:3.4

ENV LANG=en_US.UTF-8

RUN dnf install -y ruby3.4-devel.x86_64 libyaml-devel.x86_64
RUN dnf groupinstall "Development Tools" -y

WORKDIR ${LAMBDA_TASK_ROOT}

ENTRYPOINT ["bash", "-c"]
CMD ["/var/task/.buildkite/bundle.sh"]
