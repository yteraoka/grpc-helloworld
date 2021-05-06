FROM golang:1.16.3-alpine3.13 as builder

WORKDIR /work

COPY go.* ./
COPY client client/
COPY server server/

RUN cd /work/client \
    && go mod download \
    && CGO_ENABLED=0 GOOS=linux go build \
    && cd ../server \
    && go mod download \
    && CGO_ENABLED=0 GOOS=linux go build

FROM golang:1.16.3-alpine3.13
WORKDIR /
COPY --from=builder /work/client/client /client
COPY --from=builder /work/server/server /server
COPY --from=builder /go/pkg/mod/google.golang.org/grpc@v1.28.0/testdata /go/pkg/mod/google.golang.org/grpc@v1.28.0/testdata/
RUN adduser -u 1000 -D app app
USER app
EXPOSE 10000
ENTRYPOINT ["/server"]
