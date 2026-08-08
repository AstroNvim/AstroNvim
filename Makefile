.PHONY: test test-semantic test-prepare test-clear test-update-deps test-update-goldens test-unit test-unit-environment test-unit-helpers test-unit-e2e-helpers test-unit-init test-unit-notify test-unit-core test-unit-astrolsp test-unit-mason test-unit-blink test-unit-language-helpers test-unit-dap test-unit-ui test-unit-neo-tree test-unit-snacks test-unit-ui-helpers test-unit-workflows test-unit-health-dev test-unit-entrypoint test-unit-contracts test-fixtures test-startup test-astrocore test-astrolsp test-neo-tree test-snacks test-workflows test-diagnostics test-contracts test-behavior

TEST_TARGETS := test test-semantic test-update-goldens test-unit test-unit-environment test-unit-helpers test-unit-e2e-helpers test-unit-init test-unit-notify test-unit-core test-unit-astrolsp test-unit-mason test-unit-blink test-unit-language-helpers test-unit-dap test-unit-ui test-unit-neo-tree test-unit-snacks test-unit-ui-helpers test-unit-workflows test-unit-health-dev test-unit-entrypoint test-unit-contracts test-fixtures test-startup test-astrocore test-astrolsp test-neo-tree test-snacks test-workflows test-diagnostics test-contracts test-behavior

$(TEST_TARGETS): test-prepare

test:
	@nvim -l tests/minit.lua --minitest

test-semantic:
	@nvim -l tests/minit.lua --minitest tests/unit/*.lua tests/e2e/astrocore_spec.lua tests/e2e/astrolsp_spec.lua tests/e2e/behavior_spec.lua tests/e2e/contracts_spec.lua tests/e2e/fixture_variants_spec.lua tests/e2e/scaffold_spec.lua tests/e2e/snacks_spec.lua tests/e2e/startup_spec.lua tests/e2e/workflows_spec.lua

test-prepare:
	@nvim -l tests/bootstrap.lua

test-clear:
	@nvim -l tests/clear_test_environment.lua

test-update-deps:
	@$(MAKE) test-clear
	@$(MAKE) test-prepare

test-update-goldens:
	@export ASTRONVIM_TEST_UPDATE_GOLDENS=1; $(MAKE) test

test-unit:
	@nvim -l tests/minit.lua --minitest tests/unit/*.lua

test-unit-environment:
	@nvim -l tests/minit.lua --minitest tests/unit/test_environment_spec.lua

test-unit-helpers:
	@nvim -l tests/minit.lua --minitest tests/unit/helpers_spec.lua

test-unit-e2e-helpers:
	@nvim -l tests/minit.lua --minitest tests/unit/e2e_helpers_spec.lua

test-unit-init:
	@nvim -l tests/minit.lua --minitest tests/unit/init_spec.lua

test-unit-notify:
	@nvim -l tests/minit.lua --minitest tests/unit/notify_spec.lua

test-unit-core:
	@nvim -l tests/minit.lua --minitest tests/unit/core_spec.lua

test-unit-astrolsp:
	@nvim -l tests/minit.lua --minitest tests/unit/astrolsp_spec.lua

test-unit-mason:
	@nvim -l tests/minit.lua --minitest tests/unit/mason_spec.lua

test-unit-blink:
	@nvim -l tests/minit.lua --minitest tests/unit/blink_spec.lua

test-unit-language-helpers:
	@nvim -l tests/minit.lua --minitest tests/unit/language_helpers_spec.lua

test-unit-dap:
	@nvim -l tests/minit.lua --minitest tests/unit/dap_spec.lua

test-unit-ui:
	@nvim -l tests/minit.lua --minitest tests/unit/ui_spec.lua

test-unit-neo-tree:
	@nvim -l tests/minit.lua --minitest tests/unit/neo_tree_spec.lua

test-unit-snacks:
	@nvim -l tests/minit.lua --minitest tests/unit/snacks_spec.lua

test-unit-ui-helpers:
	@nvim -l tests/minit.lua --minitest tests/unit/ui_helpers_spec.lua

test-unit-workflows:
	@nvim -l tests/minit.lua --minitest tests/unit/workflows_spec.lua

test-unit-health-dev:
	@nvim -l tests/minit.lua --minitest tests/unit/health_dev_spec.lua

test-unit-entrypoint:
	@nvim -l tests/minit.lua --minitest tests/unit/entrypoint_spec.lua

test-unit-contracts:
	@nvim -l tests/minit.lua --minitest tests/unit/contracts_spec.lua

test-fixtures:
	@nvim -l tests/minit.lua --minitest tests/e2e/fixture_variants_spec.lua

test-startup:
	@nvim -l tests/minit.lua --minitest tests/e2e/startup_spec.lua

test-astrocore:
	@nvim -l tests/minit.lua --minitest tests/e2e/astrocore_spec.lua

test-astrolsp:
	@nvim -l tests/minit.lua --minitest tests/e2e/astrolsp_spec.lua

test-neo-tree:
	@nvim -l tests/minit.lua --minitest tests/e2e/neo_tree_spec.lua

test-snacks:
	@nvim -l tests/minit.lua --minitest tests/e2e/snacks_spec.lua

test-workflows:
	@nvim -l tests/minit.lua --minitest tests/e2e/workflows_spec.lua

test-diagnostics:
	@nvim -l tests/minit.lua --minitest tests/e2e/diagnostics_spec.lua

test-contracts:
	@nvim -l tests/minit.lua --minitest tests/e2e/contracts_spec.lua

test-behavior:
	@nvim -l tests/minit.lua --minitest tests/e2e/behavior_spec.lua
