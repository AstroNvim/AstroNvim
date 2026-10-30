# Test coverage map

This map separates user-visible integration from unit contracts and implementation inspection. A test failure should normally identify a user-visible regression, a stable public contract violation, a lifecycle safety problem, or a supported runtime compatibility problem.

| Area | Current coverage | Test class | Remaining live coverage |
| --- | --- | --- | --- |
| Startup and plugin environment | `startup_spec.lua`, `helpers.lua`, `bootstrap.lua` | Live child and harness contract | Upload generated provenance and add packaged-shape smoke coverage |
| AstroCore mappings and buffer lifecycle | `astrocore_spec.lua`, `core_spec.lua` | Live child plus focused unit contracts | Review private state assertions and add platform-safe terminal fixtures |
| AstroLSP formatting and signature help | `astrolsp_spec.lua`, `lsp_spec.lua`, unit specs | Live local-server formatting, client capability merge, and file-create protocol traffic plus fake-client contracts | Expand only if a new public protocol path is added |
| Mason and Mason LSP integration | `mason_spec.lua`, `mason_spec.lua` e2e, and related unit specs | Live Mason UI/registry smoke plus mocked contracts | Add live Mason LSP server setup only if release behavior requires it |
| DAP and launch configuration | `dap_spec.lua` unit and e2e, production launch parser and adapter fixtures | Live launch parsing, hermetic adapter initialization/termination, DAP UI lifecycle, and mocked mapping contracts | Add breakpoint or stepping coverage only if AstroNvim-owned behavior requires it |
| Blink completion | `blink_spec.lua` unit and e2e | Live buffer completion menu acceptance/hide lifecycle plus configured mapping contracts | Add native LSP completion only if that becomes an AstroNvim-owned product contract |
| Treesitter | `language_helpers_spec.lua`, `core_spec.lua`, `treesitter_spec.lua` e2e | Live Lua parser and large-buffer behavior plus declaration contracts | Add textobject/highlighting assertions only when parser availability is hermetic |
| Neo-tree | `neo_tree_spec.lua`, screenshots, unit specs | Live UI, external file updates, and OS-specific refresh behavior | Add more watcher timing cases only for observed regressions |
| Diagnostics and Heirline | `diagnostics_spec.lua`, screenshots, unit specs | Live state and exact visual baseline | Keep semantics portable; isolate exact Ubuntu 0.12.4 visual contracts |
| Snacks UI | `snacks_spec.lua` | Live dashboard/input/select cleanup | Add error and repeated-session edge cases only where user-visible |
| Resession | `workflows_spec.lua`, `resession_spec.lua` e2e, unit workflows | Live save/restore across child restart plus mocked forwarding contracts | Add ignored-buffer persistence cases if the real session contract changes |
| ToggleTerm | `workflows_spec.lua`, `astrocore_spec.lua` | Live terminal windows and mappings | Verify platform-neutral child commands and cleanup |
| Gitsigns and GuessIndent | `workflows_spec.lua`, `fixture_variants_spec.lua` | Live lazy activation and fixture behavior | Add failure notification coverage if the public behavior requires it |
| Notifications and health | unit specs, startup notification e2e | Focused unit and startup integration | Keep malformed version and startup error contracts logic-based |
| Platform behavior | platform-aware helpers, unit mocks, Windows/macOS CI lanes | Real semantic smoke on supported hosted runners plus simulated branches | Add platform-specific visual lanes only if visual support is promised |
| Dependency provenance | generated `.tests/manifest.json`, lock, `ci_summary.lua`, and case results | Per-job JSON/Markdown summary and uploaded artifacts | Add long-term retention or comparison tooling if trend analysis is needed |

## Assertion policy

- Prefer editor state, rendered effects, command results, forwarded public arguments, and lifecycle outcomes.
- Assert required members and invariants instead of complete plugin tables or private manager fields.
- Do not use `package.loaded` as the success condition. Assert the behavior that loading was meant to enable.
- Keep exact versions, commits, serialized data, and compatibility fields only when they are the public or harness contract being protected.
- Keep visual snapshots only for the documented exact runtime baseline. Do not use visual snapshots as the only behavior assertion.
- Name tests with a unique file-qualified identity. Avoid repeated short IDs across files.
