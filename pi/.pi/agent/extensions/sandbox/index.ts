/**
 * Sandbox Extension - FS-level sandboxing for bash + FS policy for read/write/edit
 *
 * MOTIVATION
 * ----------
 * The @anthropic-ai/sandbox-runtime (srt) creates persistent 0-byte stub files in the
 * working directory when it runs bash commands via bubblewrap on Linux.  Root cause:
 * `bwrap --ro-bind /dev/null <non-existent-target>` requires the target to exist on the
 * HOST filesystem first, so bwrap creates it — and never removes it.
 * See: https://github.com/anthropic-experimental/sandbox-runtime/issues/85
 *      https://github.com/anthropics/claude-code/issues/28189
 *
 * This extension replaces srt with a minimal hand-rolled bubblewrap wrapper that only
 * bind-mounts paths that ALREADY EXIST on the host — non-existent paths are simply
 * skipped, eliminating the stub-file creation entirely.
 *
 * WHAT THIS PROVIDES
 * ------------------
 * 1. **FS policy** (pure TypeScript, always active when enabled):
 *    Intercepts the `read`, `write`, and `edit` built-in tool calls and blocks them
 *    according to the denyRead / allowWrite / denyWrite config.
 *
 * 2. **Bash sandbox** (requires `bwrap` on Linux):
 *    Wraps every bash command in a bubblewrap container with:
 *      - Read-only root (`--ro-bind / /`)
 *      - Selective write access (`--bind <dir> <dir>` for each allowWrite dir, if it exists)
 *      - Read blocks via tmpfs/devnull overlay — ONLY for paths that exist on disk
 *      - PID namespace isolation (`--unshare-pid --proc /proc`)
 *      - Optional full network block (`--unshare-net`) when blockNetwork: true
 *    Network proxy / per-domain filtering is NOT supported — this avoids the socat
 *    bridge processes and the associated socket cleanup issues.
 *
 * CONFIG
 * ------
 * Global: ~/.pi/agent/sandbox.json
 * Project: <cwd>/.pi/sandbox.json  (merged, project wins)
 *
 * {
 *   "enabled": true,
 *   "blockNetwork": false,          // true → --unshare-net (blocks ALL network in bash)
 *   "filesystem": {
 *     "denyRead":   ["~/.ssh", "~/.aws", "~/.gnupg"],
 *     "allowWrite": [".", "/tmp"],
 *     "denyWrite":  [".env", ".env.*", "*.pem", "*.key"]
 *   }
 * }
 *
 * Pattern matching (denyRead / denyWrite / allowWrite):
 *   - Patterns with "/" or starting with "~" → path-prefix match after expansion.
 *   - Bare patterns (no "/")                 → minimatch glob against the basename.
 *
 * USAGE
 * -----
 *   pi -e ~/.pi/agent/extensions/sandbox          # enabled with default config
 *   pi -e ~/.pi/agent/extensions/sandbox --no-sandbox   # disable everything
 *   /sandbox                                        # show current config & status
 *
 * SETUP (Linux)
 * -----
 *   1. Copy sandbox/ directory to ~/.pi/agent/extensions/
 *   2. Run `npm install` inside ~/.pi/agent/extensions/sandbox/
 *   3. Ensure bwrap is installed: pacman -S bubblewrap
 */

