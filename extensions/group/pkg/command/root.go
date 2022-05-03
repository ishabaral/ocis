package command

import (
	"context"
	"os"

	"github.com/owncloud/ocis/extensions/group/pkg/config"
	"github.com/owncloud/ocis/ocis-pkg/clihelper"
	ociscfg "github.com/owncloud/ocis/ocis-pkg/config"
	"github.com/thejerf/suture/v4"
	"github.com/urfave/cli/v2"
)

// GetCommands provides all commands for this service
func GetCommands(cfg *config.Config) cli.Commands {
	return []*cli.Command{
		// start this service
		Server(cfg),

		// interaction with this service

		// infos about this service
		Health(cfg),
		Version(cfg),
	}
}

// Execute is the entry point for the ocis-group command.
func Execute(cfg *config.Config) error {
	app := clihelper.DefaultApp(&cli.App{
		Name:     "ocis-group",
		Usage:    "Provide groups for oCIS",
		Commands: GetCommands(cfg),
	})

	cli.HelpFlag = &cli.BoolFlag{
		Name:  "help,h",
		Usage: "Show the help",
	}

	return app.Run(os.Args)
}

// SutureService allows for the group command to be embedded and supervised by a suture supervisor tree.
type SutureService struct {
	cfg *config.Config
}

// NewSutureService creates a new group.SutureService
func NewSutureService(cfg *ociscfg.Config) suture.Service {
	cfg.Group.Commons = cfg.Commons
	return SutureService{
		cfg: cfg.Group,
	}
}

func (s SutureService) Serve(ctx context.Context) error {
	s.cfg.Context = ctx
	if err := Execute(s.cfg); err != nil {
		return err
	}

	return nil
}
