/**
 * git-scout.ts — GitHub & GitLab code search and codebase scouting
 *
 * Provides custom tools for searching code and exploring repository structure
 * on GitHub and GitLab without needing MCP servers. Designed as a lightweight
 * alternative — 6 focused tools instead of 15+ from a full MCP server.
 *
 * ── Auth (config file or env vars) ────────────────────────────
 *   Config file: ~/.config/git-scout.json  (XDG), or ~/.git-scout.json
 *     { "github": { "token": "..." }, "gitlab": { "token": "...", "host": "..." } }
 *   Env vars (fallback):
 *     GitHub:  GITHUB_PAT    Fine-grained PAT with "Contents" read access
 *     GitLab:  GITLAB_TOKEN  Personal access token with "read_api" scope
 *              GITLAB_HOST   (Optional) Self-hosted instance hostname, e.g. "gitlab.company.com"
 *
 * ── Tools ────────────────────────────────────────────────────
 *   github_search_code         Search GitHub code via REST /search/code (legacy engine)
 *   github_get_repo_tree       List repo file tree (recursive or shallow)
 *   github_get_file_content    Read file contents from a GitHub repo
 *   gitlab_search_code         Search GitLab code — requires Premium/Ultimate or self-hosted Zoekt
 *   gitlab_get_repo_tree       List GitLab project file tree
 *   gitlab_get_file_content    Read file contents from a GitLab project
 *
 * ── Limitations ──────────────────────────────────────────────
 *   GitHub:  /search/code uses the legacy engine — 10 req/min, 256-char query,
 *            no regex/symbol search, only default branch indexed.
 *            File tree and content endpoints have standard rate limits (5000 req/hr).
 *   GitLab:  Code search (blobs scope) requires Premium/Ultimate or Zoekt.
 *            Free-tier users: use get_repo_tree + get_file_content for file-based scouting.
 */

import { Type } from "typebox";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

// ── Config (file or env vars) ────────────────────────────────

interface GitScoutConfig {
	github?: { token?: string };
	gitlab?: { token?: string; host?: string };
}

function loadConfig(): GitScoutConfig {
	const candidates = [
		join(process.env.XDG_CONFIG_HOME || join(homedir(), ".config"), "git-scout.json"),
		join(homedir(), ".git-scout.json"),
	];
	for (const p of candidates) {
		if (existsSync(p)) {
			try {
				return JSON.parse(readFileSync(p, "utf-8"));
			} catch {
				// skip unreadable or malformed files, try next candidate
			}
		}
	}
	return {};
}

let $config: GitScoutConfig = {};

function ghAuth(): Record<string, string> {
	const t = $config.github?.token ?? process.env.GITHUB_PAT ?? process.env.GH_TOKEN ?? process.env.GITHUB_TOKEN;
	if (!t) throw new Error(
		"GitHub token not found. Set it in ~/.config/git-scout.json ({\"github\":{\"token\":\"...\"}}) or via $GITHUB_PAT.",
	);
	return { Authorization: `Bearer ${t}`, Accept: "application/vnd.github.v3+json" };
}

function glAuth(): Record<string, string> {
	const t = $config.gitlab?.token ?? process.env.GITLAB_TOKEN;
	if (!t) throw new Error(
		"GitLab token not found. Set it in ~/.config/git-scout.json ({\"gitlab\":{\"token\":\"...\"}}) or via $GITLAB_TOKEN.",
	);
	return { "PRIVATE-TOKEN": t };
}

function glApiUrl(): string {
	const host = $config.gitlab?.host ?? process.env.GITLAB_HOST;
	return host ? `https://${host}/api/v4` : "https://gitlab.com/api/v4";
}

/** URL-encode a string for API paths. */
function enc(s: string): string {
	return encodeURIComponent(s);
}

/** URL-encode a GitLab project path (group/subgroup/project → group%2Fsubgroup%2Fproject). */
function glProj(s: string): string {
	return s.split("/").map(enc).join("%2F");
}

