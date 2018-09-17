FROM golang:1.11-rc-alpine as build

RUN apk add --no-cache git=2.18.0-r0 ca-certificates

RUN wget -O /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && chmod +x /usr/local/bin/dep

RUN go get -u -d github.com/golang-migrate/migrate/cli
WORKDIR $GOPATH/src/github.com/golang-migrate/migrate/cli
RUN dep ensure
RUN CGO_ENABLED=0 go build -ldflags "-s -w" -tags 'cassandra clickhouse cockroachdb crate mongodb mysql neo4j postgres ql redshift shell spanner sqlite3 stub testing' -o /migrate


FROM scratch

WORKDIR /

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /migrate /usr/local/bin/migrate

ENTRYPOINT ["/usr/local/bin/migrate"]
