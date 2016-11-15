FROM golang:1.7-alpine

RUN echo 'http://dl-4.alpinelinux.org/alpine/v3.4/main' >> /etc/apk/repositories && \
  apk upgrade --update && \
  apk add curl

RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/build?os=linux&arch=amd64" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
 && chmod 0755 /usr/bin/caddy \
 && /usr/bin/caddy -version

COPY Caddyfile server.crt server.key ./

EXPOSE 80 443

ENTRYPOINT ["caddy"]
CMD ["--log", "stdout"]
