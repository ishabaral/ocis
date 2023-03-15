package backend

import (
	"context"
	"errors"

	gateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	cs3 "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	"google.golang.org/grpc"
)

var (
	// ErrAccountNotFound account not found
	ErrAccountNotFound = errors.New("user not found")
	// ErrAccountDisabled account disabled
	ErrAccountDisabled = errors.New("account disabled")
	// ErrNotSupported operation not supported by user-backend
	ErrNotSupported = errors.New("operation not supported")
)

//go:generate mockery --name=UserBackend

// UserBackend allows the proxy to retrieve users from different user-backends (accounts-service, CS3)
type UserBackend interface {
	GetUserByClaims(ctx context.Context, claim, value string) (*cs3.User, string, error)
	Authenticate(ctx context.Context, username string, password string) (*cs3.User, string, error)
	CreateUserFromClaims(ctx context.Context, claims map[string]interface{}) (*cs3.User, error)
}

// RevaAuthenticator helper interface to mock auth-method from reva gateway-client.
type RevaAuthenticator interface {
	Authenticate(ctx context.Context, in *gateway.AuthenticateRequest, opts ...grpc.CallOption) (*gateway.AuthenticateResponse, error)
}
