# Build stage
ARG GO_VERSION=1.9
ARG PROJECT_PATH=/go/src/github.com/dustin-decker/eraftd
FROM golang:${GO_VERSION}-alpine AS builder
WORKDIR /go/src/github.com/dustin-decker/eraftd
RUN apk --no-cache add git
RUN go get -u github.com/golang/dep/cmd/dep
COPY ./ ${PROJECT_PATH}
RUN export PATH=$PATH:`go env GOHOSTOS`-`go env GOHOSTARCH` \
    && dep ensure \
    && CGO_ENABLED=0 GOOS=`go env GOHOSTOS` GOARCH=`go env GOHOSTARCH` go build -o eraftd \
    && go test $(go list ./... | grep -v /vendor/)

# Production image*
FROM scratch
EXPOSE 12379
EXPOSE 12380
COPY --from=builder /go/src/github.com/dustin-decker/eraftd/eraftd /eraftd
ENTRYPOINT [ "/eraftd" ]