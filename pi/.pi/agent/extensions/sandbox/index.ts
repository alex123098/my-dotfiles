/**
 * Sandbox Extension - OS-level sandboxing for bash + filesystem policy for read/write/edit
 *
 * Uses @anthropic-ai/sandbox-runtime to enforce filesystem and network
 * restrictions on bash commands at the OS level (sandbox-exec on macOS,
 * bubblewrap on Linux). Additionally enforces filesystem allow/deny policies
 * on read, write, and edit tools at the JavaScript level.
 *
 * Config files (merged, project takes precedence):
 * - ~/.pi/agent/extensions/sandbox.json (global)
 * - <cwd>/.pi/sandbox.json (project-local)
 *
 * Example .pi/sandbox.json:
 * ```json
 * {
 *   "enabled": true,
 *   "network": {
 *     "allowedDomains": ["github.com", "*.github.com"],
 *     "deniedDomains": []
 *   },
 *   "filesystem": {
 *     "denyRead": ["~/.ssh", "~/.aws"],
 *     "allowWrite": [".", "/tmp"],
 *     "denyWrite": [".env"]
 *   }
 * }
 * ```
 *
 * Usage:
 * - `pi -e ./sandbox` - sandbox enabled with default/config settings
 * - `pi -e ./sandbox --no-sandbox` - disable sandboxing
 * - `/sandbox` - show current sandbox configuration
 *
 * Setup:
 * 1. Copy sandbox/ directory to ~/.pi/agent/extensions/
 * 2. Run `npm install` in ~/.pi/agent/extensions/sandbox/
 *
 * Linux also requires: bubblewrap, socat, ripgrep
 */

import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { access as fsAccess, readFile as fsReadFile, writeFile as fsWriteFile, mkdir as fsMkdir } from "node:fs/promises";
import { homedir } from "node:os";
import * as path from "node:path";
import { SandboxManager, type SandboxRuntimeConfig } from "@anthropic-ai/sandbox-runtime";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	type BashOperations,
	type EditOperations,
	CONFIG_DIR_NAME,
	createBashTool,
	createReadTool,
	createWriteTool,
	createEditTool,
	getAgentDir,
	type ReadOperations,
	type WriteOperations,
} from "@earendil-works/pi-coding-agent";

// ---------------------------------------------------------------------------
// Types & defaults
// ---------------------------------------------------------------------------

interface SandboxConfig extends SandboxRuntimeConfig {
	enabled?: boolean;
}

const DEFAULT_CONFIG: SandboxConfig = {
	enabled: true,
	network: {
		allowedDomains: [
			"npmjs.org",
			"*.npmjs.org",
			"registry.npmjs.org",
			"registry.yarnpkg.com",
			"pypi.org",
			"*.pypi.org",
			"github.com",
			"*.github.com",
			"api.github.com",
			"raw.githubusercontent.com",
		],
		deniedDomains: [],
	},
	filesystem: {
		denyRead: ["~/.ssh", "~/.aws", "~/.gnupg"],
		allowWrite: [".", "/tmp"],
		denyWrite: [".env", ".env.*", "*.pem", "*.key"],
	},
};

// ---------------------------------------------------------------------------
// Path policy helpers
// ---------------------------------------------------------------------------

/** Expand ~/ prefix to the user's home directory. */
function expandTilde(pattern: string): string {
	if (pattern.startsWith("~/")) {
		return path.join(homedir(), pattern.slice(2));
	}
	if (pattern === "~") {
		return homedir();
	}
	return pattern;
}

/**
 * Check whether `filePath` matches a single policy pattern.
 *
 * - Patterns containing glob characters (`*`, `?`, `[`, `{`, `\`) are tested
 *   with `path.matchesGlob` (Node 22+).
 * - Non-glob patterns are treated as directory/file prefixes: `filePath` must
 *   equal `resolved` or start with `resolved/` (after expanding `~` and
 *   resolving relative paths against `cwd`).
 */
