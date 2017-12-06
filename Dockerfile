FROM debian:jessie

MAINTAINER Jere Virta

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install -yq wget nano lsb-release curl apt-utils debian-keyring supervisor && \
    echo "deb http://debmon.org/debmon debmon-jessie main" >>/etc/apt/sources.list && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY content/ /
COPY start.sh /
RUN chmod +x /start.sh
RUN chmod +s /opt/supervisor/icinga2_supervisor

ENV INITSYSTEM on

RUN echo "$MASTER_IP $MASTER_HOST" >>/etc/hosts

EXPOSE 5665

ENTRYPOINT ["/start.sh"]
