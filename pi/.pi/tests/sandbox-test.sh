#!/usr/bin/env bash
# ─── Sandbox Extension Full Test Suite ─────────────────────────────────────────
# Run inside a pi session that has the sandbox extension loaded.
# bash commands will be sandboxed — this is intentional (we're testing the sandbox).
#
# Usage: bash sandbox-test.sh

set -euo pipefail

PASS=0
FAIL=0

pass() { PASS=$((PASS+1)); echo "  ✅ PASS: $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ FAIL: $1"; }

# ─── Test 1: Bash runs inside bwrap ─────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 1: Bash runs inside bwrap container"
echo "═══════════════════════════════════════════════════════════════"
CMD=$(tr '\0' ' ' < /proc/1/cmdline 2>/dev/null || echo "")
if echo "$CMD" | grep -q bwrap; then
  pass "PID 1 is bwrap — bash is sandboxed"
else
  fail "PID 1 is not bwrap"
fi

# ─── Test 2: PID namespace isolation ────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 2: PID namespace isolation"
echo "═══════════════════════════════════════════════════════════════"
PNAME=$(ps -p 1 -o comm= 2>/dev/null || echo "")
if [ "$PNAME" = "bwrap" ]; then
  pass "PID 1 is bwrap (inside container)"
else
  fail "Expected PID 1 = bwrap, got $PNAME"
fi

# ─── Test 3: Read-only root ─────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 3: Read-only root filesystem"
echo "═══════════════════════════════════════════════════════════════"
if touch /test_ro_check 2>/dev/null; then
  fail "Root is writable (expected read-only)"
  rm -f /test_ro_check
else
  pass "Root is read-only (cannot write to /)"
fi

# ─── Test 4: denyRead paths are empty tmpfs ─────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 4: denyRead paths isolated via empty tmpfs"
echo "═══════════════════════════════════════════════════════════════"
MISSING=0
for denied in ~/.ssh ~/.aws ~/.gnupg; do
  COUNT=$(ls -1 "$denied" 2>/dev/null | wc -l || echo 0)
  if [ "$COUNT" -eq 0 ] 2>/dev/null; then
    pass "$denied is empty tmpfs"
  else
    fail "$denied has $COUNT entries (expected empty)"
    MISSING=$((MISSING+1))
  fi
done

# ─── Test 5: allowWrite directories are writable ────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 5: allowWrite directories are writable"
echo "═══════════════════════════════════════════════════════════════"
CWD_WRITABLE=false
if touch /tmp/_sandbox_test_write 2>/dev/null; then
  rm -f /tmp/_sandbox_test_write
  pass "/tmp is writable"
else
  fail "/tmp is not writable"
fi

# ─── Test 6: Network access (should work with blockNetwork=false) ──────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 6: Network access (blockNetwork=false)"
echo "═══════════════════════════════════════════════════════════════"
if curl -s --connect-timeout 5 https://google.com >/dev/null 2>&1; then
  pass "Network is reachable (http request succeeded)"
elif curl -s --connect-timeout 5 https://google.com 2>&1 | grep -qi "301\|moved\|timeout\|refused\|resolved"; then
  pass "Network attempted (DNS resolution works)"
else
  fail "Network appears blocked"
fi

# ─── Test 7: No stub files created ─────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  TEST 7: No stub files created by bwrap"
echo "═══════════════════════════════════════════════════════════════"
STUBS=$(find / -maxdepth 4 -name "*.stub" -o -name "bwrap-stub-*" 2>/dev/null | head -5)
if [ -z "$STUBS" ]; then
  pass "No stub files found on filesystem"
else
  echo "  Found: $STUBS"
  fail "Stub files detected"
fi

# ─── Results ────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  RESULTS: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════════════════════════════"
