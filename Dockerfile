FROM debian:buster

MAINTAINER Bruno Binet <bruno.binet@helioslite.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    openssh-server dumb-init net-tools sudo

COPY pre-start.sh /usr/local/sbin/pre-start.sh
COPY sleep.sh /usr/local/bin/sleep.sh
COPY cleanup_port.sh /usr/local/sbin/cleanup_port.sh

RUN chmod 750 /usr/local/sbin/* && \
    adduser --group --system --shell /bin/sh --disabled-password \
      --home /var/lib/autossh autossh && \
    chmod 700 /var/lib/autossh && \
    mkdir -p -m 700 /var/lib/autossh/.ssh && \
    chown -R autossh:autossh /var/lib/autossh && \
    mkdir /var/run/sshd

EXPOSE 22

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

ENV AUTOSSH_PUBKEY_PATH /run/secrets/autossh_id_rsa.pub

CMD ["bash", "-c", "/usr/local/sbin/pre-start.sh && /usr/sbin/sshd -D"]
