FROM bitnami/minideb:latest AS base
RUN apt-get update && \
    apt-get --yes upgrade && \
    apt-get --yes install --no-install-recommends ca-certificates libcurl4 libevent-2.1-7

FROM base AS builder

ARG TRANSMISSION_VERSION=4.0.6

WORKDIR /build

RUN apt-get install --yes --no-install-recommends build-essential g++ make cmake git python3 automake libtool zlib1g-dev libssl-dev libcurl4-openssl-dev libevent-dev && \
    git clone --depth 1 --branch $TRANSMISSION_VERSION --single-branch https://github.com/transmission/transmission transmission && \
    cd transmission && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. &&  \
    make && \
    DESTDIR="/transmission" make install

FROM base

WORKDIR /transmission

ENV UID=1000
ENV PORT=9091
# 'critical', 'error', 'warn', 'info', 'debug', or 'trace'
ENV LOG_LEVEL=info
ENV TRANSMISSION_WEB_HOME=/transmission/usr/local/share/transmission/public_html

RUN useradd -ms /bin/bash -u $UID transmission

COPY --from=builder /transmission /transmission
COPY --chown=transmission:transmission .config /transmission/config

USER transmission

EXPOSE $PORT

CMD ["sh", "-c", "/transmission/usr/local/bin/transmission-daemon --foreground --port=${PORT} --config-dir=/transmission/config/transmission-daemon --log-level=${LOG_LEVEL}"]
