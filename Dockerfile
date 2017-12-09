FROM debian:jessie

MAINTAINER Jere Virta

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yq --no-install-recommends \
    wget \
    nano \
    lsb-release \
    curl \
    apt-utils \
    debian-keyring \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY content/ /
COPY start.sh /
RUN chmod +x /start.sh

ENV INITSYSTEM on

EXPOSE 5665

ENTRYPOINT ["/start.sh"]
