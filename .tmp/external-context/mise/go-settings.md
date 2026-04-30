---
source: Official docs (webfetch)
library: mise
package: mise
topic: Go language settings
fetched: 2026-04-30T00:00:00Z
official_docs: https://mise.jdx.dev/lang/go.html
---

# mise Go Settings

All Go-specific settings live under `[settings.go]` in `~/.config/mise/config.toml`.

## Correct key names (as of 2026-04-30)

| Key | Type | Default | Notes |
|-----|------|---------|-------|
| `go.set_goroot` | boolean | `true` | Sets `GOROOT=~/.local/share/mise/installs/go/.../` |
| `go.set_gopath` | boolean | `false` | **DEPRECATED** — use `env._go.set_goroot` instead |
| `go.set_gobin` | boolean (optional) | `None` | Controls `GOBIN` |
| `go.default_packages_file` | string | `~/.default-go-packages` | Path to default packages file |
| `go.download_mirror` | string | `https://dl.google.com/go` | Mirror for SDK tarballs |
| `go.repo` | string | `https://github.com/golang/go` | URL to fetch go from |
| `go.skip_checksum` | boolean | `false` | Skip checksum verification |

## Correct TOML syntax

```toml
[settings.go]
set_goroot = true
set_gopath = false  # deprecated
default_packages_file = "~/.config/mise/go-packages"
```

Note: `set_gopath` is deprecated. The deprecation notice says:
> Deprecated: Use env._go.set_goroot instead.

## Why the warning occurs

The warning `mise WARN  unknown field in ~/.config/mise/config.toml: settings.go` is
likely caused by a **mise version mismatch** — older versions of mise did not support
`[settings.go]` as a subsection. The key names themselves (`set_goroot`, `set_gopath`,
`default_packages_file`) are correct per current docs.

There is NO separate `settings.toml` file — all settings go in `config.toml` under `[settings]`.

## Source

- https://mise.jdx.dev/lang/go.html
- https://mise.jdx.dev/configuration/settings.html#go