function matchesPolicy(filePath: string, rawPattern: string, cwd: string): boolean {
	const pattern = expandTilde(rawPattern);

	// Glob pattern – delegate to Node 22+ path.matchesGlob
	if (/[*?[{\\]/.test(pattern)) {
		return path.matchesGlob(filePath, pattern);
	}

	// Resolve relative patterns against cwd (e.g. "." → cwd)
	const resolved = path.isAbsolute(pattern) ? pattern : path.resolve(cwd, pattern);

	return filePath === resolved || filePath.startsWith(resolved + "/");
}

/** Check whether a path is denied for reading. */
function isReadDenied(filePath: string, denyPatterns: string[] | undefined, cwd: string): boolean {
	if (!denyPatterns || denyPatterns.length === 0) return false;
	const abs = path.resolve(filePath);
	return denyPatterns.some((p) => matchesPolicy(abs, p, cwd));
}

/** Check whether a write operation on `filePath` is permitted. */
function isWritePermitted(
	filePath: string,
	allowPatterns: string[] | undefined,
	denyPatterns: string[] | undefined,
	cwd: string,
): boolean {
	const abs = path.resolve(filePath);

	// Deny always wins.
	if (denyPatterns && denyPatterns.length > 0) {
		if (denyPatterns.some((p) => matchesPolicy(abs, p, cwd))) return false;
	}

	// If no allowlist is configured, everything that isn't denied is permitted.
	if (!allowPatterns || allowPatterns.length === 0) return true;

	// Must match at least one allow pattern.
	return allowPatterns.some((p) => matchesPolicy(abs, p, cwd));
}

// ---------------------------------------------------------------------------
// Load config (same as original)
// ---------------------------------------------------------------------------

let _cachedConfig: SandboxConfig | undefined;

function loadConfig(cwd: string): SandboxConfig {
	const projectConfigPath = path.join(cwd, CONFIG_DIR_NAME, "sandbox.json");
	const globalConfigPath = path.join(getAgentDir(), "extensions", "sandbox.json");

	let globalConfig: Partial<SandboxConfig> = {};
	let projectConfig: Partial<SandboxConfig> = {};

	if (existsSync(globalConfigPath)) {
		try {
			globalConfig = JSON.parse(readFileSync(globalConfigPath, "utf-8"));
		} catch (e) {
			console.error(`Warning: Could not parse ${globalConfigPath}: ${e}`);
		}
	}

	if (existsSync(projectConfigPath)) {
		try {
			projectConfig = JSON.parse(readFileSync(projectConfigPath, "utf-8"));
		} catch (e) {
			console.error(`Warning: Could not parse ${projectConfigPath}: ${e}`);
		}
	}

	return deepMerge(deepMerge(DEFAULT_CONFIG, globalConfig), projectConfig);
}

function invalidateConfig(): void {
	_cachedConfig = undefined;
}

function deepMerge(base: SandboxConfig, overrides: Partial<SandboxConfig>): SandboxConfig {
	const result: SandboxConfig = { ...base };

	if (overrides.enabled !== undefined) result.enabled = overrides.enabled;
	if (overrides.network) {
		result.network = { ...base.network, ...overrides.network };
	}
	if (overrides.filesystem) {
		result.filesystem = { ...base.filesystem, ...overrides.filesystem };
	}

	const extOverrides = overrides as {
		ignoreViolations?: Record<string, string[]>;
		enableWeakerNestedSandbox?: boolean;
	};
	const extResult = result as { ignoreViolations?: Record<string, string[]>; enableWeakerNestedSandbox?: boolean };

	if (extOverrides.ignoreViolations) {
		extResult.ignoreViolations = extOverrides.ignoreViolations;
	}
	if (extOverrides.enableWeakerNestedSandbox !== undefined) {
		extResult.enableWeakerNestedSandbox = extOverrides.enableWeakerNestedSandbox;
	}

	return result;
}

// ---------------------------------------------------------------------------
// Sandboxed bash ops (bubblewrap level – original)
// ---------------------------------------------------------------------------

function createSandboxedBashOps(): BashOperations {
	return {
		async exec(command, cwd, { onData, signal, timeout }) {
			if (!existsSync(cwd)) {
				throw new Error(`Working directory does not exist: ${cwd}`);
			}

			const wrappedCommand = await SandboxManager.wrapWithSandbox(command);

			return new Promise((resolve, reject) => {
				const child = spawn("bash", ["-c", wrappedCommand], {
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
							try {
								process.kill(-child.pid, "SIGKILL");
							} catch {
								child.kill("SIGKILL");
							}
						}
					}, timeout * 1000);
				}

				child.stdout?.on("data", onData);
				child.stderr?.on("data", onData);

				child.on("error", (err) => {
					if (timeoutHandle) clearTimeout(timeoutHandle);
					reject(err);
				});

				const onAbort = () => {
					if (child.pid) {
						try {
							process.kill(-child.pid, "SIGKILL");
						} catch {
							child.kill("SIGKILL");
						}
					}
				};

				signal?.addEventListener("abort", onAbort, { once: true });

				child.on("close", (code) => {
					if (timeoutHandle) clearTimeout(timeoutHandle);
					signal?.removeEventListener("abort", onAbort);

					if (signal?.aborted) {
						reject(new Error("aborted"));
					} else if (timedOut) {
						reject(new Error(`timeout:${timeout}`));
					} else {
						resolve({ exitCode: code });
					}
				});
			});
		},
	};
}

// ---------------------------------------------------------------------------
// Sandboxed read ops (filesystem policy at JS level)
// ---------------------------------------------------------------------------

