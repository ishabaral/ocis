package runner

import (
	"context"
)

// GroupRunner represent a group of tasks that need to run together.
// The expectation is that all the tasks will run at the same time, and when
// one of them stops, the rest will also stop.
//
// The GroupRunner is intended to be used to run multiple services, which are
// more or less independent from eachother, but at the same time it doesn't
// make sense to have any of them stopped while the rest are running.
// Basically, either all of them run, or none of them.
// For example, you can have a GRPC and HTTP servers running, each of them
// providing a piece of functionality, however, if any of them fails, the
// feature provided by them would be incomplete or broken.
//
// Note that, as services, the task aren't expected to stop by default.
// This means that, if a task finishes naturally, the rest of the task will
// asked to stop as well.
type GroupRunner struct {
	runners map[string]*Runner
}

// NewGroup will create a GroupRunner
func NewGroup() *GroupRunner {
	return &GroupRunner{
		runners: make(map[string]*Runner),
	}
}

// Add will add a runner to the group.
//
// It's mandatory that each runner in the group has an unique id, otherwise
// there will be issues
func (gr *GroupRunner) Add(r *Runner) {
	if _, ok := gr.runners[r.ID]; ok {
		// a runner already exist with that id
		panic("Trying to add a runner with an existing Id in the group")
	}
	gr.runners[r.ID] = r
}

// Run will execute all the tasks in the group at the same time.
//
// Similarly to the "regular" runner's `Run` method, the execution thread
// will be blocked here until all tasks are completed, and their results
// will be available (each result will have the runner's id so it's easy to
// find which one failed). Note that there is no guarantee about the result's
// order, so the first result in the slice might or might not be the first
// result to be obtained.
//
// When the context is marked as done, the groupRunner will call all the
// stoppers for each runner to notify each task to stop. Note that the tasks
// might still take a while to complete.
//
// If a task finishes naturally (with the context still "alive"), it will also
// cause the groupRunner to call the stoppers of the rest of the tasks. So if
// a task finishes, the rest will also finish.
// Note that it is NOT expected for the finished task's stopper to be called
// in this case.
func (gr *GroupRunner) Run(ctx context.Context) []*Result {
	results := make(map[string]*Result)

	ch := make(chan *Result, len(gr.runners)) // no need to block writing results
	for _, runner := range gr.runners {
		runner.RunAsync(ch)
	}

	// wait for a result or for the context to be done
	select {
	case result := <-ch:
		results[result.RunnerID] = result
	case <-ctx.Done():
		// Do nothing
	}

	// interrupt the rest of the runners
	for _, runner := range gr.runners {
		if _, ok := results[runner.ID]; !ok {
			// there might still be race conditions because the result might not have
			// been made available even though the runner has finished. We assume
			// that calling the `Interrupt` method multiple times and / or calling
			// the `Interrupt` method when the task has finished is safe
			runner.Interrupt()
		}
	}

	// Having notified that the context has been finished, we still need to
	// wait for the rest of the results
	for i := len(results); i < len(gr.runners); i++ {
		result := <-ch
		results[result.RunnerID] = result
	}

	close(ch)

	values := make([]*Result, 0, len(gr.runners))
	for _, val := range results {
		values = append(values, val)
	}
	return values
}

// RunAsync will execute the tasks in the group asynchronously.
// The result of each task will be placed in the provided channel as soon
// as it's available.
// Note that this method will finish as soon as all the tasks are running.
func (gr *GroupRunner) RunAsync(ch chan<- *Result) {
	for _, runner := range gr.runners {
		runner.RunAsync(ch)
	}
}

// Interrupt will execute the stopper function of ALL the tasks, which should
// notify the tasks in order for them to finish.
// The stoppers will be called immediately but sequentially. This means that
// the second stopper won't be called until the first one has returned. This
// usually isn't a problem because the service `Stop`'s methods either don't
// take a long time to return, or they run asynchronously in another goroutine.
//
// As said, this will affect ALL the tasks in the group. It isn't possible to
// try to stop just one task.
func (gr *GroupRunner) Interrupt() {
	for _, runner := range gr.runners {
		runner.Interrupt()
	}
}
