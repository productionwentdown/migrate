FROM golang:1.11-rc-alpine as build

# args
ARG version="4.0.2"
ARG databases="cassandra clickhouse cockroachdb crate mongodb mysql neo4j postgres ql redshift shell spanner sqlite3 stub testing"

# dependencies
RUN apk add --no-cache git ca-certificates

# source
RUN git clone https://github.com/golang-migrate/migrate -b "v${version}" /src/migrate
WORKDIR /src/migrate

# dependencies
RUN go get
WORKDIR /src/migrate/cli

# build
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -ldflags "-s -w" -tags "${databases}" -o /migrate


FROM scratch

ARG version

# labels
LABEL org.label-schema.vcs-url="https://github.com/productionwentdown/migrate"
LABEL org.label-schema.version=${version}
LABEL org.label-schema.schema-version="1.0"

# copy binary and ca certs
COPY --from=build /migrate /migrate
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

WORKDIR /

ENTRYPOINT ["/migrate"]
