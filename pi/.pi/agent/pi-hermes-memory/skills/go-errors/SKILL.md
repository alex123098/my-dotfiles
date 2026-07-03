---
name: "go-errors"
description: "Go error handling and context.Context propagation. Use when creating, wrapping, inspecting, or logging errors, and when propagating context across API boundaries, timeouts, or cancellation."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing error handling code, debugging error flows, setting up context propagation, or designing cancellation/timeout patterns. Covers error creation (sentinel errors, custom types), wrapping with %w, inspection with errors.Is/As/AsType, the single handling rule, structured error logging, and context.Context propagation through API boundaries.

## Procedure
1. **Error Creation**: Use `errors.New` for static messages, `fmt.Errorf` for dynamic. Error strings MUST be lowercase, no trailing punctuation, no prescribed action. Use sentinel errors (`var ErrNotFound = errors.New("pkg: not found")`) for expected conditions. Use custom error types for carrying structured data. Preallocate sentinels at package level — never inline `errors.New` in functions called repeatedly.
2. **Error Wrapping**: Wrap errors with context using `fmt.Errorf("context: %w", err)` — use `%w` internally to preserve chain, `%v` at system boundaries to hide internals. Use `errors.Join` (Go 1.20+) to combine independent errors. NEVER use `fmt.Errorf("%v", err)` or string concatenation — those break the error chain.
3. **Error Inspection**: Use `errors.Is(err, sentinel)` for sentinel matching. Use `errors.As(err, &target)` for typed chain inspection (Go <1.26). Use `errors.AsType[T](err)` (Go 1.26+) for type-safe chain inspection. NEVER use direct comparison (`err == ErrNotFound`) or bare type assertions for errors that may be wrapped.
4. **Single Handling Rule**: Errors are EITHER logged OR returned — NEVER both. Log-and-return creates duplicate log lines and makes aggregators unreliable. Log at the top-level handler; return with wrapping context from lower layers. Always check returned errors — never discard with `_`.
5. **Context Propagation**: `context.Context` is Go's mechanism for cancellation, deadlines, and request-scoped values. ctx MUST be the first parameter named `ctx`. NEVER store context in a struct — pass explicitly. NEVER pass nil — use `context.TODO()` if unsure. Propagate the same ctx through the entire call chain. `cancel()` must be called on all control-flow paths for `WithCancel`/`WithTimeout`/`WithDeadline`. `context.Background()` only at top-level (main, init, tests). Use `context.WithoutCancel` (Go 1.21+) for background work that outlives the parent.
6. **Structured Error Logging**: Use `log/slog` (Go 1.21+) — not `fmt.Println` or `log.Printf`. Use `slog.ErrorContext(ctx, "msg", "err", err)` to correlate with traces. Log with context variants (`slog.InfoContext`). Use log levels appropriately: Debug for dev, Info for normal, Warn for degraded, Error for failures needing attention. Never expose technical errors to users — translate to user-friendly messages, log technical details server-side.

## Pitfalls
- Returning a typed nil pointer in an interface creates a non-nil interface (`var h *MyHandler; return h` yields `interface{type: *MyHandler, value: nil}` which is != nil). Return untyped `nil` for the nil case.
- Using `%v` instead of `%w` when wrapping breaks `errors.Is`/`errors.As` chain inspection.
- Calling `cancel()` at every return path is essential — if multiple goroutines share the ctx, one cancel leaks the rest.
- Creating new `context.Background()` in the middle of a request path breaks the cancellation chain.
- Using `context.Value` for function parameters — context values are for request-scoped metadata only (request ID, user ID). Keys must be unexported types to prevent collisions.

## Verification
1. `go vet ./...` catches unused results, canceled context not used.
2. No `fmt.Println` or `log.Printf` in production code paths — all logging uses `slog`.
3. No `if err != nil { return err }` without adding context via `fmt.Errorf`.
4. Every `context.WithCancel/WithTimeout/WithDeadline` has a matching `cancel()` call on all paths.