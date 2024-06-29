FROM bitnami/minideb:latest AS base
RUN apt-get update && \
    apt-get --yes upgrade && \
    apt-get --yes install --no-install-recommends ca-certificates zlib1g-dev libssl-dev libcurl4-openssl-dev libevent-dev

FROM base AS builder
RUN apt-get install --yes --no-install-recommends build-essential g++ make cmake git python3 automake libtool libevent-openssl-2.1-7 && \
    git clone --depth 1 --branch 4.0.6 --single-branch https://github.com/transmission/transmission Transmission && \
    cd Transmission && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. &&  \
    make && \
    DESTDIR="/transmission" make install 

FROM base
ENV UID=1000
ENV PORT=9091
COPY --from=builder /transmission /transmission

RUN useradd -ms /bin/bash -u $UID movies
USER movies

CMD ["/transmission/usr/local/bin/transmission-daemon", "--foreground", "--port=${PORT}"]

EXPOSE $PORT
