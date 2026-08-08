.PHONY: test test-prepare test-update-deps test-update-goldens test-startup test-neo-tree test-diagnostics test-contracts test-behavior

test:
	@nvim -l tests/minit.lua --minitest

test-prepare:
	@nvim -l tests/bootstrap.lua --restore

test-update-deps:
	@nvim -l tests/bootstrap.lua --update

test-update-goldens:
	@export ASTRONVIM_TEST_UPDATE_GOLDENS=1; make test

test-startup:
	@nvim -l tests/minit.lua --minitest tests/e2e/startup_spec.lua

test-neo-tree:
	@nvim -l tests/minit.lua --minitest tests/e2e/neo_tree_spec.lua

test-diagnostics:
	@nvim -l tests/minit.lua --minitest tests/e2e/diagnostics_spec.lua

test-contracts:
	@nvim -l tests/minit.lua --minitest tests/e2e/contracts_spec.lua

test-behavior:
	@nvim -l tests/minit.lua --minitest tests/e2e/behavior_spec.lua