// ═══════════════════════════════════════════════════════════
// GitHub Tools
// ═══════════════════════════════════════════════════════════

const githubSearchCode = defineTool({
	name: "github_search_code",
	label: "GitHub Code Search",
	description:
		"Search code on GitHub via the REST API. Uses GitHub's legacy engine (not Blackbird). "
		+ "Limitations: 10 requests/minute, 256-char max query, no regex/symbol search, "
		+ "only the default branch is indexed, files >350 KiB excluded, `path:` qualifier is "
		+ "directory-prefix-only (not filename). "
		+ "Supports qualifiers: repo:, org:, language:, path:, extension:, filename:. "
		+ 'Example: "class:Handler repo:user/repo language:go"',
	parameters: Type.Object({
		query: Type.String({
			description:
				"Search query. Supports GitHub qualifiers like repo:, org:, language:, path:, extension:, filename:. "
				+ 'Example: "class:Handler repo:user/repo language:go"',
		}),
		limit: Type.Optional(Type.Integer({ description: "Max results (1–100, default: 20)" })),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const perPage = Math.min(p.limit ?? 20, 100);
		const url = `https://api.github.com/search/code?q=${enc(p.query)}&per_page=${perPage}`;
		const res = await fetch(url, { headers: ghAuth(), signal });
		const body = await res.json();
		if (!res.ok) {
			return {
				content: [{ type: "text", text: `GitHub Error ${res.status}: ${body.message ?? JSON.stringify(body)}` }],
				isError: true,
			};
		}
		const results = (body.items ?? []).slice(0, perPage).map((i: any) => ({
			repo: i.repository.full_name,
			path: i.path,
			url: i.html_url,
		}));
		return {
			content: [{ type: "text", text: JSON.stringify({ total: body.total_count, results }, null, 2) }],
			details: { total: body.total_count, count: results.length },
		};
	},
});

const githubGetRepoTree = defineTool({
	name: "github_get_repo_tree",
	label: "GitHub Repo Tree",
	description:
		"Get the file tree of a GitHub repository. Use to understand project structure, "
		+ "find relevant source files, or inspect a subdirectory. "
		+ "Returns up to 100k entries (GitHub's limit for recursive trees). "
		+ 'Pass path to narrow to a subtree (e.g. "src/lib").',
	parameters: Type.Object({
		repo: Type.String({ description: "Repository in 'owner/name' format, e.g. 'torvalds/linux'" }),
		path: Type.Optional(Type.String({ description: "Subdirectory to filter on (e.g. 'src/lib'). Omit for full tree." })),
		recursive: Type.Optional(Type.Boolean({
			description: "Recursive listing (default: true). Set false for top-level only.",
		})),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const recursive = p.recursive !== false;
		const qs = recursive ? "?recursive=1" : "";
		const url = `https://api.github.com/repos/${p.repo}/git/trees/HEAD${qs}`;
		const res = await fetch(url, { headers: ghAuth(), signal });
		const body = await res.json();
		if (!res.ok) {
			return {
				content: [{ type: "text", text: `GitHub Error ${res.status}: ${body.message ?? JSON.stringify(body)}` }],
				isError: true,
			};
		}
		let items = body.tree ?? [];
		if (p.path) items = items.filter((i: any) => i.path.startsWith(p.path!));
		const truncated = items.length > 500;
		return {
			content: [{
				type: "text",
				text: JSON.stringify(
					{ repo: p.repo, count: items.length, items: truncated ? items.slice(0, 500) : items },
					null,
					2,
				),
			}],
			details: { count: items.length, truncated },
		};
	},
});

const githubGetFileContent = defineTool({
	name: "github_get_file_content",
	label: "GitHub File Content",
	description:
		"Get the raw content of a file from a GitHub repository. "
		+ "Use to read source code, configuration files, documentation, etc. "
		+ "Files >1 MiB cannot be retrieved via this API. "
		+ "Returns file text decoded from base64.",
	parameters: Type.Object({
		repo: Type.String({ description: "Repository in 'owner/name' format, e.g. 'user/repo'" }),
		path: Type.String({ description: "File path within the repo, e.g. 'src/main.ts'" }),
		ref: Type.Optional(Type.String({ description: "Branch, tag, or commit SHA (default: default branch)" })),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const qs = p.ref ? `?ref=${enc(p.ref)}` : "";
		const url = `https://api.github.com/repos/${p.repo}/contents/${enc(p.path)}${qs}`;
		const res = await fetch(url, { headers: ghAuth(), signal });
		const body = await res.json();
		if (!res.ok) {
			return {
				content: [{ type: "text", text: `GitHub Error ${res.status}: ${body.message ?? JSON.stringify(body)}` }],
				isError: true,
			};
		}
		if (body.type === "dir") {
			return {
				content: [{ type: "text", text: `"${p.path}" is a directory. Use github_get_repo_tree to list its contents.` }],
				isError: true,
			};
		}
		if (body.encoding === "base64" && body.content) {
			const text = Buffer.from(body.content, "base64").toString("utf-8");
			return {
				content: [{ type: "text", text }],
				details: { size: body.size, sha: body.sha, path: body.path },
			};
		}
		return {
			content: [{ type: "text", text: body.content ?? "(empty file)" }],
			details: { size: body.size ?? 0 },
		};
	},
});

// ═══════════════════════════════════════════════════════════
// GitLab Tools
// ═══════════════════════════════════════════════════════════

const gitlabSearchCode = defineTool({
	name: "gitlab_search_code",
	label: "GitLab Code Search",
	description:
		"Search code in a GitLab project. Uses the 'blobs' scope which requires "
		+ "GitLab Premium/Ultimate or a self-hosted instance with Zoekt enabled. "
		+ "On Free/CE tier this will return 403 — use gitlab_get_repo_tree + "
		+ "gitlab_get_file_content for file-based exploration instead. "
		+ "Supports qualifiers: filename:*.ts, path:src/, extension:go. "
		+ "Set GITLAB_HOST env var for self-hosted instances.",
	parameters: Type.Object({
		project: Type.String({
			description:
				"Project path (e.g. 'group/project' or 'group/subgroup/project') or numeric project ID.",
		}),
		query: Type.String({ description: "Search term. Supports qualifiers: filename:, path:, extension:" }),
		limit: Type.Optional(Type.Integer({ description: "Max results (1–100, default: 20)" })),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const projEnc = glProj(p.project);
		const perPage = Math.min(p.limit ?? 20, 100);
		const url = `${glApiUrl()}/projects/${projEnc}/search?scope=blobs&search=${enc(p.query)}&per_page=${perPage}`;
		const res = await fetch(url, { headers: glAuth(), signal });
		const body = await res.json();
		if (!res.ok) {
			const msg = res.status === 403
				? "GitLab code search (blobs scope) requires Premium/Ultimate or self-hosted with Zoekt enabled. "
					+ "Try gitlab_get_repo_tree to list project files, then gitlab_get_file_content to read specific files."
				: `GitLab Error ${res.status}: ${JSON.stringify(body)}`;
			return { content: [{ type: "text", text: msg }], isError: true };
		}
		const results = (body ?? []).slice(0, perPage).map((i: any) => ({
			path: i.filename ?? i.path,
			ref: i.ref,
			url: i.web_url
				?? `${glApiUrl().replace("/api/v4", "")}/${projEnc}/-/blob/${i.ref}/${enc(i.filename ?? i.path)}`,
		}));
		return {
			content: [{ type: "text", text: JSON.stringify({ count: results.length, results }, null, 2) }],
			details: { count: results.length },
		};
	},
});

const gitlabGetRepoTree = defineTool({
	name: "gitlab_get_repo_tree",
	label: "GitLab Repo Tree",
	description:
		"List files and directories in a GitLab project's repository. "
		+ "Use to understand project layout, find relevant files, or explore a subdirectory. "
		+ "Set GITLAB_HOST env var for self-hosted instances. "
		+ "Results are paginated (100 per page by default). Use path to narrow scope.",
	parameters: Type.Object({
		project: Type.String({ description: "Project path (e.g. 'group/project') or numeric project ID." }),
		path: Type.Optional(Type.String({ description: "Subdirectory to list (default: root). Use '' for full tree." })),
		recursive: Type.Optional(Type.Boolean({
			description: "List recursively (default: false for GitLab — set true for full tree traversal). "
				+ "Note: GitLab's API is flat per page; multiple pages may be needed for large projects.",
		})),
		limit: Type.Optional(Type.Integer({ description: "Max results (default: 100, max: 500)" })),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const projEnc = glProj(p.project);
		const perPage = Math.min(p.limit ?? 100, 500);
		let url = `${glApiUrl()}/projects/${projEnc}/repository/tree?per_page=${perPage}`;
		if (p.path) url += `&path=${enc(p.path)}`;
		if (p.recursive) url += "&recursive=true";
		const res = await fetch(url, { headers: glAuth(), signal });
		const body = await res.json();
		if (!res.ok) {
			return {
				content: [{ type: "text", text: `GitLab Error ${res.status}: ${JSON.stringify(body)}` }],
				isError: true,
			};
		}
		const items = (body ?? []).map((i: any) => ({
			path: i.path,
			type: i.type,
			mode: i.mode,
		}));
		const truncated = items.length > 500;
		return {
			content: [{
				type: "text",
				text: JSON.stringify(
					{ project: p.project, count: items.length, items: truncated ? items.slice(0, 500) : items },
					null,
					2,
				),
			}],
			details: { count: items.length, truncated },
		};
	},
});

const gitlabGetFileContent = defineTool({
	name: "gitlab_get_file_content",
	label: "GitLab File Content",
	description:
		"Get the raw content of a file from a GitLab project. "
		+ "Use to read source code, configuration, or documentation files. "
		+ "Returns the file as plain text. "
		+ "Set GITLAB_HOST env var for self-hosted instances.",
	parameters: Type.Object({
		project: Type.String({ description: "Project path (e.g. 'group/project') or numeric project ID." }),
		path: Type.String({ description: "File path within the project, e.g. 'src/main.py'" }),
		ref: Type.Optional(Type.String({ description: "Branch, tag, or commit SHA (default: default branch)." })),
	}),
	async execute(_id, p, signal, _upd, _ctx) {
		const projEnc = glProj(p.project);
		const fileEnc = enc(p.path);
		const qs = p.ref ? `?ref=${enc(p.ref)}` : "";
		const url = `${glApiUrl()}/projects/${projEnc}/repository/files/${fileEnc}/raw${qs}`;
		const res = await fetch(url, { headers: glAuth(), signal });
		if (!res.ok) {
			const body = await res.text().catch(() => "");
			return {
				content: [{ type: "text", text: `GitLab Error ${res.status}: ${body || res.statusText}` }],
				isError: true,
			};
		}
		const text = await res.text();
		return {
			content: [{ type: "text", text }],
			details: { path: p.path, size: text.length },
		};
	},
});

// ═══════════════════════════════════════════════════════════
// Extension Entry Point
// ═══════════════════════════════════════════════════════════

export default function (pi: ExtensionAPI) {
	// Load config once at startup; falls back to env vars if no config file found.
	$config = loadConfig();

	pi.registerTool(githubSearchCode);
	pi.registerTool(githubGetRepoTree);
	pi.registerTool(githubGetFileContent);
	pi.registerTool(gitlabSearchCode);
	pi.registerTool(gitlabGetRepoTree);
	pi.registerTool(gitlabGetFileContent);
}
