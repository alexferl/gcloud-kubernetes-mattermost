FROM abiosoft/caddy:builder as builder

ARG version="0.10.10"
ARG plugins=""

RUN VERSION=${version} PLUGINS=${plugins} /bin/sh /usr/bin/builder.sh

FROM alpine:3.6
LABEL maintainer "Alexandre Ferland <aferlandqc@gmail.com>"

LABEL caddy_version="0.10.10"

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

COPY Caddyfile /etc/Caddyfile
COPY server.crt /etc/server.crt
COPY server.key /etc/server.key

WORKDIR /srv

EXPOSE 80 443

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]

