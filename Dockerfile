FROM debian:stretch

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends openssh-server dumb-init

RUN adduser --system --shell /bin/sh autossh --uid 1000

ADD sleep.sh /usr/local/bin/sleep.sh
RUN chmod +x /usr/local/bin/sleep.sh
RUN mkdir /var/run/sshd

EXPOSE 22

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

ENV HOST_KEY /etc/ssh/ssh_host_rsa_key
ENV AUTHORIZED_KEYS_FILE /etc/ssh/authorized_keys

CMD ["bash", "-c", "/usr/sbin/sshd -h $HOST_KEY -o AuthorizedKeysFile=$AUTHORIZED_KEYS_FILE -D"]