function createPolicyReadOps(cwd: string, config: SandboxConfig): ReadOperations {
	const denyRead = config.filesystem?.denyRead;

	return {
		readFile: async (absolutePath) => {
			if (isReadDenied(absolutePath, denyRead, cwd)) {
				throw new Error(`Read denied by sandbox policy: ${absolutePath}`);
			}
			return fsReadFile(absolutePath);
		},
		access: async (absolutePath) => {
			if (isReadDenied(absolutePath, denyRead, cwd)) {
				throw new Error(`Read denied by sandbox policy: ${absolutePath}`);
			}
			await fsAccess(absolutePath, constants.R_OK);
		},
		detectImageMimeType: async (absolutePath) => {
			if (isReadDenied(absolutePath, denyRead, cwd)) {
				return null;
			}
			const ext = path.extname(absolutePath).toLowerCase();
			if (ext === ".png") return "image/png";
			if (ext === ".jpg" || ext === ".jpeg") return "image/jpeg";
			if (ext === ".gif") return "image/gif";
			if (ext === ".webp") return "image/webp";
			if (ext === ".bmp") return "image/bmp";
			return null;
		},
	};
}

// ---------------------------------------------------------------------------
// Sandboxed write ops (filesystem policy at JS level)
// ---------------------------------------------------------------------------

function createPolicyWriteOps(cwd: string, config: SandboxConfig): WriteOperations {
	const allowWrite = config.filesystem?.allowWrite;
	const denyWrite = config.filesystem?.denyWrite;

	return {
		writeFile: async (absolutePath, content) => {
			if (!isWritePermitted(absolutePath, allowWrite, denyWrite, cwd)) {
				throw new Error(
					`Write denied by sandbox policy: ${absolutePath}` +
						(allowWrite?.length ? ` (allowed paths: ${allowWrite.join(", ")})` : ""),
				);
			}
			await fsWriteFile(absolutePath, content, "utf-8");
		},
		mkdir: async (dir) => {
			if (!isWritePermitted(dir, allowWrite, denyWrite, cwd)) {
				throw new Error(
					`Write denied by sandbox policy: ${dir}` +
						(allowWrite?.length ? ` (allowed paths: ${allowWrite.join(", ")})` : ""),
				);
			}
			await fsMkdir(dir, { recursive: true });
		},
	};
}

// ---------------------------------------------------------------------------
// Sandboxed edit ops (filesystem policy at JS level)
// ---------------------------------------------------------------------------

function createPolicyEditOps(cwd: string, config: SandboxConfig): EditOperations {
	const denyRead = config.filesystem?.denyRead;
	const allowWrite = config.filesystem?.allowWrite;
	const denyWrite = config.filesystem?.denyWrite;

	return {
		readFile: async (absolutePath) => {
			if (isReadDenied(absolutePath, denyRead, cwd)) {
				throw new Error(`Read denied by sandbox policy: ${absolutePath}`);
			}
			return fsReadFile(absolutePath);
		},
		writeFile: async (absolutePath, content) => {
			if (!isWritePermitted(absolutePath, allowWrite, denyWrite, cwd)) {
				throw new Error(
					`Write denied by sandbox policy: ${absolutePath}` +
						(allowWrite?.length ? ` (allowed paths: ${allowWrite.join(", ")})` : ""),
				);
			}
			await fsWriteFile(absolutePath, content, "utf-8");
		},
		access: async (absolutePath) => {
			if (isReadDenied(absolutePath, denyRead, cwd)) {
				throw new Error(`Read denied by sandbox policy: ${absolutePath}`);
			}
			await fsAccess(absolutePath, constants.R_OK | constants.W_OK);
		},
	};
}

