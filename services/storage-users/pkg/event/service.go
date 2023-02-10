package event

import (
	"time"

	apiGateway "github.com/cs3org/go-cs3apis/cs3/gateway/v1beta1"
	apiUser "github.com/cs3org/go-cs3apis/cs3/identity/user/v1beta1"
	"github.com/cs3org/reva/v2/pkg/events"
	"github.com/owncloud/ocis/v2/ocis-pkg/log"
	"github.com/owncloud/ocis/v2/services/storage-users/pkg/config"
	"github.com/owncloud/ocis/v2/services/storage-users/pkg/task"
)

const (
	consumerGroup = "storage-users"
)

// Service wraps all common logic that is needed to react to incoming events.
type Service struct {
	gatewayClient apiGateway.GatewayAPIClient
	eventStream   events.Stream
	logger        log.Logger
	config        config.Config
}

// NewService prepares and returns a Service implementation.
func NewService(gatewayClient apiGateway.GatewayAPIClient, eventStream events.Stream, logger log.Logger, conf config.Config) (Service, error) {
	svc := Service{
		gatewayClient: gatewayClient,
		eventStream:   eventStream,
		logger:        logger,
		config:        conf,
	}

	return svc, nil
}

// Run to fulfil Runner interface
func (s Service) Run() error {
	ch, err := events.Consume(s.eventStream, consumerGroup, PurgeTrashBin{})
	if err != nil {
		return err
	}

	for e := range ch {
		var errs []error

		switch ev := e.(type) {
		case PurgeTrashBin:
			executionTime := ev.ExecutionTime
			if executionTime.IsZero() {
				executionTime = time.Now()
			}

			executantID := ev.ExecutantID
			if executantID == nil {
				executantID = &apiUser.UserId{OpaqueId: s.config.Tasks.PurgeTrashBin.UserID}
			}

			tasks := map[task.SpaceType]time.Time{
				task.Project:  executionTime.Add(-s.config.Tasks.PurgeTrashBin.ProjectDeleteBefore),
				task.Personal: executionTime.Add(-s.config.Tasks.PurgeTrashBin.PersonalDeleteBefore),
			}

			for spaceType, deleteBefore := range tasks {
				// skip task execution if the deleteBefore time is the same as the now time,
				// which indicates that the duration configuration for this space type is set to 0 which is the equivalent to disabled.
				if deleteBefore.Equal(executionTime) {
					continue
				}

				if err = task.PurgeTrashBin(executantID, deleteBefore, spaceType, s.gatewayClient, s.config.Commons.MachineAuthAPIKey); err != nil {
					errs = append(errs, err)
				}
			}

		}

		for _, err := range errs {
			s.logger.Error().Err(err).Interface("event", e)
		}
	}

	return nil
}