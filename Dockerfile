FROM buildpack-deps:jessie-scm
MAINTAINER Bartosz Majsak "bartosz@redhat.com"

RUN apt-get update && apt-get -y --no-install-recommends install \
    ca-certificates \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

COPY bin/kubectl /usr/local/bin/
COPY bin/cluster /kubernetes/cluster

COPY bin/osio.test /usr/local/bin/
COPY run_osio_conformance_tests.sh /run_osio_conformance_tests.sh

WORKDIR /usr/local/bin

ENV RESULTS_DIR="/tmp/results"

RUN ["chmod", "+x", "/run_osio_conformance_tests.sh"]
CMD ["/bin/sh", "-c", "/run_osio_conformance_tests.sh"]