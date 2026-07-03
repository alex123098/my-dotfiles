---
name: "go-style"
description: "Go code style, naming conventions, struct/interface design, and project layout. Use when writing or reviewing Go code to ensure idiomatic formatting, naming, type design, and directory organization."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing, reviewing, or refactoring Go code. Covers formatting conventions, identifier naming (MixedCaps, acronyms, stutter avoidance), struct/interface design (small interfaces, composition, "accept interfaces return structs"), and project layout (cmd/, internal/, pkg/ conventions). Not for error handling patterns or concurrency design.

## Procedure
1. **Naming**: Use MixedCaps (not snake_case, not ALL_CAPS). Package names are lowercase, singular, no stutter (`http.Client` not `http.HTTPClient`). Exported = UpperCamelCase, unexported = lowerCamelCase. Acronyms: all caps or all lower (`HTTPServer`, `urlParser`). Boolean fields use `is`/`has`/`can` prefix (`isReady`), getters keep the prefix (`IsReady()`). Error vars: `Err` prefix. Error types: `Error` suffix. Constructors: `New()` for single-type packages, `NewTypeName()` for multi-type. Enum iota 0 = Unknown sentinel. Error strings: fully lowercase including acronyms, no trailing punctuation.
2. **Code Style**: No rigid line limit, break at ~120+ at semantic boundaries. Function calls with 4+ args use one-per-line. Use `:=` for non-zero values, `var` for zero-value init. Always initialize slices and maps (never nil). Use early return for errors/edge cases — keep happy path flat. Drop `else` when `if` body has return/break/continue. Extract complex conditions into named booleans. Prefer `switch` over long if-else chains. Functions should be short, focused, ≤4 params — use options struct beyond that. Parameter order: ctx first, inputs, output destinations.
3. **Struct/Interface Design**: Keep interfaces small (1-3 methods). Compose small interfaces into larger ones via embedding. 'Accept interfaces, return structs' — consumers define interfaces where they need them. Prefer pointer receivers for methods that mutate and when nil is meaningful; value receivers for small, immutable types. Use field names in composite literals ([`srv := &http.Server{Addr: ":8080"}`]). Implement compile-time interface checks with `var _ Interface = (*Type)(nil)`.
4. **Project Layout**: All `main` packages in `cmd/{name}` with minimal logic (parse flags, wire, call `Run()`). Business logic in `internal/` (private) or `pkg/` (only if external consumers). Flat structure for small projects; layers only when justified. Follow 12-Factor App for services: config via env vars, logs to stdout, stateless processes. Module name matches repo URL (`github.com/user/repo`), lowercase with hyphens.

## Pitfalls
- Don't stutter — package name is already at call site (`json.Decoder` not `json.JSONDecoder`).
- Don't use `Get` prefix on getters (`user.Name()` not `user.GetName()`).
- Don't use plural package names (`url` not `urls`).
- Don't over-structure small projects — a 100-line CLI doesn't need layers.
- Don't store context in structs — pass explicitly as first parameter.

## Verification
1. Running `gofmt -s -w .` passes cleanly.
2. `go vet ./...` produces no output.
3. All exported names are intentionally exported (not accidental via UpperCamelCase).
4. Package names are singular and lowercased.
5. No `Get` prefix on getter methods.