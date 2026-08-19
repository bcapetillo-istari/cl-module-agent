FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    zip \
    unzip \
    ca-certificates \
    jq \
    nano \
    && rm -rf /var/lib/apt/lists/*

ARG AGENT_VERSION=11.10.3
ARG STARI_CLI_VERSION=0.21.14
ENV AGENT_VERSION=${AGENT_VERSION}

COPY downloads/istari-agent_${AGENT_VERSION}_amd64.deb /tmp/istari-agent.deb
RUN dpkg -i /tmp/istari-agent.deb || apt-get install -y -f && rm /tmp/istari-agent.deb

COPY downloads/stari_ubuntu_24_04-amd64-v${STARI_CLI_VERSION}.tar.gz /tmp/stari-cli.tar.gz
RUN mkdir -p /opt/stari-cli \
    && tar -xzf /tmp/stari-cli.tar.gz -C /opt/stari-cli \
    && ln -s /opt/stari-cli/stari_ubuntu_24_04-amd64/stari_ubuntu_24_04-amd64 /usr/local/bin/stari \
    && rm /tmp/stari-cli.tar.gz

COPY cl_module_agent/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
