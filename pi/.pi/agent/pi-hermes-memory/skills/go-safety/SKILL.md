---
name: "go-safety"
description: "Defensive Go coding — prevent nil panics, slice aliasing, race conditions, numeric overflow, and resource leaks. Use when reviewing Go code for correctness or writing code that must be robust against common Go pitfalls."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing or reviewing Go code for correctness — nil safety, slice/map aliasing, numeric conversion safety, resource lifecycle management, zero-value design, and type assertion safety. Not for security-specific concerns (injection, crypto) or performance optimization.

## Procedure
1. **Nil Safety**: The typed nil interface trap — returning a typed nil pointer from an interface function creates `interface{type: *T, value: nil}` which is NOT `== nil`. Always return untyped `nil` for the nil case: `return nil`, not `return var h *T`. Writing to a nil map panics — always initialize with `make()` or lazy-init in methods. Indexing a nil slice panics. Ranging over nil map/slice/channel is safe (0 iterations). Use safe type assertions: `v, ok := x.(T)` — never bare `x.(T)`.
2. **Slice & Map Aliasing**: `append` reuses the backing array if capacity allows — both slices then share memory and silently corrupt each other. To force a copy on append: `s[:len(s):len(s)]` (full slice expression). Return defensive copies from exported functions: `return slices.Clone(c.hosts)` instead of `return c.hosts`. Never return internal slice/map references — callers can mutate your internals.
3. **Numeric Safety**: Integer conversions truncate silently — `int64(3_000_000_000)` cast to `int32` wraps to `-1294967296`. Always check bounds against `math.MaxInt32`/`math.MinInt32` before converting. Integer division by zero panics — always guard. Float comparison with `==` is unreliable — use `math.Abs(a-b) < epsilon`.
4. **Resource Safety**: `defer` runs at function exit, not loop iteration. Extract loop body with `defer` to a separate function, or resources accumulate until return. Always `defer rows.Close()` immediately after `db.QueryContext()`. Use `os.Root` (Go 1.24+) for user-supplied file paths to prevent traversal.
5. **Zero-Value Design**: Design types so `var x MyType` is safe and usable. Nil map fields in structs panic on first write — use lazy init with `sync.Once`. `sync.Mutex` and `bytes.Buffer` are safe at zero value. Enum iota should start at 1 or use an Unknown sentinel at 0 — var zero value silently becomes the first enum member.
6. **Concurrent Safety**: Maps MUST NOT be accessed concurrently without synchronization — concurrent write+read causes a hard crash. Use `sync.Map` for read-heavy patterns, `sync.Mutex`+map for write-heavy. Use `-race` always in CI. Use `go.uber.org/goleak` to detect goroutine leaks.

## Pitfalls
- Bare type assertion `x.(T)` panics on type mismatch — always use comma-ok form.
- Writing to a nil map panics — never `var m map[K]V; m[k] = v`.
- Comparing `err == io.EOF` instead of `errors.Is(err, io.EOF)` — fails if err is wrapped.
- Returning internal slice reference — callers can mutate your backing array.
- Using `any` when generics will do — loses compile-time type safety.
- Defer inside a loop — defers accumulate until function returns, not per iteration.
- Assuming `append` always allocates — it reuses backing array silently when capacity permits.

## Verification
1. `go vet ./...` catches nil pointer derefs, unreachable code.
2. No bare type assertions (`x.(T)`) in the codebase — all use comma-ok form.
3. All exported functions returning slices use `slices.Clone` or full-slice expressions.
4. No `defer` inside loops — extracted to helper functions.
5. `go test -race ./...` passes.