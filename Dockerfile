FROM golang:1-alpine AS builder

WORKDIR /go/src/github.com/mdlayher/apcupsd_exporter
ENV GOPATH=/go

COPY . .

RUN apk update && apk upgrade && \
    apk add --no-cache --virtual .build-deps bash git openssh && \
    go get -d -v ./... && \
    go install -v ./... && \
    apk del --purge .build-deps && \
    rm -rf /var/cache/apk/*

FROM alpine:3.8
COPY --from=builder /go/bin/apcupsd_exporter /go/bin/apcupsd_exporter
ENV APCUPSD_ADDR=":3551" APCUPSD_NETWORK="tcp" \
    TELEMETRY_ADDR=":9162" TELEMETRY_PATH="/metrics"
USER nobody
CMD /go/bin/apcupsd_exporter -apcupsd.addr ${APCUPSD_ADDR} \
    -apcupsd.network ${APCUPSD_NETWORK} -telemetry.addr ${TELEMETRY_ADDR} \
    -telemetry.path ${TELEMETRY_PATH}
