FROM golang:1.21.5-bullseye as builder

WORKDIR /go/src/app

COPY go.* ./
COPY client client/
COPY server server/

RUN cd client \
    && go mod download \
    && CGO_ENABLED=0 GOOS=linux go build \
    && cd ../server \
    && go mod download \
    && CGO_ENABLED=0 GOOS=linux go build

FROM gcr.io/distroless/static-debian11
WORKDIR /
COPY --from=builder /go/src/app/client/client /client
COPY --from=builder /go/src/app/server/server /server
COPY --from=builder /go/pkg/mod/google.golang.org/grpc@v1.54.0/testdata /go/pkg/mod/google.golang.org/grpc@v1.54.0/testdata/
USER nonroot
EXPOSE 10000
ENTRYPOINT ["/server"]
