FROM debian:stretch

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends openssh-server dumb-init

RUN adduser --system --group --shell /bin/sh --disabled-password --uid 1000 autossh

COPY pre-create-users.sh /usr/local/bin/pre-create-users.sh
COPY sleep.sh /usr/local/bin/sleep.sh
RUN mkdir /var/run/sshd

EXPOSE 22

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

ENV HOST_KEY /etc/ssh/ssh_host_rsa_key
ENV AUTHORIZED_KEYS_FILE /etc/ssh/authorized_keys

CMD ["bash", "-c", "/usr/local/bin/pre-create-users.sh && /usr/sbin/sshd -h $HOST_KEY -o AuthorizedKeysFile=$AUTHORIZED_KEYS_FILE -D"]
