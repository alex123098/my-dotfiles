---
name: "go-modernize"
description: "Go code modernization — replace outdated patterns with current Go idioms (Go 1.21-1.26). Use when upgrading Go versions, modernizing legacy code patterns, or adopting new standard library features."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---

## Procedure
1. **Check go.mod Version**: Read the `go` directive in `go.mod` to determine the current target. Reference the relevant Go release notes for features available at that version. The latest stable versions and their changelogs: Go 1.21 (Aug 2023, go.dev/doc/go1.21), Go 1.22 (Feb 2024), Go 1.23 (Aug 2024), Go 1.24 (Feb 2025), Go 1.25 (Aug 2025), Go 1.26 (Feb 2026, go.dev/doc/go1.26).
2. **High Priority (Safety/Correctness)**: (1) Remove loop variable shadow copies — Go 1.22+ loop variables have per-iteration scope. (2) Replace `math/rand` with `math/rand/v2` — deprecate `rand.Seed` (Go 1.22+). (3) Use `os.Root` for user-supplied file paths — prevents path traversal (Go 1.24+). (4) Use `errors.Is`/`errors.As` instead of direct error comparison (Go 1.13+). (5) Migrate deprecated crypto: `crypto/sha3` for SHA-3, `crypto/hkdf` for HKDF, `crypto/pbkdf2` for PBKDF2 (all Go 1.24+).
3. **Medium Priority (Readability/Maintainability)**: (1) Replace `interface{}` with `any` (Go 1.18+). (2) Use `min`/`max` builtins (Go 1.21+). (3) Use `slices` and `maps` standard packages instead of handwritten helpers (Go 1.21+). (4) Use `cmp.Or` for default values (Go 1.22+). (5) Use `range` over int — `for i := range n` (Go 1.22+). (6) Use `sync.OnceValue`/`sync.OnceFunc` for lazy initialization (Go 1.21+).
4. **Testing Modernization**: (1) Use `t.Context()` in tests instead of `context.Background()` (Go 1.24+). (2) Use `b.Loop()` instead of manual `b.N` loops in benchmarks (Go 1.24+). (3) Use `testing/synctest` (Go 1.25+) for deterministic goroutine testing — the API is `synctest.Test(t, func(t *testing.T) { ... })`, not the old experimental `synctest.Run`. (4) Use `t.ArtifactDir()` for persisting test artifacts (Go 1.26+).
5. **Tooling Modernization**: (1) Move tool dependencies to `go.mod` tool directives (Go 1.24+). (2) Enable PGO for production builds (Go 1.21+ — just place a `default.pgo` file). (3) Replace `sort.Slice` with `slices.SortFunc` (Go 1.21+). (4) Use `strings.SplitSeq` and iterator variants (Go 1.24+). (5) Replace `reflect.PtrTo` with `reflect.PointerTo` (Go 1.22+). (6) Replace `runtime.SetFinalizer` with `runtime.AddCleanup` (Go 1.24+).
6. **Migration Priority**: Always prioritize safety/correctness changes (loop var, crypto, math/rand) over readability improvements (any, min/max). Run `go mod tidy` and the full test suite after any dependency change. Encourage Go version bumps — each new version brings compiler optimizations, security fixes, and tooling improvements.

## Pitfalls
- Don't suggest a migration to `encoding/json/v2` unless the project explicitly opts into `GOEXPERIMENT=jsonv2` — it remains experimental in Go 1.25+.
- Don't replace `http.Handler` with `http.HandlerFunc` — they serve different purposes.
- Don't refactor unrelated code during a version upgrade — change only what the version change requires.
- Don't use `synctest.Run` in Go 1.25+ — the API is now `synctest.Test`.
- Don't upgrade `go.mod` minor version without testing — some features may not be safe to adopt everywhere.
- Don't re-suggest modernizations the developer explicitly ignored — create a `.modernize` file tracking ignored suggestions.

## Verification
1. `go vet ./...` passes — catches new language feature misuses.
2. `go mod tidy` completes without errors.
3. Full test suite passes after modernization changes.
4. No deprecation warnings from `go build` or `go vet`.
5. `golangci-lint run` (with `modernize` linter if available) reports no fixable patterns.