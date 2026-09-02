FROM --platform=$BUILDPLATFORM golang:1.27.1-trixie as builder

ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/app

COPY go.* ./
COPY client client/
COPY server server/

RUN cd client \
    && go mod download \
    && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
    && cd ../server \
    && go mod download \
    && CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build \
    && cd .. \
    && grpc_dir="$(go list -m -f '{{.Dir}}' google.golang.org/grpc)" \
    && mkdir -p "/out${grpc_dir}" \
    && cp -r "${grpc_dir}/testdata" "/out${grpc_dir}/"

FROM gcr.io/distroless/static-debian13
WORKDIR /
COPY --from=builder /go/src/app/client/client /client
COPY --from=builder /go/src/app/server/server /server
COPY --from=builder /out/go /go
USER nonroot
EXPOSE 10000
ENTRYPOINT ["/server"]