import { spawn, spawnSync } from "node:child_process";
import { existsSync, readFileSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { basename, resolve, sep } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { CONFIG_DIR_NAME, createBashTool, getAgentDir, type BashOperations } from "@earendil-works/pi-coding-agent";
import { minimatch } from "minimatch";

// ─── Config types ─────────────────────────────────────────────────────────────

interface FilesystemConfig {
  denyRead?: string[];
  allowWrite?: string[];
  denyWrite?: string[];
}

interface SandboxConfig {
  enabled?: boolean;
  blockNetwork?: boolean; // --unshare-net: blocks ALL network access inside bash
  filesystem?: FilesystemConfig;
}

// ─── Defaults ────────────────────────────────────────────────────────────────

const DEFAULT_CONFIG: SandboxConfig = {
  enabled: true,
  blockNetwork: false,
  filesystem: {
    denyRead: ["~/.ssh", "~/.aws", "~/.gnupg"],
    allowWrite: [".", "/tmp"],
    denyWrite: [".env", ".env.*", "*.pem", "*.key"],
  },
};

// ─── Config loading ───────────────────────────────────────────────────────────

function loadConfig(cwd: string): SandboxConfig {
  const globalPath = resolve(getAgentDir(), "sandbox.json");
  const projectPath = resolve(cwd, CONFIG_DIR_NAME, "sandbox.json");

  let global: Partial<SandboxConfig> = {};
  let project: Partial<SandboxConfig> = {};

  for (const [path, target] of [
    [globalPath, { ref: global }],
    [projectPath, { ref: project }],
  ] as const) {
    if (existsSync(path)) {
      try {
        const parsed = JSON.parse(readFileSync(path, "utf-8"));
        if (path === globalPath) global = parsed;
        else project = parsed;
      } catch (e) {
        console.error(`Warning: Could not parse ${path}: ${e}`);
      }
    }
  }

  return deepMerge(deepMerge(DEFAULT_CONFIG, global), project);
}

function deepMerge(base: SandboxConfig, over: Partial<SandboxConfig>): SandboxConfig {
  const r = { ...base };
  if (over.enabled !== undefined) r.enabled = over.enabled;
  if (over.blockNetwork !== undefined) r.blockNetwork = over.blockNetwork;
  if (over.filesystem) r.filesystem = { ...base.filesystem, ...over.filesystem };
  return r;
}

// ─── Path helpers ─────────────────────────────────────────────────────────────

function expandPath(pattern: string, cwd: string): string {
  if (pattern.startsWith("~")) return resolve(homedir(), pattern.slice(2));
  return resolve(cwd, pattern);
}

/**
 * Returns true if `filePath` matches `pattern`.
 *
 * Patterns with "/" or starting with "~" are treated as path prefixes after expansion.
 * Bare patterns (no "/") are matched as basename globs via minimatch.
 */
function matchesPattern(filePath: string, pattern: string, cwd: string): boolean {
  const isPathPattern = pattern.includes("/") || pattern.startsWith("~");
  if (isPathPattern) {
    const expanded = expandPath(pattern, cwd);
    const resolved = resolve(cwd, filePath);
    return resolved === expanded || resolved.startsWith(expanded + sep);
  }
  return minimatch(basename(filePath), pattern, { dot: true });
}

// ─── FS policy checks (for read / write / edit tools) ─────────────────────────

function checkReadPolicy(filePath: string, fs: FilesystemConfig | undefined, cwd: string): string | null {
  for (const pattern of fs?.denyRead ?? []) {
    if (matchesPattern(filePath, pattern, cwd)) {
      return `Read blocked: "${filePath}" matches restricted pattern "${pattern}"`;
    }
  }
  return null;
}

function checkWritePolicy(filePath: string, fs: FilesystemConfig | undefined, cwd: string): string | null {
  // denyWrite takes priority
  for (const pattern of fs?.denyWrite ?? []) {
    if (matchesPattern(filePath, pattern, cwd)) {
      return `Write blocked: "${filePath}" matches restricted pattern "${pattern}"`;
    }
  }
  // allowWrite whitelist — if non-empty, file must be under one of the allowed dirs
  const allowed = fs?.allowWrite ?? [];
  if (allowed.length > 0) {
    const resolved = resolve(cwd, filePath);
    const ok = allowed.some((dir) => {
      const expanded = expandPath(dir, cwd);
      return resolved === expanded || resolved.startsWith(expanded + sep);
    });
    if (!ok) {
      return `Write blocked: "${filePath}" is outside allowed write paths [${allowed.join(", ")}]`;
    }
  }
  return null;
}

// ─── Bubblewrap bash sandboxing ───────────────────────────────────────────────

/**
 * Check if bwrap is available and usable on this system.
 */
function hasBwrap(): boolean {
  const r = spawnSync("bwrap", ["--version"], { stdio: "pipe" });
  return r.status === 0;
}

/**
 * Build bwrap arguments for the given config and cwd.
 *
 * KEY INVARIANT: We only add `--ro-bind /dev/null <target>` or `--bind <src> <dst>`
 * for paths that ALREADY EXIST on the host. Non-existent paths are skipped entirely.
 * This avoids the stub-file creation bug in @anthropic-ai/sandbox-runtime.
 */
function buildBwrapArgs(cfg: SandboxConfig, cwd: string): string[] {
  const fs = cfg.filesystem ?? {};
  const args: string[] = ["--die-with-parent", "--new-session"];

  // Read-only root: everything is read-only by default
  args.push("--ro-bind", "/", "/");

  // Selectively allow writes — only for paths that actually exist
  for (const pattern of fs.allowWrite ?? []) {
    const expanded = expandPath(pattern, cwd);
    if (existsSync(expanded)) {
      args.push("--bind", expanded, expanded);
    }
    // Non-existent allowed-write paths are skipped — no stub files created
  }

  // Block reads to denied paths — only for paths that actually exist
  for (const pattern of fs.denyRead ?? []) {
    const expanded = expandPath(pattern, cwd);
    if (!existsSync(expanded)) continue; // ← the fix: skip non-existent paths
    try {
      const st = statSync(expanded);
      if (st.isDirectory()) {
        args.push("--tmpfs", expanded); // mount empty tmpfs over directory
      } else {
        args.push("--ro-bind", "/dev/null", expanded); // bind /dev/null over file
      }
    } catch {
      // stat failed — skip
    }
  }

  // System mounts
  args.push("--dev", "/dev");
  args.push("--proc", "/proc");
  args.push("--unshare-pid");

  // Optional: block all network access
  if (cfg.blockNetwork) {
    args.push("--unshare-net");
  }

  return args;
}

function createBwrapBashOps(cfg: SandboxConfig, sessionCwd: string): BashOperations {
  return {
    async exec(command, cwd, { onData, signal, timeout }) {
      if (!existsSync(cwd)) throw new Error(`Working directory does not exist: ${cwd}`);

      const bwrapArgs = buildBwrapArgs(cfg, sessionCwd);
      // Run: bwrap <args> bash -c <command>
      bwrapArgs.push("bash", "-c", command);

      return new Promise((resolve, reject) => {
        const child = spawn("bwrap", bwrapArgs, {
          cwd,
          detached: true,
          stdio: ["ignore", "pipe", "pipe"],
        });

        let timedOut = false;
        let timeoutHandle: NodeJS.Timeout | undefined;

        if (timeout !== undefined && timeout > 0) {
          timeoutHandle = setTimeout(() => {
            timedOut = true;
            if (child.pid) {
              try { process.kill(-child.pid, "SIGKILL"); } catch { child.kill("SIGKILL"); }
            }
          }, timeout * 1000);
        }

        child.stdout?.on("data", onData);
        child.stderr?.on("data", onData);
        child.on("error", (err) => { if (timeoutHandle) clearTimeout(timeoutHandle); reject(err); });

        const onAbort = () => {
          if (child.pid) {
            try { process.kill(-child.pid, "SIGKILL"); } catch { child.kill("SIGKILL"); }
          }
        };
        signal?.addEventListener("abort", onAbort, { once: true });

        child.on("close", (code) => {
          if (timeoutHandle) clearTimeout(timeoutHandle);
          signal?.removeEventListener("abort", onAbort);
          if (signal?.aborted) reject(new Error("aborted"));
          else if (timedOut) reject(new Error(`timeout:${timeout}`));
          else resolve({ exitCode: code });
        });
      });
    },
  };
}

// ─── Extension entry point ────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerFlag("no-sandbox", {
    description: "Disable sandboxing (FS policy for read/write/edit + bwrap for bash)",
    type: "boolean",
    default: false,
  });

  const localCwd = process.cwd();
  const localBash = createBashTool(localCwd);

  let bashSandboxEnabled = false;
  let fsPolicyEnabled = false;
  let activeConfig: SandboxConfig = DEFAULT_CONFIG;

  // ── Bash tool override ─────────────────────────────────────────────────────

  pi.registerTool({
    ...localBash,
    label: "bash (sandboxed)",
    async execute(id, params, signal, onUpdate, _ctx) {
      if (!bashSandboxEnabled) return localBash.execute(id, params, signal, onUpdate);
      const ops = createBwrapBashOps(activeConfig, localCwd);
      const sandboxedBash = createBashTool(localCwd, { operations: ops });
      return sandboxedBash.execute(id, params, signal, onUpdate);
    },
  });

  pi.on("user_bash", () => {
    if (!bashSandboxEnabled) return;
    return { operations: createBwrapBashOps(activeConfig, localCwd) };
  });

  // ── FS policy: intercept read / write / edit ───────────────────────────────

  pi.on("tool_call", async (event, ctx) => {
    if (!fsPolicyEnabled) return undefined;

    const { toolName, input } = event;
    const filePath = input.path as string | undefined;
    if (!filePath) return undefined;

    if (toolName === "read") {
      const reason = checkReadPolicy(filePath, activeConfig.filesystem, ctx.cwd);
      if (reason) { ctx.ui.notify(reason, "warning"); return { block: true, reason }; }
    }

    if (toolName === "write" || toolName === "edit") {
      const reason = checkWritePolicy(filePath, activeConfig.filesystem, ctx.cwd);
      if (reason) { ctx.ui.notify(reason, "warning"); return { block: true, reason }; }
    }

    return undefined;
  });

  // ── Session lifecycle ──────────────────────────────────────────────────────

  pi.on("session_start", async (_event, ctx) => {
    const noSandbox = pi.getFlag("no-sandbox") as boolean;
    activeConfig = loadConfig(ctx.cwd);

    if (noSandbox || activeConfig.enabled === false) {
      fsPolicyEnabled = false;
      bashSandboxEnabled = false;
      ctx.ui.notify(`Sandbox disabled (${noSandbox ? "--no-sandbox" : "config"})`, "info");
      return;
    }

    // FS policy is always active (no OS deps)
    fsPolicyEnabled = true;

    // Bash sandbox requires bwrap on Linux
    if (process.platform !== "linux") {
      ctx.ui.notify(`Bash sandbox not supported on ${process.platform}; FS policy active`, "warning");
    } else if (!hasBwrap()) {
      ctx.ui.notify("bwrap not found — bash sandbox disabled; FS policy active. Install: pacman -S bubblewrap", "warning");
    } else {
      bashSandboxEnabled = true;
    }

    _reportStatus(ctx);
  });

  pi.on("session_shutdown", async () => {
    bashSandboxEnabled = false;
    fsPolicyEnabled = false;
  });

  // ── /sandbox command ───────────────────────────────────────────────────────

  pi.registerCommand("sandbox", {
    description: "Show current sandbox configuration and status",
    handler: async (_args, ctx) => {
      if (!fsPolicyEnabled && !bashSandboxEnabled) {
        ctx.ui.notify("Sandbox is disabled", "info");
        return;
      }
      const cfg = activeConfig;
      const networkNote = cfg.blockNetwork
        ? "all blocked (--unshare-net)"
        : "unrestricted (set blockNetwork:true to block all)";
      const lines = [
        `Status:  bash-sandbox=${bashSandboxEnabled ? "✓ (bwrap)" : "✗"}  fs-policy=${fsPolicyEnabled ? "✓" : "✗"}`,
        "",
        `Network (bash): ${networkNote}`,
        "",
        "Filesystem policy (read/write/edit tools):",
        `  Deny Read:   ${cfg.filesystem?.denyRead?.join(", ") || "(none)"}`,
        `  Allow Write: ${cfg.filesystem?.allowWrite?.join(", ") || "(any)"}`,
        `  Deny Write:  ${cfg.filesystem?.denyWrite?.join(", ") || "(none)"}`,
        "",
        "Note: bash sandbox uses bwrap directly (no @anthropic-ai/sandbox-runtime).",
        "      Non-existent deny/allow paths are skipped — no stub files created.",
      ];
      ctx.ui.notify(lines.join("\n"), "info");
    },
  });

  // ── Internal helpers ───────────────────────────────────────────────────────

  function _reportStatus(ctx: ExtensionContext) {
    const parts: string[] = [];
    if (bashSandboxEnabled) parts.push(`bwrap${activeConfig.blockNetwork ? "(net-blocked)" : ""}`);
    if (fsPolicyEnabled) {
      const wc = activeConfig.filesystem?.allowWrite?.length ?? 0;
      parts.push(`fs-policy(${wc} write paths)`);
    }
    if (parts.length > 0) {
      ctx.ui.setStatus("sandbox", ctx.ui.theme.fg("accent", `🔒 Sandbox: ${parts.join(", ")}`));
      ctx.ui.notify(`Sandbox active: ${parts.join(", ")}`, "info");
    }
  }
}
