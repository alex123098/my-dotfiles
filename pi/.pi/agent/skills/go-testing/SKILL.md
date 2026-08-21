---
name: "go-testing"
description: "Go testing best practices — table-driven tests, testify, benchmarks, fuzzing, parallel tests, goroutine leak detection. Use when writing, reviewing, or debugging Go tests, or setting up test infrastructure."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---

## Procedure
1. **Table-Driven Tests**: Always use named subtests with `t.Run`. Each test case must have a `name` field. Use descriptive lowercase phrases for subtest names (`"valid id"`, `"empty input"`). Loop with `for _, tt := range tests { t.Run(tt.name, func(t *testing.T) { ... }) }`. Use `got`/`want` naming for results and expectations. Use `t.Errorf` for non-fatal assertions, `t.Fatalf` for setup failures.
2. **testify Usage**: Use `assert` for non-fatal checks (`assert.Equal(t, want, got)`), `require` for fatal checks (`require.NoError(t, err)`). Use `assert.New(t)` / `require.New(t)` for assertion object to reduce verbosity. Mock interfaces with `testify/mock` — mock interfaces, not concrete types. Use `suite` sparingly — prefer table-driven with subtests over suite-based organization.
3. **Parallel Tests**: Independent tests SHOULD use `t.Parallel()`. For table-driven parallel tests, add `t.Parallel()` inside `t.Run` callback. Integration tests MUST use build tags (`//go:build integration`) to separate from unit tests. Use `testdata/` for test fixtures. Use `t.Context()` (Go 1.24+) for test contexts.
4. **Benchmarks**: Use `b.Loop()` (Go 1.24+) for clean iteration: `for b.Loop() { ... }`. For older Go, use the traditional `for n := 0; n < b.N; n++` pattern. Always report allocations with `b.ReportAllocs()`. Use sub-benchmarks for different input sizes: `b.Run("n=100", func(b *testing.B) { ... })`. Compare with `benchstat` — collect `-count=6` for statistical significance.
5. **Fuzzing**: Write fuzz targets for functions that parse untrusted input. Seed corpus with representative inputs via `f.Add()`. Fuzz function takes `*testing.F` and the target types: `f.Fuzz(func(t *testing.T, input string) { ... })`. Run with `go test -fuzz=FuzzName ./...`.
6. **Goroutine Leak Detection**: Add `goleak.VerifyTestMain(m)` in TestMain for packages with goroutines. Use per-test `defer goleak.VerifyNone(t)` for targeted checks. In Go 1.25+, use `testing/synctest` for deterministic goroutine testing with synthetic time.
7. **Test Quality Rules**: Tests MUST NOT depend on execution order. NEVER test implementation details — test observable behavior. Keep unit tests fast (<1ms). Run with race detection: `go test -race ./...`. Use Example functions as executable documentation (`// Output: ...`).

## Pitfalls
- Missing `t.Parallel()` inside `t.Run` callback (not on the outer test) for parallel subtests — all subtests still run sequentially.
- Not calling `t.Run` for table-driven cases — errors show line numbers instead of case names.
- Mixing unit and integration tests without build tags — slows down `go test ./...`.
- Benchmarks without `b.ReportAllocs` — allocation differences are invisible.
- Using `suite` for everything — table-driven subtests are more idiomatic and composable.
- Comparing floats directly — use `assert.InDelta` or epsilon comparison.

## Verification
1. `go test -race ./...` passes cleanly.
2. `go test -bench=. -benchmem ./...` produces benchmark numbers.
3. `go vet ./...` passes — catches context cancellation, unreachable code.
4. No `go test` output shows 'no test files' when there should be tests.
5. Integration tests only run with `-tags=integration` flag.