FROM golang:1.11-rc-alpine as build

# args
ARG version="3.5.2"
ARG databases="cassandra clickhouse cockroachdb crate mongodb mysql neo4j postgres ql redshift shell spanner sqlite3 stub testing"

# dependencies
RUN apk add --no-cache git ca-certificates

# build tools: dep
RUN wget -O /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.5.0/dep-linux-amd64 && chmod +x /usr/local/bin/dep

# source
RUN git clone https://github.com/golang-migrate/migrate -b "v${version}" $GOPATH/src/github.com/golang-migrate/migrate
WORKDIR $GOPATH/src/github.com/golang-migrate/migrate
RUN git checkout -b "v${version}"

# dependencies
WORKDIR $GOPATH/src/github.com/golang-migrate/migrate/cli
RUN dep ensure

# build
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -ldflags "-s -w" -tags '${databases}' -o /migrate


FROM scratch

# labels
LABEL org.label-schema.vcs-url="https://github.com/productionwentdown/migrate"
LABEL org.label-schema.version=${version}
LABEL org.label-schema.schema-version="1.0"

# copy binary and ca certs
COPY --from=build /migrate /migrate
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

WORKDIR /

ENTRYPOINT ["/migrate"]
