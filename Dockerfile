# syntax=docker/dockerfile:1.3
FROM haproxytech/haproxy-alpine:2.9
RUN apk update --no-cache && apk upgrade --no-cache openssl && apk add --no-cache gettext
RUN chown haproxy:haproxy /etc/haproxy
COPY --chown=haproxy:haproxy --chmod=644 config/0-haproxy.conf /etc/haproxy/0-haproxy.conf.template
COPY --chown=haproxy:haproxy --chmod=644 config/0-haproxy-no-chroot.conf /etc/haproxy/0-haproxy-no-chroot.conf.template
COPY --chown=haproxy:haproxy --chmod=644 config/1-defaults.conf /etc/haproxy/1-defaults.conf.template
COPY --chown=haproxy:haproxy --chmod=644 config/2-relay.conf /etc/haproxy/2-relay.conf.template
COPY --chown=haproxy:haproxy --chmod=644 config/3-codecov-relay.conf /etc/haproxy/3-codecov-relay.conf.template
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh


ARG COMMIT_SHA
ARG VERSION
ENV BUILD_ID $COMMIT_SHA
ENV BUILD_VERSION $VERSION

RUN chown -R haproxy:haproxy /var/lib/haproxy && mkdir -p /run && chown -R haproxy:haproxy /etc/haproxy && chown -R haproxy:haproxy /run

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
