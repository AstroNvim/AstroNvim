# Test Suite

Prerequisites: `make`, Git, and Neovim `v0.11.0` or newer. Neovim `v0.12.4` is the exact visual-golden baseline.

```sh
make test
```

Every test target prepares the generated `.tests/` environment first. A missing environment clones the latest `stable` lazy.nvim and resolves the full current AstroNvim plugin specification once. The generated lockfile and manifest remain in `.tests/`; ordinary runs reuse a valid marked environment offline and never read or modify the committed `tests/lazy-lock.json`.

Use `make test-clear` to remove only this repository's generated `.tests/` directory. Use `make test-update-deps` to clear it and build a fresh latest environment. Network access is required only for a fresh build. When a fresh build is required, offline execution fails instead of attempting a repair. If an existing environment is incomplete or incompatible, clear it instead of attempting an online repair. Legacy unmarked environments are adopted only when lazy.nvim and every managed remote plugin are present at their expected paths with no tracked modifications. Untracked generated artifacts are allowed, and adoption never uses the network. Remove a stale `.tests.prepare.lock` only after confirming that no `make test-*` process still owns it.

Run the non-visual cross-version suite with `make test-semantic`. Run all unit tests with `make test-unit`, or run the lifecycle helper tests with `make test-unit-environment`. Focused end-to-end targets include `make test-startup`, `make test-astrocore`, `make test-neo-tree`, `make test-diagnostics`, `make test-contracts`, and `make test-behavior`.

`tests/minit.lua` is the parent `mini.test` runner. Unit specs under `tests/unit/` run in the parent process and use `tests/unit_helpers.lua` to isolate modules, fake public boundaries, and restore state after each case. End-to-end specs start an isolated child Neovim through `tests/helpers.lua`; the child uses a temporary XDG environment and a copied fixture project.

Tests should fail when a supported behavior, lifecycle invariant, or public contract regresses. Assert observable behavior and forwarded arguments instead of mirroring implementation tables. Replace only public service boundaries when an upstream algorithm should not run in the test. A failing test is expected evidence of a real regression, not a reason to weaken the assertion.

Fixtures live in `tests/fixtures/`. Screen goldens live in `tests/screenshots/`, and highlight goldens live in `tests/highlights/`. Add semantic assertions for editor state, mappings, options, or API results before adding a screen snapshot. Snapshots verify rendering; they should not be the only assertion.
