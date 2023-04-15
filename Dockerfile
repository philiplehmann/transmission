FROM bitnami/minideb:latest as base
RUN apt-get update && apt-get -y upgrade && apt-get -y install make cmake zlib1g-dev libssl-dev libcurl4-openssl-dev libevent-dev

FROM base as builder
RUN apt-get install -y build-essential git python automake libtool netatalk libevent-openssl-2.1-7 \
  && git clone --depth 1 --branch 4.0.3 --single-branch https://github.com/transmission/transmission Transmission \
  && cd Transmission \
  && git submodule update --init --recursive \
  && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
  && make

FROM base
COPY --from=builder /Transmission /Transmission
RUN cd Transmission/build \
  && make install \
  && cd / && rm -rf /Transmission \
  && apt-get -y remove make cmake && apt-get -y autoremove && apt-get -y clean

RUN useradd -ms /bin/bash -u 1002 movies
USER movies

ENTRYPOINT ["/usr/local/bin/transmission-daemon", "--foreground", "--port=9091"]

EXPOSE 9091