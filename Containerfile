ARG BASE_VERSION=15
ARG OPENSPEEDTEST_VERSION=2.0
FROM ghcr.io/daemonless/nginx-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG OPENSPEEDTEST_VERSION
ARG PACKAGES="ca_root_nss"
ARG UPSTREAM_URL="https://api.github.com/repos/openspeedtest/Docker-Image/releases/latest"
ARG UPSTREAM_JQ=".tag_name"
ARG HEALTHCHECK_ENDPOINT="http://localhost:3000/daemonless-ping"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

LABEL org.opencontainers.image.title="OpenSpeedTest" \
    org.opencontainers.image.description="HTML5 Network Speed Test on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/openspeedtest" \
    org.opencontainers.image.url="https://openspeedtest.com/" \
    org.opencontainers.image.documentation="https://github.com/openspeedtest/Speed-Test" \
    org.opencontainers.image.version="${OPENSPEEDTEST_VERSION}" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="3000" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.base="nginx" \
    io.daemonless.category="Utilities" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-jq="${UPSTREAM_JQ}" \
    io.daemonless.healthcheck-url="${HEALTHCHECK_ENDPOINT}" \
    io.daemonless.packages="${PACKAGES}"

# Download OpenSpeedTest files
RUN pkg update && pkg install -y ${PACKAGES} && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/* && \
    fetch -o /tmp/speedtest.tar.gz https://github.com/openspeedtest/Speed-Test/archive/refs/heads/main.tar.gz && \
    mkdir -p /usr/local/www/openspeedtest /app && \
    tar -xzf /tmp/speedtest.tar.gz -C /usr/local/www/openspeedtest --strip-components=1 && \
    rm /tmp/speedtest.tar.gz && \
    echo "${OPENSPEEDTEST_VERSION}" > /app/version && \
    chown -R bsd:bsd /usr/local/www/openspeedtest

# Copy custom nginx config for OpenSpeedTest
COPY root/ /

RUN chmod +x /etc/cont-init.d/* 2>/dev/null || true

EXPOSE 3000


