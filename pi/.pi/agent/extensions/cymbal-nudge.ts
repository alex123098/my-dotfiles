/**
 * cymbal-nudge.ts — Nudge the agent to prefer cymbal for code navigation
 *
 * Wires cymbal's two hook subcommands into Pi's native hook points:
 *
 *   session_start     → `cymbal hook remind` — injects navigation primer into
 *                        the system prompt once per session so the model starts
 *                        cymbal-aware without paying re-injection cost every turn.
 *
 *   tool_call (bash)  → `cymbal hook nudge` — inspects the would-be shell command;
 *                        if it looks like a code search (rg/grep/find/fd/…), appends
 *                        a short cymbal suggestion to the tool result so the model
 *                        sees the better path right next to its output.
 *
 *   tool_call (read)  → light heuristic nudge when reading a full source file
 *                        (no offset/limit) to suggest `cymbal show` / `cymbal search`.
 *
 * Follows the same "never blocks, always allow" contract as cymbal's design notes.
 * Silent when cymbal is not installed or has nothing to say.
 */

import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawnSync } from "node:child_process";

// Source-code extensions that warrant a cymbal read-nudge
const CODE_EXTS = new Set([
  ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
  ".go", ".py", ".rs", ".lua", ".rb", ".java",
  ".cs", ".cpp", ".c", ".h", ".hpp", ".zig", ".sh",
]);

// ── cymbal helpers ───────────────────────────────────────────

function cymbalRemind(): string | null {
  try {
    const r = spawnSync("cymbal", ["hook", "remind", "--format=json"], {
      encoding: "utf-8",
      timeout: 5000,
    });
    if (r.status === 0 && r.stdout) {
      const parsed = JSON.parse(r.stdout.trim()) as { systemMessage?: string };
      return parsed.systemMessage ?? null;
    }
  } catch {
    // cymbal not installed or remind failed — stay silent
  }
  return null;
}

interface NudgeResult {
  suggest: string;
  why: string;
  tool: string;
}

function cymbalNudge(command: string): NudgeResult | null {
  const payload = JSON.stringify({ tool_name: "Bash", tool_input: { command } });
  try {
    const r = spawnSync("cymbal", ["hook", "nudge", "--format=json"], {
      input: payload,
      encoding: "utf-8",
      timeout: 5000,
    });
    if (r.status === 0 && r.stdout?.trim()) {
      return JSON.parse(r.stdout.trim()) as NudgeResult;
    }
  } catch {
    // cymbal not installed or nudge failed — stay silent
  }
  return null;
}

function fileExt(path: string): string {
  const dot = path.lastIndexOf(".");
  const slash = Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\"));
  return dot > slash ? path.slice(dot) : "";
}

function isCodeFile(path: string): boolean {
  return CODE_EXTS.has(fileExt(path));
}

// ── Extension ───────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // Reminder text fetched once per session; reset on reload/new/resume
  let reminder: string | null = null;
  let reminderInjected = false;

  // Per-tool-call nudge text, keyed by toolCallId
  const pendingNudges = new Map<string, string>();

  // Throttle read-nudges: at most once every 30 s
  const READ_NUDGE_INTERVAL_MS = 30_000;
  let lastReadNudgeAt = 0;

  // ── 1. session_start: fetch reminder (non-blocking) ───────
  pi.on("session_start", (_event, _ctx) => {
    reminderInjected = false;
    lastReadNudgeAt = 0;
    pendingNudges.clear();
    reminder = cymbalRemind();
  });

  // ── 2. before_agent_start: inject reminder once per session
  pi.on("before_agent_start", (event, _ctx) => {
    if (reminderInjected || !reminder) return;
    reminderInjected = true;
    return {
      systemPrompt: `${event.systemPrompt}\n\n---\n\n${reminder}`,
    };
  });

  // ── 3. tool_call: inspect bash commands + read calls ──────
  pi.on("tool_call", (event, _ctx) => {
    // Bash: delegate to cymbal hook nudge
    if (isToolCallEventType("bash", event)) {
      const nudge = cymbalNudge(event.input.command);
      if (nudge) {
        pendingNudges.set(
          event.toolCallId,
          `💡 **cymbal nudge:** ${nudge.suggest}\n_Why:_ ${nudge.why}`,
        );
      }
      return; // always allow
    }

    // Read: light heuristic — only for full-file reads of source files, throttled
    if (isToolCallEventType("read", event)) {
      const { path, offset, limit } = event.input;
      const now = Date.now();
      if (!offset && !limit && isCodeFile(path) && now - lastReadNudgeAt >= READ_NUDGE_INTERVAL_MS) {
        lastReadNudgeAt = now;
        const base = path.split("/").pop() ?? path;
        pendingNudges.set(
          event.toolCallId,
          `💡 **cymbal tip:** Reading a full source file? ` +
            `If you know a symbol name, \`cymbal show <SymbolName>\` is faster. ` +
            `Use \`cymbal search ${base}\` to list symbols defined in this file.`,
        );
      }
    }

  });

  // ── 4. tool_result: append pending nudge (if any) ─────────
  pi.on("tool_result", (event, _ctx) => {
    const nudge = pendingNudges.get(event.toolCallId);
    if (!nudge) return;
    pendingNudges.delete(event.toolCallId);

    return {
      content: [
        ...(event.content ?? []),
        { type: "text" as const, text: `\n\n${nudge}` },
      ],
    };
  });
}
