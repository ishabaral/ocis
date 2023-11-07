package identity

import (
	"context"
	"time"

	gateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	cs3Group "github.com/cs3org/go-cs3apis/cs3/identity/group/v1beta1"
	cs3User "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	rpc "github.com/cs3org/go-cs3apis/cs3/rpc/v1beta1"
	"github.com/cs3org/reva/v2/pkg/rgrpc/todo/pool"
	revautils "github.com/cs3org/reva/v2/pkg/utils"
	"github.com/jellydator/ttlcache/v3"
	libregraph "github.com/owncloud/libre-graph-api-go"
	"github.com/owncloud/ocis/v2/services/graph/pkg/service/v0/errorcode"
)

// IdentityCache implements a simple ttl based cache for looking up users and groups by ID
type IdentityCache struct {
	users           *ttlcache.Cache[string, libregraph.User]
	groups          *ttlcache.Cache[string, libregraph.Group]
	gatewaySelector pool.Selectable[gateway.GatewayAPIClient]
}

type identityCacheOptions struct {
	gatewaySelector pool.Selectable[gateway.GatewayAPIClient]
	usersTTL        time.Duration
	groupsTTL       time.Duration
}

// IdentityCacheOptiondefines a single option function.
type IdentityCacheOption func(o *identityCacheOptions)

// IdentityCacheWithGatewaySelector set the gatewaySelector for the Identity Cache
func IdentityCacheWithGatewaySelector(gatewaySelector pool.Selectable[gateway.GatewayAPIClient]) IdentityCacheOption {
	return func(o *identityCacheOptions) {
		o.gatewaySelector = gatewaySelector
	}
}

// IdentityCacheWithUsersTTL sets the TTL for the users cache
func IdentityCacheWithUsersTTL(ttl time.Duration) IdentityCacheOption {
	return func(o *identityCacheOptions) {
		o.usersTTL = ttl
	}
}

// IdentityCacheWithGroupsTTL sets the TTL for the groups cache
func IdentityCacheWithGroupsTTL(ttl time.Duration) IdentityCacheOption {
	return func(o *identityCacheOptions) {
		o.groupsTTL = ttl
	}
}

func newOptions(opts ...IdentityCacheOption) identityCacheOptions {
	opt := identityCacheOptions{}
	for _, o := range opts {
		o(&opt)
	}
	return opt
}

// NewIdentityCache instanciates a new IdentityCache and sets the supplied options
func NewIdentityCache(opts ...IdentityCacheOption) IdentityCache {
	opt := newOptions(opts...)

	var cache IdentityCache

	cache.users = ttlcache.New(
		ttlcache.WithTTL[string, libregraph.User](opt.usersTTL),
		ttlcache.WithDisableTouchOnHit[string, libregraph.User](),
	)
	go cache.users.Start()

	cache.groups = ttlcache.New(
		ttlcache.WithTTL[string, libregraph.Group](opt.groupsTTL),
		ttlcache.WithDisableTouchOnHit[string, libregraph.Group](),
	)
	go cache.groups.Start()

	cache.gatewaySelector = opt.gatewaySelector

	return cache
}

// GetUser looks up a user by id, if the user is not cached yet it will do a lookup via the CS3 API
func (cache IdentityCache) GetUser(ctx context.Context, userid string) (libregraph.User, error) {
	var user libregraph.User
	if item := cache.users.Get(userid); item == nil {
		gatewayClient, err := cache.gatewaySelector.Next()
		cs3UserID := &cs3User.UserId{
			OpaqueId: userid,
		}
		cs3User, err := revautils.GetUser(cs3UserID, gatewayClient)
		if err != nil {
			if revautils.IsErrNotFound(err) {
				return libregraph.User{}, ErrNotFound
			}
			return libregraph.User{}, errorcode.New(errorcode.GeneralException, err.Error())
		}
		user = *CreateUserModelFromCS3(cs3User)
		cache.users.Set(userid, user, ttlcache.DefaultTTL)

	} else {
		user = item.Value()
	}
	return user, nil
}

// GetUser looks up a group by id, if the group is not cached yet it will do a lookup via the CS3 API
func (cache IdentityCache) GetGroup(ctx context.Context, groupid string) (libregraph.Group, error) {
	var group libregraph.Group
	if item := cache.groups.Get(groupid); item == nil {
		gatewayClient, err := cache.gatewaySelector.Next()
		cs3GroupID := &cs3Group.GroupId{
			OpaqueId: groupid,
		}
		req := cs3Group.GetGroupRequest{
			GroupId: cs3GroupID,
		}
		res, err := gatewayClient.GetGroup(ctx, &req)
		if err != nil {
			return group, errorcode.New(errorcode.GeneralException, err.Error())
		}
		switch res.Status.Code {
		case rpc.Code_CODE_OK:
			cs3Group := res.GetGroup()
			group = *CreateGroupModelFromCS3(cs3Group)
			cache.groups.Set(groupid, group, ttlcache.DefaultTTL)
		case rpc.Code_CODE_NOT_FOUND:
			return group, ErrNotFound
		default:
			return group, errorcode.New(errorcode.GeneralException, res.Status.Message)
		}
	} else {
		group = item.Value()
	}
	return group, nil
}
