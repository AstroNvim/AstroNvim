# Test Suite

Prerequisites: `make`, Git, and Neovim `v0.12.4`. This exact Neovim version is the visual-golden baseline. Network access is required the first time dependencies are prepared.

```sh
make test-prepare
make test
```

Run a focused suite with `make test-startup`, `make test-neo-tree`, `make test-diagnostics`, `make test-contracts`, or `make test-behavior`.

Dependencies are pinned in `tests/lazy-lock.json`. Run `make test-update-deps` only when intentionally updating them, then review and commit the lockfile change. Goldens are also explicit: run `make test-update-goldens` only after reviewing an expected visual or highlight change, then review the files it updates.

`tests/minit.lua` is the parent `mini.test` runner. Each test starts an isolated child Neovim through `tests/helpers.lua`; the child uses a temporary XDG environment and a copied fixture project. Keep parent-runner state isolated from child assertions.

Fixtures live in `tests/fixtures/`. Screen goldens live in `tests/screenshots/`, and highlight goldens live in `tests/highlights/`. Add semantic assertions for editor state, mappings, options, or API results before adding a screen snapshot. Snapshots verify rendering; they should not be the only assertion.
