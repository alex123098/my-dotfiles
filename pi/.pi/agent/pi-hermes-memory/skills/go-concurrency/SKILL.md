---
name: "go-concurrency"
description: "Go concurrency patterns — goroutines, channels, sync primitives, errgroup, pipelines. Use when writing or reviewing concurrent Go code involving goroutines, channels, select, locks, worker pools, or fan-out/fan-in patterns."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing concurrent Go code: spawning goroutines, creating channels, using sync primitives (Mutex, RWMutex, WaitGroup, Once, atomic), setting up errgroup groups, implementing worker pools or pipelines, or debugging goroutine leaks, races, or deadlocks.

## Procedure
1. **Goroutine Discipline**: Every goroutine must have a clear exit path — without a shutdown mechanism, they leak. Before spawning: (1) How will it exit? (2) Can I signal it to stop? (3) How do I wait for it? (4) Who owns the channels? (5) Could this be synchronous instead? Use context cancellation or done channels for signaling. Track leaks with `go.uber.org/goleak.VerifyTestMain(m)`.
2. **Channels**: Owner = sender creates and closes. Only the sender closes a channel. Specify direction (`chan<-` send-only, `<-chan` receive-only) — compiler prevents misuse. Default to unbuffered channels — larger buffers mask backpressure. Always include `ctx.Done()` in select to allow cancellation. Avoid repeated `time.After` in hot loops — allocate once and reuse. Send values (copies), not pointers — sending pointers creates invisible shared memory.
3. **Channel vs Mutex vs Atomic**: Channels = passing data between goroutines, coordinating lifecycle. Mutex/RWMutex = protecting shared struct fields. `sync/atomic` = simple counters, flags (prefer typed atomics: `atomic.Int64`, `atomic.Bool` since Go 1.19). `sync.Map` = read-heavy concurrent map access (otherwise use RWMutex+map).
4. **WaitGroup vs errgroup**: `sync.WaitGroup` = fire-and-forget, no errors. `errgroup.Group` = collect first error. `errgroup.WithContext` = cancel siblings on first error. `errgroup.SetLimit(n)` = built-in worker pool with bounded concurrency. Go 1.25+: `wg.Go(func(){...})` for simple fire-and-wait.
5. **Common Sync Primitives**: `sync.Once` / `OnceFunc` / `OnceValue` = one-time init. `singleflight.Group` = deduplicate concurrent calls (cache stampede prevention). `sync.Pool` = reuse temporary objects (always `Reset()` before `Put()`). Keep mutex critical sections short — never hold across I/O. Never upgrade RLock to Lock (deadlock).
6. **Pipelines & Worker Pools**: Fan-out multiple goroutines to process data, fan-in a results channel. Use errgroup with SetLimit for bounded worker pools. Use Go 1.23+ iterators for lazy evaluation. Always check context cancellation between pipeline stages. For graceful shutdown patterns, signal completion via context or done channel.

## Pitfalls
- Fire-and-forget goroutines without stop mechanism — they leak until process restart.
- Calling `wg.Add()` inside the goroutine instead of before `go func()` — `Wait()` may return early.
- Closing a channel from the receiver panics if the sender writes after close.
- Missing `ctx.Done()` in select — goroutine won't respond to cancellation.
- Unbounded goroutine spawning — use `errgroup.SetLimit(n)` or a semaphore.
- Sharing pointers via channels — defeats channel's purpose of communicating ownership.
- Mutex held across I/O operations — blocks other goroutines for no reason.
- Not running `-race` in CI — most races don't crash in dev but cause data corruption in production.

## Verification
1. `go test -race ./...` passes cleanly — no race conditions.
2. `goleak.VerifyTestMain(m)` passes — no goroutine leaks.
3. Every `go func()` has a corresponding `sync.WaitGroup` or `errgroup` tracking.
4. No `time.After` in hot loops — uses `time.NewTimer` + `Reset`.
5. All `select` statements include `ctx.Done()`.