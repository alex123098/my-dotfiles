/**
 * Tokyo-Night Status Bar Extension
 *
 * Replaces the default pi footer with a custom status bar:
 *   Left:  context used / context max (%),  CWD
 *   Right: provider/model,  thinking level,  vim mode
 *
 * Colors are tuned to the tokyo-dark theme — brighter than the default dim/muted
 * footer, using accent/blue for values, muted for labels, and context-type tokens
 * (success→green when low, warning→yellow when moderate, error→red when high).
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/**
 * Map a context-usage percentage (0-100) to a circular progress character.
 * Progression: ○ empty → ◔ quarter → ◑ half → ◕ three-quarters → ● full
 */
function barChar(pct: number): string {
  if (pct <= 0) return "▁";
  if (pct <= 15) return "▂";
  if (pct <= 35) return "▃";
  if (pct <= 55) return "▄";
  if (pct <= 65) return "▅";
  if (pct <= 75) return "▆";
  if (pct <= 88) return "▇";
  return "█";
}

export default function(pi: ExtensionAPI) {
  // --- Track mutable state for the footer ---
  let renderRequestFn: (() => void) | null = null;

  function requestRender() {
    renderRequestFn?.();
  }

  // Model change → re-render
  pi.on("model_select", () => requestRender());

  // Thinking level change → re-render
  pi.on("thinking_level_select", () => requestRender());

  // Session startup → install footer
  pi.on("session_start", async (_event: unknown, ctx: ExtensionContext) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      renderRequestFn = () => tui.requestRender();

      // Re-render when branch changes (e.g., new messages)
      const unsubBranch = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: () => {
          renderRequestFn = null;
          unsubBranch();
        },
        invalidate() { },
        render(width: number): string[] {
          // --- Left side: context usage ---
          const usage = ctx.getContextUsage();
          const ctxWindow = ctx.model?.contextWindow ?? 0;
          const ctxTokens = usage?.tokens ?? 0;
          const ctxPercent = usage?.percent ?? 0;

          let ctxStr: string;
          if (ctxWindow > 0 && ctxTokens > 0) {
            const abs = ctxTokens >= 1000
              ? `${(ctxTokens / 1000).toFixed(ctxTokens >= 1_000_000 ? 1 : 0)}k`
              : `${ctxTokens}`;
            const max = ctxWindow >= 1000
              ? `${(ctxWindow / 1000).toFixed(0)}k`
              : `${ctxWindow}`;

            // Color-code by usage percentage — circle + numbers
            const ctxToken = ctxPercent < 50 ? "success" : ctxPercent < 80 ? "warning" : "error";
            const bar = barChar(ctxPercent);
            ctxStr = theme.fg(ctxToken, bar) +
              theme.fg("dim", " ") +
              theme.fg(ctxToken, `${abs}`) +
              theme.fg("dim", "/") +
              theme.fg("muted", max) +
              theme.fg("dim", ` (${ctxPercent.toFixed(0)}%)`);
          } else {
            ctxStr = theme.fg("dim", "  —");
          }

          // CWD
          const cwd = ctx.cwd;
          const cwdShort = cwd === process.env.HOME
            ? "~"
            : cwd.startsWith(process.env.HOME ?? "")
              ? `~${cwd.slice((process.env.HOME ?? "").length)}`
              : cwd.split("/").pop() ?? cwd;

          const left = `${ctxStr}  ${theme.fg("accent", cwdShort)}`;

          // --- Right side: model + thinking ---
          const modelId = ctx.model?.id ?? "no-model";
          const provider = ctx.model?.provider ?? "";
          const modelLabel = provider ? `${provider}/${modelId}` : modelId;
          const modelStr = theme.fg("text", modelLabel);

          const thinkingLevel = pi.getThinkingLevel();
          const thinkingColor =
            thinkingLevel === "off" ? "dim" :
              thinkingLevel === "minimal" ? "muted" :
                thinkingLevel === "low" ? "success" :
                  thinkingLevel === "medium" ? "accent" :
                    thinkingLevel === "high" ? "warning" : "error";
          const thinkingStr = theme.fg(thinkingColor, `${thinkingLevel === "off" ? "" : "🧠 "}${thinkingLevel}`);

          // Vim mode (from pi-vimmode extension status)
          const vimStatus = footerData.getExtensionStatuses().get("pi-vimmode");
          const vimStr = vimStatus ? `  ${theme.fg("accent", vimStatus)}` : "";

          const right = `${modelStr}  ${thinkingStr}${vimStr}`;

          // --- Layout: left + pad + right ---
          const leftW = visibleWidth(left);
          const rightW = visibleWidth(right);
          const padLen = Math.max(1, width - leftW - rightW);
          const pad = " ".repeat(padLen);

          return [truncateToWidth(left + pad + right, width)];
        },
      };
    });
  });
}