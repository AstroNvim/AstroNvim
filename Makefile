.PHONY: test test-semantic test-unit test-unit-contracts test-e2e test-harness-unit test-prepare test-clear test-update-deps test-fingerprint test-update-goldens

E2E_REPOSITORY ?= ../AstroNvim-e2e
E2E_ROOT := $(abspath $(E2E_REPOSITORY))
E2E_MAKEFILE := $(E2E_ROOT)/Makefile
NVIM ?= nvim

define RUN_E2E
	@test -f "$(E2E_MAKEFILE)" || { \
		echo "The optional AstroNvim-e2e checkout is required: $(E2E_ROOT)" >&2; \
		exit 1; \
	}
	@$(MAKE) -f "$(E2E_MAKEFILE)" $(1) \
		SOURCE_ROOT="$(CURDIR)" \
		HARNESS_ROOT="$(E2E_ROOT)" \
		NVIM="$(NVIM)"
endef

test:
	$(call RUN_E2E,test)

test-semantic:
	$(call RUN_E2E,test-semantic)

test-unit:
	$(call RUN_E2E,test-unit)

test-unit-contracts:
	$(call RUN_E2E,test-unit-contracts)

test-e2e:
	$(call RUN_E2E,test-e2e)

test-harness-unit:
	$(call RUN_E2E,test-harness-unit)

test-prepare:
	$(call RUN_E2E,test-prepare)

test-clear:
	$(call RUN_E2E,test-clear)

test-update-deps:
	$(call RUN_E2E,test-update-deps)

test-fingerprint:
	$(call RUN_E2E,test-fingerprint)

test-update-goldens:
	$(call RUN_E2E,test-update-goldens)
