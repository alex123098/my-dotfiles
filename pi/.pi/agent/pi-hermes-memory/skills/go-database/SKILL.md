---
name: "go-database"
description: "Go database access patterns — parameterized queries, struct scanning, transactions, connection pooling, context propagation. Use when writing, reviewing, or debugging Go code that interacts with PostgreSQL, MySQL, or SQLite."
version: 1
created: "2026-06-20"
updated: "2026-06-20"
---
## When to Use
Use when writing repository functions, query helpers, transaction wrappers, or connection pool configuration in Go. Covers sqlx/pgx patterns (no ORMs), parameterized queries, NULL handling, scanning, transactions with isolation levels, connection pool tuning, batch processing, and context-aware operations.

## Procedure
1. **Use sqlx or pgx, Not ORMs**: Use `jmoiron/sqlx` for struct scanning ergonomics or `jackc/pgx` for PostgreSQL-specific features. Avoid GORM and other ORMs — they hide SQL, generate unpredictable queries, and make debugging harder. ORMs also obscure JOINs, subqueries, and index utilization from query plans.
2. **Parameterized Queries**: NEVER concatenate user input into SQL strings — use `?` (MySQL/SQLite) or `$1` (PostgreSQL) placeholders: `db.GetContext(ctx, &user, "SELECT * FROM users WHERE id = ?", id)`. Parameterization is not optional — concatenation leads to SQL injection.
3. **Scanning & NULL Handling**: Use sqlx `StructScan` / `Get` / `Select` for automatic struct mapping. Handle NULLable columns with `*string`, `*int` pointers or `sql.NullXxx` types. Use `COALESCE` in SQL as a simpler alternative. Always handle `sql.ErrNoRows` explicitly — distinguish 'not found' from real errors using `errors.Is(err, sql.ErrNoRows)`.
4. **Transactions**: Use `BeginTxx`/`BeginTx` for multi-statement operations. Handle commit/rollback via `defer` pattern: `tx, err := db.BeginTxx(ctx, nil); if err != nil { return err }; defer tx.Rollback()` — then `tx.Commit()` at the end. Set isolation levels when default READ COMMITTED is insufficient (SERIALIZABLE for financial operations). Use `SELECT ... FOR UPDATE` when reading data to modify — prevents race conditions.
5. **Connection Pool**: Always configure pool limits: `db.SetMaxOpenConns(n)` (limit total connections), `db.SetMaxIdleConns(n)` (keep warm connections), `db.SetConnMaxLifetime(d)` (recycle connections), `db.SetConnMaxIdleTime(d)` (close idle connections). Default MaxIdleConns is 2 — too low for any concurrent service. Match MaxOpenConns to your DB's configured connection limit.
6. **Context & Batch Patterns**: Always use `*Context` method variants (`QueryContext`, `ExecContext`, `GetContext`) to respect request deadlines. Always `defer rows.Close()` immediately after `QueryContext` call. Use `db.Exec` (not `Query`) for statements returning no rows — `Query` returns `*Rows` that must be closed or the connection leaks. Batch operations in reasonable sizes (e.g., 1000 rows per batch) — row-by-row is too many round trips, millions at once holds locks and memory.

## Pitfalls
- Using `db.Query` for INSERT/UPDATE/DELETE — returns `*Rows` that must be closed, leaks connection if forgotten. Use `db.Exec`.
- Not deferring `rows.Close()` — connection leaks back to pool slowly, eventually exhausting it.
- Forgetting to handle `sql.ErrNoRows` — it's a sentinel error, not a real failure.
- Not setting `MaxIdleConns` — defaults to 2, causing connection storms under load.
- Using ORMs — they generate unpredictable SQL, make query optimization impossible, and break debugging.
- Opening and closing connections for each operation — use a shared pool initialized once at startup.

## Verification
1. No SQL string concatenation in the codebase — all queries use parameterized placeholders.
2. Every `QueryContext` has `defer rows.Close()` immediately following.
3. Connection pool configured at startup with explicit MaxOpenConns, MaxIdleConns, ConnMaxLifetime.
4. No GORM or other ORM imports in production code.
5. `sql.ErrNoRows` is handled explicitly in every query function.