FROM bitnami/minideb:latest as builder

RUN apt-get update \
  && apt-get install -y build-essential git cmake libssl-dev libcurl4-openssl-dev python \
  && git clone https://github.com/transmission/transmission Transmission \
  && cd Transmission \
  && git submodule update --init --recursive \
  && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo .. \
  && make \
  && make install \
  && cd && rm -rf /Transmission \
  && apt-get remove -y build-essential git cmake \
  && apt-get autoremove -y

RUN useradd -ms /bin/bash -u 1002 movies
USER movies

ENTRYPOINT ["/usr/local/bin/transmission-daemon", "--foreground", "--port=9091"]

EXPOSE 9091