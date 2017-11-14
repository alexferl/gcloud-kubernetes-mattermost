FROM abiosoft/caddy:builder as builder

ARG version="0.10.10"
ARG plugins="googlecloud"

RUN VERSION=${version} PLUGINS=${plugins} /bin/sh /usr/bin/builder.sh

FROM alpine:3.6
LABEL maintainer "Alexandre Ferland <aferlandqc@gmail.com>"

RUN apk add --no-cache ca-certificates && \
    update-ca-certificates

LABEL caddy_version="0.10.10"

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

COPY Caddyfile /etc/Caddyfile
COPY credentials.json /etc/credentials.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/etc/credentials.json

WORKDIR /srv

EXPOSE 80 443

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree", "--email", "<you@example.com>"]