// ---------------------------------------------------------------------------
// Extension entry point
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
	pi.registerFlag("no-sandbox", {
		description: "Disable sandboxing (bash bubblewrap + filesystem policies)",
		type: "boolean",
		default: false,
	});

	const localCwd = process.cwd();
	const localBash = createBashTool(localCwd);
	const localRead = createReadTool(localCwd);
	const localWrite = createWriteTool(localCwd);
	const localEdit = createEditTool(localCwd);

	let sandboxEnabled = false;
	let sandboxInitialized = false;
	let currentConfig: SandboxConfig | undefined;

	// -- bash --
	pi.registerTool({
		...localBash,
		label: "bash (sandboxed)",
		async execute(id, params, signal, onUpdate, _ctx) {
			if (!sandboxEnabled || !sandboxInitialized) {
				return localBash.execute(id, params, signal, onUpdate);
			}

			const sandboxedBash = createBashTool(localCwd, {
				operations: createSandboxedBashOps(),
			});
			return sandboxedBash.execute(id, params, signal, onUpdate);
		},
	});

	// -- read --
	pi.registerTool({
		...localRead,
		label: "read (sandboxed)",
		async execute(id, params, signal, onUpdate, _ctx) {
			if (!sandboxEnabled || !currentConfig) {
				return localRead.execute(id, params, signal, onUpdate);
			}

			const policyRead = createReadTool(localCwd, {
				operations: createPolicyReadOps(localCwd, currentConfig),
			});
			return policyRead.execute(id, params, signal, onUpdate);
		},
	});

	// -- write --
	pi.registerTool({
		...localWrite,
		label: "write (sandboxed)",
		async execute(id, params, signal, onUpdate, _ctx) {
			if (!sandboxEnabled || !currentConfig) {
				return localWrite.execute(id, params, signal, onUpdate);
			}

			const policyWrite = createWriteTool(localCwd, {
				operations: createPolicyWriteOps(localCwd, currentConfig),
			});
			return policyWrite.execute(id, params, signal, onUpdate);
		},
	});

	// -- edit --
	pi.registerTool({
		...localEdit,
		label: "edit (sandboxed)",
		async execute(id, params, signal, onUpdate, _ctx) {
			if (!sandboxEnabled || !currentConfig) {
				return localEdit.execute(id, params, signal, onUpdate);
			}

			const policyEdit = createEditTool(localCwd, {
				operations: createPolicyEditOps(localCwd, currentConfig),
			});
			return policyEdit.execute(id, params, signal, onUpdate);
		},
	});

	// -- user_bash (! commands) --
	pi.on("user_bash", () => {
		if (!sandboxEnabled || !sandboxInitialized) return;
		return { operations: createSandboxedBashOps() };
	});

	// -- session lifecycle --
	pi.on("session_start", async (_event, ctx) => {
		const noSandbox = pi.getFlag("no-sandbox") as boolean;

		if (noSandbox) {
			sandboxEnabled = false;
			ctx.ui.notify("Sandbox disabled via --no-sandbox", "warning");
			return;
		}

		const config = loadConfig(ctx.cwd);
		currentConfig = config;

		if (!config.enabled) {
			sandboxEnabled = false;
			ctx.ui.notify("Sandbox disabled via config", "info");
			return;
		}

		const platform = process.platform;
		if (platform !== "darwin" && platform !== "linux") {
			sandboxEnabled = false;
			ctx.ui.notify(`Sandbox not supported on ${platform}`, "warning");
			return;
		}

		try {
			const configExt = config as unknown as {
				ignoreViolations?: Record<string, string[]>;
				enableWeakerNestedSandbox?: boolean;
			};

			await SandboxManager.initialize({
				network: config.network,
				filesystem: config.filesystem,
				ignoreViolations: configExt.ignoreViolations,
				enableWeakerNestedSandbox: configExt.enableWeakerNestedSandbox,
			});

			sandboxEnabled = true;
			sandboxInitialized = true;

			const networkCount = config.network?.allowedDomains?.length ?? 0;
			const writeCount = config.filesystem?.allowWrite?.length ?? 0;
			const denyReadCount = config.filesystem?.denyRead?.length ?? 0;
			ctx.ui.setStatus(
				"sandbox",
				ctx.ui.theme.fg(
					"accent",
					`🔒 Sandbox: ${networkCount} domains, ${writeCount} write paths, ${denyReadCount} deny-read`,
				),
			);
			ctx.ui.notify("Sandbox initialized (bash bubblewrap + FS policy)", "info");
		} catch (err) {
			sandboxEnabled = false;
			ctx.ui.notify(`Sandbox initialization failed: ${err instanceof Error ? err.message : err}`, "error");
		}
	});

	pi.on("session_shutdown", async () => {
		if (sandboxInitialized) {
			try {
				await SandboxManager.reset();
			} catch {
				// Ignore cleanup errors
			}
		}
		sandboxEnabled = false;
		sandboxInitialized = false;
		currentConfig = undefined;
	});

	// -- /sandbox command --
	pi.registerCommand("sandbox", {
		description: "Show sandbox configuration and status",
		handler: async (_args, ctx) => {
			const config = loadConfig(ctx.cwd);
			const lines = [
				`Sandbox: ${sandboxEnabled ? "✅ enabled" : "❌ disabled"}`,
				"",
				"Network (bubblewrap):",
				`  Allowed: ${config.network?.allowedDomains?.join(", ") || "(none)"}`,
				`  Denied: ${config.network?.deniedDomains?.join(", ") || "(none)"}`,
				"",
				"Filesystem (JS policy):",
				`  Deny Read: ${config.filesystem?.denyRead?.join(", ") || "(none)"}`,
				`  Allow Write: ${config.filesystem?.allowWrite?.join(", ") || "(none)"}`,
				`  Deny Write: ${config.filesystem?.denyWrite?.join(", ") || "(none)"}`,
				"",
				"Tools sandboxed: bash, !commands, read, write, edit",
			];
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});
}
