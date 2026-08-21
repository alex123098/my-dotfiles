---
name: "go-observability"
description: "Go production observability — structured logging with slog, Prometheus metrics, OpenTelemetry tracing, pprof profiling. Use when instrumenting Go services for production monitoring, adding metrics or tracing, or debugging production issues."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---

## Procedure
1. **Structured Logging (slog)**: Use `log/slog` (Go 1.21+) — never `fmt.Println` or `log.Printf` in production. Set up JSON handler: `slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))`. Always use context variants: `slog.InfoContext(ctx, "msg", "key", val)` to correlate with traces. Use log levels: Debug=dev, Info=normal operations, Warn=degraded state, Error=failure needing attention. Replace `zap`/`logrus`/`zerolog` with slog — use bridge handlers during migration (e.g., samber/slog-zap).
2. **Prometheus Metrics**: Four metric types: Counter (rate of events, always increases), Gauge (snapshot values, can go up/down), Histogram (latency, size distributions — PREFER over Summary), Summary (quantiles, can't aggregate across instances). Always label with bounded values — NEVER unbounded (user IDs, full URLs). Write PromQL queries as comments above metric declarations for discoverability. Use `prometheus.DefBuckets` for HTTP latency histograms.
3. **OpenTelemetry Tracing**: Set up TracerProvider at service startup. Add spans to every meaningful operation: service methods, DB queries, external API calls. Use `otelhttp` middleware for automatic HTTP instrumentation. Record errors with `span.RecordError()`. Propagate context via `propagators` for cross-service trace continuity. Correlate with logs using `otelslog` bridge (trace_id, span_id injected automatically).
4. **pprof Profiling**: Enable pprof endpoints (with authentication) for on-demand profiling: CPU, heap, goroutine, mutex, block profiles. Toggle via env vars. Capture with `curl /debug/pprof/profile?seconds=30 > cpu.pprof`. Analyze with `go tool pprof -http=:8080 cpu.pprof`. For continuous profiling, use Pyroscope.
5. **Signal Correlation & Alerting**: Embed trace_id in logs for jumping from log line to full trace. Attach exemplars on histogram metrics linking latency spikes to exact traces. A feature is NOT done until observable: metrics declared, proper logging in place, spans created. Set up alerts on four golden signals: latency, traffic, errors, saturation.

## Pitfalls
- Logging AND returning the same error — violates single handling rule, creates duplicate logs.
- High-cardinality metric labels (user IDs, emails, full URLs) — destroys Prometheus performance.
- Using Summary instead of Histogram for latency — can't aggregate across instances.
- Not passing context to slog calls — breaks trace correlation between logs and traces.
- Exposing pprof endpoints without authentication in production — information disclosure risk.
- Using `irate` instead of `rate` in PromQL alerting rules — causes flapping alerts.

## Verification
1. All production logging uses `slog` — grep for `fmt.Println`, `log.Print` shows zero results.
2. Every exported function returns a `slog`-logged error or wrapped error — never both.
3. Each HTTP endpoint has latency histogram + error counter metrics declared.
4. `go tool pprof` can connect to /debug/pprof/ endpoints.
5. All slog calls use `Context` variants for trace correlation.