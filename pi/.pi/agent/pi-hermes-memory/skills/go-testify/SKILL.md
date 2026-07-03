---
name: "go-testify"
description: "stretchr/testify patterns for Go tests — assert vs require, mock expectations, argument matchers, suites, and common pitfalls. Use when the codebase imports github.com/stretchr/testify and you need to write or review test assertions, mocks, or suites."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing or reviewing Go tests that import github.com/stretchr/testify. Covers all four testify packages: assert (soft assertions), require (hard assertions), mock (interface mocking), and suite (test organization with setup/teardown). Not for general Go testing patterns (table-driven tests, parallel tests, fuzzing) — see go-testing skill for those.

## Procedure
1. **assert vs require**: Both offer identical assertions. `assert` records failure and continues — you see all failures at once. `require` calls `t.FailNow()` — use for preconditions where continuing would panic (nil pointers after error, missing config). Rule: `require` for guards/setup, `assert` for verifications. Use `assert.New(t)` / `require.New(t)` aliased as `is` and `must` for readability: `is.Equal(a, b)` / `must.NoError(err)`.
2. **Core Assertions**: Always keep argument order `(expected, actual)` — swapping produces backwards diffs. `is.Equal(expected, actual)` — DeepEqual + exact type. `is.EqualValues` — converts types first (int to int64). `is.NoError(err)` / `is.Error(err)`, `is.ErrorIs(err, sentinel)` — walks the chain. `is.Nil(obj)` / `is.NotNil(obj)`. `is.True(cond)` / `is.False(cond)`. `is.Empty(collection)` / `is.Len(collection, n)`. `is.Greater(a, b)` / `is.Less(a, b)`. `is.Contains(slice, item)` / `is.ElementsMatch(a, b)` for unordered comparison. `is.InDelta(a, b, eps)` for float tolerance. `is.JSONEq(json1, json2)` for JSON ignoring whitespace/key order. `is.Eventually(func() bool { ... }, timeout, interval)` for async polling.
3. **Mock Pattern**: Embed `mock.Mock` in your mock struct, implement interface methods with `m.Called(args...)`: `func (m *MockStore) Get(id int) (*User, error) { args := m.Called(id); return args.Get(0).(*User), args.Error(1) }`. Set expectations in test: `mockStore.On("Get", 42).Return(&User{Name: "alice"}, nil)`. ALWAYS verify with `mockStore.AssertExpectations(t)` at the end — without it, unmatched expectations silently pass. Use `t.Cleanup(func() { mockStore.AssertExpectations(t) })` to avoid forgetting.
4. **Argument Matchers**: `mock.Anything` — matches any argument. `mock.AnythingOfType("string")` — matches any string. `mock.MatchedBy(func(v any) bool)` — custom predicate matching. Use these when the exact value isn't important for the test scenario.
5. **Call Modifiers**: Chain after `.Return(...)`: `.Once()` — expect exactly one call. `.Times(n)` — expect n calls. `.Maybe()` — optional call (use sparingly). `.Not()` — assert NOT called at all. `.Run(func(args mock.Arguments) { ... })` — run logic when call happens (capture arguments). `.Panic(val)` — simulate panic return.
6. **Return Value Helpers**: `args.Get(0)` returns `any` — cast to concrete type. `args.String(0)` / `args.Int(0)` for typed extraction. `args.Error(0)` returns `error`. `args.Bool(0)` returns `bool`. `args.Get(n)` panics if index out of range — ensure your mock method declares the right number of return values.
7. **Suite Patterns**: Embed `suite.Suite` for shared setup: `type MySuite struct { suite.Suite; db *MockDB; svc *Service }`. Lifecycle: `SetupSuite()` once before all tests, `SetupTest()` before each test, `TearDownTest()` after each, `TearDownSuite()` once after all. Suite methods use `s.Equal()`, `s.Require().NoError()`. MUST have a launcher: `func TestMySuite(t *testing.T) { suite.Run(t, new(MySuite)) }`. Prefer table-driven subtests over suite-style for most cases — use suites primarily when `SetupTest` overhead is significant (DB setup, file fixtures).

## Pitfalls
- Forgetting `AssertExpectations(t)` — mock expectations are silently ignored if never verified. Use `t.Cleanup(func() { m.AssertExpectations(t) })` right after mock creation.
- Swapped `(expected, actual)` order in assertions — testify assumes `Equal(expected, actual)`. Swapping produces backwards diff output.
- Using `assert` for guard conditions where `nil` would cause a panic — use `require` to halt immediately.
- Missing `suite.Run(t, new(MySuite))` — without the launcher, zero suite tests execute silently.
- Comparing pointers with `is.Equal` — compares addresses. Use `.EqualExportedValues` or dereference.
- Using `is.Equal(err, ErrNotFound)` — fails on wrapped errors. Use `is.ErrorIs(err, ErrNotFound)` to walk the chain.
- Mixing mock expectations with concrete types from previous test calls — always reset mocks in `SetupTest` for fresh expectations per test.

## Verification
1. `go test ./...` passes with all mock `AssertExpectations` verified.
2. No bare `err == sentinel` comparisons in test code — uses `ErrorIs` instead.
3. All preconditions use `require` (not `assert`) — nil dereferences after failure are impossible.
4. Every mock method properly extracts return values via `args.Get(n)` with correct type assertions.
5. Suite types have a corresponding `TestXxxSuite(t *testing.T)` launcher function.