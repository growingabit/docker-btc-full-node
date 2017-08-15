FROM ubuntu:16.04

# Specify RPC auth
ARG RPC_USER
ARG RPC_PASSWORD

# Initial OS setup & refresh
# https://launchpad.net/~bitcoin/+archive/ubuntu/bitcoin
RUN echo "deb http://ppa.launchpad.net/bitcoin/bitcoin/ubuntu xenial main" > /etc/apt/sources.list.d/bitcoin.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C70EF1F0305A1ADB9986DBD8D46F45428842CE5E
RUN apt-get update && apt-get install -y \
    bitcoind \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Setup locales for debugging purposes
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Create dedicated user
RUN useradd -ms /bin/bash btcd
USER btcd
WORKDIR /home/btcd

# Copy & edit default configuration
COPY bitcoin.conf /home/btcd/.bitcoin/bitcoin.conf
### --- Dirty workaround for: https://github.com/moby/moby/issues/6119
USER root
RUN chown -R btcd:btcd /home/btcd/.bitcoin
USER btcd
### --- Should be solved by: https://github.com/moby/moby/pull/34263
RUN sed -i "s/RPC_USER_CHANGEME/$RPC_USER/" /home/btcd/.bitcoin/bitcoin.conf && \
    sed -i "s/RPC_PASSWORD_CHANGEME/$RPC_PASSWORD/" /home/btcd/.bitcoin/bitcoin.conf

# Export blockchain data and config to volume
VOLUME ["/home/btcd/.bitcoin"]

# Expose standard & testnet ports
EXPOSE 8333 8332 18333 18332

# Start node daemon
CMD ["bitcoind"]