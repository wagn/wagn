FROM phusion/passenger-ruby22
MAINTAINER Gerry Gleason (gerryg@inbox.com)

WORKDIR /work
COPY docker/files/* /tmp/build/
RUN /tmp/build/setup.sh

