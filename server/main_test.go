package main

import (
	"context"
	"net"
	"testing"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	pb "google.golang.org/grpc/examples/helloworld/helloworld"
	"google.golang.org/grpc/test/bufconn"
)

func newTestClient(t *testing.T) pb.GreeterClient {
	t.Helper()
	lis := bufconn.Listen(1024 * 1024)
	t.Cleanup(func() { lis.Close() })

	srv := grpc.NewServer()
	pb.RegisterGreeterServer(srv, &server{})
	go srv.Serve(lis) //nolint:errcheck
	t.Cleanup(srv.Stop)

	conn, err := grpc.NewClient(
		"passthrough:///bufnet",
		grpc.WithContextDialer(func(ctx context.Context, _ string) (net.Conn, error) {
			return lis.DialContext(ctx)
		}),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("failed to create client: %v", err)
	}
	t.Cleanup(func() { conn.Close() })
	return pb.NewGreeterClient(conn)
}

func TestSayHello(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  string
	}{
		{"simple name", "world", "Hello world"},
		{"empty name", "", "Hello "},
		{"japanese", "テスト", "Hello テスト"},
	}

	client := newTestClient(t)

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			resp, err := client.SayHello(context.Background(), &pb.HelloRequest{Name: tt.input})
			if err != nil {
				t.Fatalf("SayHello(%q): %v", tt.input, err)
			}
			if resp.Message != tt.want {
				t.Errorf("got %q, want %q", resp.Message, tt.want)
			}
		})
	}
}

func TestSayHelloDirect(t *testing.T) {
	s := &server{}
	resp, err := s.SayHello(context.Background(), &pb.HelloRequest{Name: "Alice"})
	if err != nil {
		t.Fatalf("SayHello: %v", err)
	}
	if resp.Message != "Hello Alice" {
		t.Errorf("got %q, want %q", resp.Message, "Hello Alice")
	}
}
