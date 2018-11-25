FROM golang:1.11-alpine
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

WORKDIR /go/src/github.com/mdlayher/apcupsd_exporter
ENV GOPATH=/go APCUPSD_ADDR=":3551" APCUPSD_NETWORK="tcp" \
    TELEMETRY_ADDR=":9162" TELEMETRY_PATH="/metrics"

COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

USER nobody
CMD /go/bin/apcupsd_exporter -apcupsd.addr ${APCUPSD_ADDR} \
    -apcupsd.network ${APCUPSD_NETWORK} -telemetry.addr ${TELEMETRY_ADDR} \
    -telemetry.path ${TELEMETRY_PATH}
