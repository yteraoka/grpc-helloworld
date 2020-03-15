# gRPC client / server for Testing

based on https://github.com/grpc/grpc-go/tree/master/examples

## server

```
$ ./server -help
Usage of ./server:
  -cert_file string
    	The TLS cert file
  -key_file string
    	The TLS key file
  -port int
    	The server port (default 10000)
  -sleep int
    	wait duration in second before response
  -tls
    	Connection uses TLS if true, else plain TCP
```

## client

```
$ ./client -help
Usage of ./client:
  -ca_file string
    	The file containing the CA root cert file
  -count int
    	number of request (default 1)
  -server_addr string
    	The server address in the format of host:port (default "localhost:10000")
  -server_host_override string
    	The server name use to verify the hostname returned by TLS handshake (default "x.test.youtube.com")
  -timeout int
    	read timeout in second (default 1)
  -tls
    	Connection uses TLS if true, else plain TCP
```

## docker run

```
$ docker run --rm --name grpc-helloworld yteraoka/grpc-helloworld
```

```
$ docker exec -it grpc-helloworld /client
```
