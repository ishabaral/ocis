package runner

import (
	"time"
)

var (
	// DefaultInterruptDuration is the default value for the `WithInterruptDuration`
	// This global value can be adjusted if needed.
	DefaultInterruptDuration = 10 * time.Second
)

// Option defines a single option function.
type Option func(o *Options)

// Options defines the available options for this package.
type Options struct {
	InterruptDuration time.Duration
}

// WithInterruptDuration provides a function to set the interrupt
// duration option.
func WithInterruptDuration(val time.Duration) Option {
	return func(o *Options) {
		o.InterruptDuration = val
	}
}
