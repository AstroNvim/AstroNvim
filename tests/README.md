# Test Suite

Prerequisites: `make`, Git, and Neovim `v0.12.0` or newer. Neovim `v0.12.4` is the exact visual-golden baseline. The current CI compatibility lane uses Neovim nightly while it tracks the upcoming 0.13 release.

```sh
make test
```

Every test target prepares the generated `.tests/` environment first. A missing environment clones the latest `stable` lazy.nvim and resolves the full current AstroNvim plugin specification once. The generated lockfile and manifest remain in `.tests/`; ordinary runs reuse a valid marked environment offline and never read or modify the committed `tests/lazy-lock.json`. The e2e fixture intentionally disables AstroNvim snapshot pinning so it follows the latest stable plugin graph. Use `make test-update-deps` when you want to refresh the generated environment against that graph. Pinning behavior is covered separately by unit contracts.

Run `make test-fingerprint` to print the single SHA-256 compatibility fingerprint used by shared CI cache keys. It does not prepare or inspect `.tests/`. The fingerprint binds the harness schema, managed layout, runtime identity, explicit test dependencies, and AstroNvim plugin specification sources that control the resolved dependency graph.

Use `make test-clear` to remove only this repository's generated `.tests/` directory. Windows users can run `tests/clear-test-environment.ps1` when Make is unavailable. Use `make test-update-deps` to clear it and build a fresh latest environment. Network access is required only for a fresh build. When a fresh build is required, offline execution fails instead of attempting a repair. If an existing environment is incomplete or incompatible, clear it instead of attempting an online repair. Legacy unmarked environments are adopted only when lazy.nvim and every managed remote plugin are present at their expected paths with no tracked modifications. Untracked generated artifacts are allowed, and adoption never uses the network. Remove a stale `.tests.prepare.lock` only after confirming that no `make test-*` process still owns it.

Run the semantic cross-version suite with `make test-semantic`. It includes live LSP, DAP, Mason, Blink, Resession, Treesitter, diagnostics, and Neo-tree assertions but skips screenshot and highlight comparisons. Run `make test` only on a runtime with matching visual goldens. Run all unit tests with `make test-unit`, or run the lifecycle helper tests with `make test-unit-environment`. Focused end-to-end targets include `make test-startup`, `make test-lsp`, `make test-dap`, `make test-mason`, `make test-resession`, `make test-blink-e2e`, `make test-treesitter`, `make test-neo-tree`, and `make test-diagnostics`.

`tests/minit.lua` is the parent `mini.test` runner. Unit specs under `tests/unit/` run in the parent process and use `tests/unit_helpers.lua` to isolate modules, fake public boundaries, and restore state after each case. End-to-end specs start an isolated child Neovim through `tests/helpers.lua`; the child uses a temporary XDG environment and a copied fixture project. The CI required matrix covers Ubuntu, macOS, and Windows semantic lanes. Ubuntu 0.12.4 owns the visual lane. Rolling nightly compatibility runs separately and does not gate release.

Tests should fail when a supported behavior, lifecycle invariant, or public contract regresses. Assert observable behavior and forwarded arguments instead of mirroring implementation tables. Replace only public service boundaries when an upstream algorithm should not run in the test. A failing test is expected evidence of a real regression, not a reason to weaken the assertion.

Fixtures live in `tests/fixtures/`. The unversioned screen and highlight goldens are the exact Neovim 0.12.4 baseline. Development-build goldens, when needed for local validation, live below a full runtime version key. CI uploads a Markdown and JSON summary with per-case results, runtime identity, platform, and generated plugin commits. Add semantic assertions for editor state, mappings, options, or API results before adding a screen snapshot. Snapshots verify rendering; they should not be the only assertion.
